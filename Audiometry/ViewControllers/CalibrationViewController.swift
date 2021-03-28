
import UIKit
import CoreData

class CalibrationViewController: UIViewController {

//------------------------------------------------------------------------------
// Local Variables
//------------------------------------------------------------------------------
    private let managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    private var globalSetting: GlobalSetting!
    private var currentSetting: CalibrationSetting!
    
    private var array_settings: [CalibrationSetting] = []
    
    private var player: CalibrationPlayer!
    private var _currentPickerIndex: Int = 0;
    private var _currentPlayFreq: Int = -1;

//------------------------------------------------------------------------------
// UI Components
//------------------------------------------------------------------------------
    private var dict_settingUI: [Int: SettingUI] = [:]
    
    @IBOutlet var pbSaveCurrent: UIButton!
    @IBOutlet var pbLoadOther: UIButton!
    @IBOutlet var pbDeleteCurrent: UIButton!
    
    @IBOutlet var lbCurrentSetting: UILabel!
    
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
        currentSetting.timestamp = Date()
        
        for settingValues in currentSetting.values! {
            let values = settingValues as! CalibrationSettingValues
            
            let settingUI = dict_settingUI[Int(values.frequency)]
            
            values.expectedLv = Double((settingUI?.tfExpectedLv.text)!) ?? 0.0
            values.presentationLv = Double((settingUI?.tfPresentationLv.text)!) ?? 0.0
            values.measuredLv_L = Double((settingUI?.tfMeasuredLv_L.text)!) ?? 0.0
            values.measuredLv_R = Double((settingUI?.tfMeasuredLv_R.text)!) ?? 0.0
        }
        
        do{
            try managedContext.save()
        } catch let error as NSError{
            print("Could not update calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    func saveSetting(_ settingName: String){
        let setting = NSEntityDescription.insertNewObject(
            forEntityName: "CalibrationSetting",
            into: managedContext) as! CalibrationSetting
        
        setting.name = settingName
        setting.timestamp = Date()
        
        lbCurrentSetting.text = settingName
        pbSaveCurrent.isEnabled = true
        pbDeleteCurrent.isEnabled = true
        
        for freq in ARRAY_DEFAULT_FREQ {
            let values = NSEntityDescription.insertNewObject(
                forEntityName: "CalibrationSettingValues",
                into: managedContext) as! CalibrationSettingValues
            
            let settingUI = dict_settingUI[freq]
            
            values.frequency = Int16(freq)
            
            values.expectedLv = Double((settingUI?.tfExpectedLv.text)!) ?? 0.0
            values.presentationLv = Double((settingUI?.tfPresentationLv.text)!) ?? 0.0
            values.measuredLv_L = Double((settingUI?.tfMeasuredLv_L.text)!) ?? 0.0
            values.measuredLv_R = Double((settingUI?.tfMeasuredLv_R.text)!) ?? 0.0
            setting.addToValues(values)
        }
        
        currentSetting = setting
        globalSetting.calibrationSetting = setting
        
        do{
            try managedContext.save()
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
            array_settings = try managedContext.fetch(request)
        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }
        
        pickerPrompt(confirmFunction: {()->Void in
            do{
                self.currentSetting = self.array_settings[self._currentPickerIndex]
                self.globalSetting.calibrationSetting = self.currentSetting
                
                self.loadSettingValues()
                
                self.pbSaveCurrent.isEnabled = true
                self.pbDeleteCurrent.isEnabled = true
                
                try self.managedContext.save()
                print("Done Loading", self.currentSetting.name!)
            } catch let error as NSError{
                print("Could not update calibration setting.")
                print("\(error), \(error.userInfo)")
            }
        }, uiCtrl: self)
    }
    
    func loadSettingValues(){
        lbCurrentSetting.text = currentSetting.name!
        
        // Load setting name
        for settingValues in currentSetting.values! {
            let values = settingValues as! CalibrationSettingValues
            
            let settingUI = dict_settingUI[Int(values.frequency)]
            
            settingUI?.tfExpectedLv.text = String(values.expectedLv)
            settingUI?.tfPresentationLv.text = String(values.presentationLv)
            settingUI?.tfMeasuredLv_L.text = String(values.measuredLv_L)
            settingUI?.tfMeasuredLv_R.text = String(values.measuredLv_R)
        }
    }
    
    @IBAction func deleteCurrentSetting(_ sender: UIButton) {
        managedContext.delete(currentSetting)
        currentSetting = nil
        globalSetting.calibrationSetting = nil
        lbCurrentSetting.text = "None"
        
        self.pbSaveCurrent.isEnabled = false
        self.pbDeleteCurrent.isEnabled = false
    }
    
//------------------------------------------------------------------------------
// View utiliy functions
//------------------------------------------------------------------------------
    @IBAction func loadDefaultPresentationLv(_ sender: UIButton) {
        for (freq, settingUI) in dict_settingUI {
            let expectedLevel = ER3A_EXPECTED_LEVELS[freq] ?? 0.0
            let measuredLevel = ER3A_MEASURED_LEVELS[freq] ?? 0.0
            settingUI.tfExpectedLv.text = String(expectedLevel)
            settingUI.tfPresentationLv.text = String(DB_DEFAULT)
            settingUI.tfMeasuredLv_L.text = String(measuredLevel)
            settingUI.tfMeasuredLv_R.text = String(measuredLevel)
        }
    }
    
    @IBAction func clearAllMeasuredLv(_ sender: UIButton) {
        for settingUI in dict_settingUI.values {
            settingUI.tfMeasuredLv_L.text = ""
            settingUI.tfMeasuredLv_R.text = ""
        }
        
    }
    
    @IBAction func toggleSingal(_ sender: UIButton){
        // No tone playing at all, simply toggle on
        if(!player.isStarted()){
            _currentPlayFreq = sender.tag
            dict_settingUI[sender.tag]!.pbPlay.setTitle("On", for: .normal)
            player.startPlaying()
            
            // Update freq & vol
            player.updateFreq(_currentPlayFreq)
            player.updateVolume(dict_settingUI[sender.tag]!)
        }
            // Same tone, toggle it off
        else if(_currentPlayFreq == sender.tag){
            dict_settingUI[sender.tag]!.pbPlay.setTitle("Off", for: .normal)
            _currentPlayFreq = -1
            player.stopPlaying()
        }
            // Else tone, switch frequency
        else {
            dict_settingUI[_currentPlayFreq]!.pbPlay.setTitle("Off", for: .normal)
            dict_settingUI[sender.tag]!.pbPlay.setTitle("On", for: .normal)
            
            _currentPlayFreq = sender.tag
            
            // Update freq & vol
            player.updateFreq(_currentPlayFreq)
            player.updateVolume(dict_settingUI[sender.tag]!)
        }
    }
//------------------------------------------------------------------------------
// Initialize View
//------------------------------------------------------------------------------
    func initSettings(){
        player = CalibrationPlayer()
        // fetch all CalibrationSetting
        let request:NSFetchRequest<GlobalSetting> =
            GlobalSetting.fetchRequest()
        request.fetchLimit = 1
        
        do {
            globalSetting = try managedContext.fetch(request).first
            if(globalSetting.calibrationSetting != nil){
                currentSetting =
                    globalSetting.calibrationSetting ?? CalibrationSetting()
                
                loadSettingValues()
                lbCurrentSetting.text = currentSetting.name
                
            }
            else {
                lbCurrentSetting.text = "None"
                pbSaveCurrent.isEnabled = false
                pbDeleteCurrent.isEnabled = false
            }
            
        } catch let error as NSError{
            print("Could not fetch global setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    func setupStackview(_ sv: UIStackView!){
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .center
        sv.spacing = 20
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Get default frequencies from util setting files
        // and setup the UI
        setupStackview(svFreqLabels)
        setupStackview(svPlayButtons)
        setupStackview(svExpectedLv)
        setupStackview(svPresentationLv)
        setupStackview(svMeasuredLv_L)
        setupStackview(svMeasuredLv_R)
        
        for freq in ARRAY_DEFAULT_FREQ {
            let settingUI = SettingUI(freq: freq)
            settingUI.pbPlay.addTarget(self,
                                       action: #selector(toggleSingal(_:)),
                                       for: .touchUpInside)
            dict_settingUI[freq] = settingUI
            
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
        return array_settings.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return array_settings[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        
        _currentPickerIndex = row
    }
}

