
import UIKit
import CoreData

class CalibrationViewController: UIViewController {

//------------------------------------------------------------------------------
// Local Variables
//------------------------------------------------------------------------------
    private let _managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    private var _globalSetting: GlobalSetting!
    private var _currentSetting: CalibrationSetting!
    
    private var _settings: [CalibrationSetting] = []
    
    private var _player: CalibrationPlayer!
    private var _currentPickerIndex: Int = 0;
    private var _currentPlayFreq: Int = -1;

//------------------------------------------------------------------------------
// UI Components
//------------------------------------------------------------------------------
    private var settingColumnLookup: [Int: CalibrationSettingColumn] = [:]
    
    @IBOutlet weak var pbReturnToTitle: UIButton!
    @IBOutlet weak var pbLoadDefault: UIButton!
    @IBOutlet weak var pbClearMesaureLevels: UIButton!
    @IBOutlet weak var pbSaveCurrent: UIButton!
    @IBOutlet weak var pbSaveAsNew: UIButton!
    @IBOutlet weak var pbLoadOther: UIButton!
    @IBOutlet weak var pbDeleteCurrent: UIButton!
    
    @IBOutlet weak var lbExpectedSoundPressureLevel: UILabel!
    @IBOutlet weak var lbPresentationLevel: UILabel!
    @IBOutlet weak var lbLeftMeasuredLevel: UILabel!
    @IBOutlet weak var lbRightMeasuredLevel: UILabel!
    @IBOutlet weak var lbCurrentSettingCaption: UILabel!
    @IBOutlet weak var lbCurrentSetting: UILabel!
    
    @IBOutlet weak var svFreqLabels: UIStackView!
    @IBOutlet weak var svPlayButtons: UIStackView!
    @IBOutlet weak var svExpectedLv: UIStackView!
    @IBOutlet weak var svPresentationLv: UIStackView!
    @IBOutlet weak var svMeasuredLv_L: UIStackView!
    @IBOutlet weak var svMeasuredLv_R: UIStackView!

//------------------------------------------------------------------------------
// CRUD for CalibrationSetting
//------------------------------------------------------------------------------
    @IBAction func saveAsNewSetting(_ sender: UIButton) {
        
        inputPrompt(promptMsg: "Please enter setting name:",
                    errorMsg: "Setting name cannot be empty!",
                    fieldMsg: "i.e. iPad1-EP1",
                    confirmFunction: saveSetting,
                    uiCtrl: self)
    }
    
    @IBAction func updateCurrentSetting(_ sender: UIButton) {
        _currentSetting.timestamp = Date()
        
        for settingValues in _currentSetting.values! {
            let values = settingValues as! CalibrationSettingValues
            
            let settingUI = settingColumnLookup[Int(values.frequency)]
            
            values.expectedLv = Double((settingUI?.tfExpectedLv.text)!) ?? 0.0
            values.presentationLv = Double((settingUI?.tfPresentationLv.text)!) ?? 0.0
            values.measuredLv_L = Double((settingUI?.tfMeasuredLv_L.text)!) ?? 0.0
            values.measuredLv_R = Double((settingUI?.tfMeasuredLv_R.text)!) ?? 0.0
        }
        
        do{
            try _managedContext.save()
        } catch let error as NSError{
            print("Could not update calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    func saveSetting(_ settingName: String){
        let setting = NSEntityDescription.insertNewObject(
            forEntityName: "CalibrationSetting",
            into: _managedContext) as! CalibrationSetting
        
        setting.name = settingName
        setting.timestamp = Date()
        
        lbCurrentSetting.text = settingName
        pbSaveCurrent.isEnabled = true
        pbDeleteCurrent.isEnabled = true
        
        for freq in DEFAULT_FREQUENCIES {
            let values = NSEntityDescription.insertNewObject(
                forEntityName: "CalibrationSettingValues",
                into: _managedContext) as! CalibrationSettingValues
            
            let settingUI = settingColumnLookup[freq]
            
            values.frequency = Int16(freq)
            
            values.expectedLv = Double((settingUI?.tfExpectedLv.text)!) ?? 0.0
            values.presentationLv = Double((settingUI?.tfPresentationLv.text)!) ?? 0.0
            values.measuredLv_L = Double((settingUI?.tfMeasuredLv_L.text)!) ?? 0.0
            values.measuredLv_R = Double((settingUI?.tfMeasuredLv_R.text)!) ?? 0.0
            setting.addToValues(values)
        }
        
        _currentSetting = setting
        _globalSetting.calibrationSetting = setting
        
        do{
            try _managedContext.save()
        } catch let error as NSError{
            print("Could not save calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    @IBAction func loadOtherSetting(_ sender: UIButton) {
        _currentPickerIndex = 0
        
        // fetch all CalibrationSetting
        let request:NSFetchRequest<CalibrationSetting> =
            CalibrationSetting.fetchRequest()
        
        let sortByTimestamp = NSSortDescriptor(
            key: #keyPath(CalibrationSetting.timestamp),
            ascending: true)
        request.sortDescriptors = [sortByTimestamp]
        
        do {
            _settings = try _managedContext.fetch(request)
        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }
        
        pickerPrompt(confirmFunction: {()->Void in
            do{
                self._currentSetting = self._settings[self._currentPickerIndex]
                self._globalSetting.calibrationSetting = self._currentSetting
                
                self.loadSettingValues()
                
                self.pbSaveCurrent.isEnabled = true
                self.pbDeleteCurrent.isEnabled = true
                
                try self._managedContext.save()
                print("Done Loading", self._currentSetting.name!)
            } catch let error as NSError{
                print("Could not update calibration setting.")
                print("\(error), \(error.userInfo)")
            }
        }, uiCtrl: self)
    }
    
    func loadSettingValues(){
        lbCurrentSetting.text = _currentSetting.name!
        
        // Load setting name
        for settingValues in _currentSetting.values! {
            let values = settingValues as! CalibrationSettingValues
            
            let settingUI = settingColumnLookup[Int(values.frequency)]
            
            settingUI?.tfExpectedLv.text = String(values.expectedLv)
            settingUI?.tfPresentationLv.text = String(values.presentationLv)
            settingUI?.tfMeasuredLv_L.text = String(values.measuredLv_L)
            settingUI?.tfMeasuredLv_R.text = String(values.measuredLv_R)
        }
    }
    
    @IBAction func deleteCurrentSetting(_ sender: UIButton) {
        _managedContext.delete(_currentSetting)
        _currentSetting = nil
        _globalSetting.calibrationSetting = nil
        lbCurrentSetting.text = NSLocalizedString("None", comment: "")
        
        self.pbSaveCurrent.isEnabled = false
        self.pbDeleteCurrent.isEnabled = false
    }
    
//------------------------------------------------------------------------------
// View utiliy functions
//------------------------------------------------------------------------------
    @IBAction func loadDefaultPresentationLevels(_ sender: UIButton) {
        for (freq, settingUI) in settingColumnLookup {
            let expectedLevel = ER3A_EXPECTED_LEVELS[freq] ?? 0.0
            let measuredLevel = ER3A_MEASURED_LEVELS[freq] ?? 0.0
            settingUI.tfExpectedLv.text = String(expectedLevel)
            settingUI.tfPresentationLv.text = String(DB_DEFAULT)
            settingUI.tfMeasuredLv_L.text = String(measuredLevel)
            settingUI.tfMeasuredLv_R.text = String(measuredLevel)
        }
    }
    
    @IBAction func clearAllMeasuredLevels(_ sender: UIButton) {
        for settingUI in settingColumnLookup.values {
            settingUI.tfMeasuredLv_L.text = ""
            settingUI.tfMeasuredLv_R.text = ""
        }
        
    }
    
    @IBAction func togglePlayerSingal(_ sender: UIButton){
        // No tone playing at all, simply toggle on
        if(!_player.isStarted()){
            _currentPlayFreq = sender.tag
            settingColumnLookup[sender.tag]!.pbPlay.setTitle("On", for: .normal)
            _player.startPlaying()
            
            // Update freq & vol
            _player.updateFreq(_currentPlayFreq)
            _player.updateVolume(settingColumnLookup[sender.tag]!)
        }
            // Same tone, toggle it off
        else if(_currentPlayFreq == sender.tag){
            settingColumnLookup[sender.tag]!.pbPlay.setTitle("Off", for: .normal)
            _currentPlayFreq = -1
            _player.stopPlaying()
        }
            // Else tone, switch frequency
        else {
            settingColumnLookup[_currentPlayFreq]!.pbPlay.setTitle("Off", for: .normal)
            settingColumnLookup[sender.tag]!.pbPlay.setTitle("On", for: .normal)
            
            _currentPlayFreq = sender.tag
            
            // Update freq & vol
            _player.updateFreq(_currentPlayFreq)
            _player.updateVolume(settingColumnLookup[sender.tag]!)
        }
    }
//------------------------------------------------------------------------------
// Initialize View
//------------------------------------------------------------------------------
    
    private func setupStackViews(_ sv: UIStackView!){
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .center
        sv.spacing = 20
    }
    
    private func initSettings(){
        _player = CalibrationPlayer()
        // fetch all CalibrationSetting
        let request:NSFetchRequest<GlobalSetting> =
            GlobalSetting.fetchRequest()
        request.fetchLimit = 1
        
        do {
            _globalSetting = try _managedContext.fetch(request).first
            if(_globalSetting.calibrationSetting != nil){
                _currentSetting =
                    _globalSetting.calibrationSetting ?? CalibrationSetting()
                
                loadSettingValues()
                lbCurrentSetting.text = _currentSetting.name
                
            }
            else {
                lbCurrentSetting.text = NSLocalizedString("None", comment: "")
                pbSaveCurrent.isEnabled = false
                pbDeleteCurrent.isEnabled = false
            }
            
        } catch let error as NSError{
            print("Could not fetch global setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    private func reloadLocaleStrings() {
        pbReturnToTitle.setTitle(
            NSLocalizedString("Return To Title", comment: ""), for: .normal)
        
        lbExpectedSoundPressureLevel.text =
            NSLocalizedString("Expected SPL", comment: "")
        lbPresentationLevel.text =
            NSLocalizedString("Presentation Level", comment: "")
        lbLeftMeasuredLevel.text =
            NSLocalizedString("Left Measured Level", comment: "")
        lbRightMeasuredLevel.text =
            NSLocalizedString("Right Measured Level", comment: "")
        lbCurrentSettingCaption.text =
            NSLocalizedString("Current Setting Caption", comment: "")
        
        pbLoadDefault.setTitle(
            NSLocalizedString("Load Default", comment: ""), for: .normal)
        pbClearMesaureLevels.setTitle(
            NSLocalizedString("Clear Measured Levels", comment: ""), for: .normal)
        pbSaveCurrent.setTitle(
            NSLocalizedString("Save", comment: ""), for: .normal)
        pbSaveAsNew.setTitle(
            NSLocalizedString("Save As New", comment: ""), for: .normal)
        pbLoadOther.setTitle(
            NSLocalizedString("Load Other", comment: ""), for: .normal)
        pbDeleteCurrent.setTitle(
            NSLocalizedString("Delete Current", comment: ""), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Get default frequencies from util setting files
        // and setup the UI
        setupStackViews(svFreqLabels)
        setupStackViews(svPlayButtons)
        setupStackViews(svExpectedLv)
        setupStackViews(svPresentationLv)
        setupStackViews(svMeasuredLv_L)
        setupStackViews(svMeasuredLv_R)
        
        for freq in DEFAULT_FREQUENCIES {
            let settingUI = CalibrationSettingColumn(freq: freq)
            settingUI.pbPlay.addTarget(self,
                                       action: #selector(togglePlayerSingal(_:)),
                                       for: .touchUpInside)
            settingColumnLookup[freq] = settingUI
            
            // Displaying in subview
            svFreqLabels.addArrangedSubview(settingUI.lbFreq)
            svPlayButtons.addArrangedSubview(settingUI.pbPlay)
            svExpectedLv.addArrangedSubview(settingUI.tfExpectedLv)
            svPresentationLv.addArrangedSubview(settingUI.tfPresentationLv)
            svMeasuredLv_L.addArrangedSubview(settingUI.tfMeasuredLv_L)
            svMeasuredLv_R.addArrangedSubview(settingUI.tfMeasuredLv_R)
        }
        // Load from CoreData all calibration settings
        // and their sub values by freqs
        initSettings()
        reloadLocaleStrings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CalibrationViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return _settings.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return _settings[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        
        _currentPickerIndex = row
    }
}

