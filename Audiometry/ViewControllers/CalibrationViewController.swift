
import UIKit

class CalibrationViewController: UIViewController, Storyboarded {

    // MARK: Properties
    private let _coordinator = AppDelegate.calibrationCoordinator
    
    private var _currentSetting: CalibrationSetting!
    private var _settings: [CalibrationSetting] = []
    
    private var _player: CalibrationPlayer!
    private var _currentPickerIndex: Int = 0;
    private var _currentPlayFreq: Int = -1;
    
    // MARK: UI Components
    private var _settingUIs: [Int: CalibrationSettingUI] = [:]
    
    @IBOutlet weak var svFreqLabels: UIStackView!
    @IBOutlet weak var svPlayButtons: UIStackView!
    
    @IBOutlet weak var svExpectedLv: UIStackView!
    @IBOutlet weak var svPresentationLv: UIStackView!
    @IBOutlet weak var svMeasuredLv_L: UIStackView!
    @IBOutlet weak var svMeasuredLv_R: UIStackView!
    
    @IBOutlet var pbSaveCurrent: UIButton!
    @IBOutlet var pbLoadOther: UIButton!
    @IBOutlet var pbDeleteCurrent: UIButton!
    
    @IBOutlet var lbCurrentSetting: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
//        player = CalibrationPlayer()
        _currentSetting = _coordinator.getCurrentCalibrationSetting()
        if(_currentSetting == nil){
            lbCurrentSetting.text = "None"
            pbSaveCurrent.isEnabled = false
        } else {
            lbCurrentSetting.text = _currentSetting.name
            loadCurrentSettingValues()
            pbSaveCurrent.isEnabled = true
        }
    }
    
    @IBAction func back(_ sender: Any) {
        _coordinator.back()
    }
    
    // MARK: Initialize ViewController
    func initUI() {
        setupStackview(svFreqLabels)
        setupStackview(svPlayButtons)
        setupStackview(svExpectedLv)
        setupStackview(svPresentationLv)
        setupStackview(svMeasuredLv_L)
        setupStackview(svMeasuredLv_R)
        
        for freq in ARRAY_DEFAULT_FREQ {
            let settingUI = CalibrationSettingUI(freq)
            settingUI.pbPlay.addTarget(self,
                                       action: #selector(toggleSingal(_:)),
                                       for: .touchUpInside)
            _settingUIs[freq] = settingUI
            
            // Displaying in subview
            svFreqLabels.addArrangedSubview(settingUI.lbFreq)
            svPlayButtons.addArrangedSubview(settingUI.pbPlay)
            svExpectedLv.addArrangedSubview(settingUI.tfExpectedLv)
            svPresentationLv.addArrangedSubview(settingUI.tfPresentationLv)
            svMeasuredLv_L.addArrangedSubview(settingUI.tfMeasuredLv_L)
            svMeasuredLv_R.addArrangedSubview(settingUI.tfMeasuredLv_R)
        }
    }
    
    func setupStackview(_ sv: UIStackView!) {
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .center
        sv.spacing = 20
    }
    
    // MARK: Calibration CRUD
    @IBAction func saveAsNewSetting(_ sender: UIButton) {
        inputPrompt(promptMsg: "Please enter setting name:",
                    errorMsg: "Setting name cannot be empty!",
                    fieldMsg: "i.e. iPad1-EP1",
                    confirmFunction: saveSetting,
                    uiCtrl: self)
    }
    
    func saveSetting(_ settingName: String) {
        _currentSetting = _coordinator.saveCalibrationSetting(settingName, ui: _settingUIs)
        lbCurrentSetting.text = settingName
        pbSaveCurrent.isEnabled = true
        pbDeleteCurrent.isEnabled = true
    }
    
    @IBAction func updateCurrentSetting(_ sender: UIButton) {
        _currentSetting.timestamp = Date()
        let allValues = _currentSetting.getDictionary()
        
        for (freq, settingUI) in _settingUIs {
            settingUI.extractValuesInto(allValues[freq]!)
        }
        _coordinator.updateCalibrationSetting(_currentSetting)
    }
    
    @IBAction func loadOtherSetting(_ sender: UIButton) {
        _settings = _coordinator.fetchAllCalibrationSettings()
        
        _currentPickerIndex = 0
        pickerPrompt(confirmFunction: {()->Void in
            let picked = self._settings[self._currentPickerIndex]
            self._coordinator.updateCalibrationSetting(picked)
            self._currentSetting = picked
            self.loadCurrentSettingValues()
            
            self.pbSaveCurrent.isEnabled = true
            self.pbDeleteCurrent.isEnabled = true
            
            print("Done Loading", self._currentSetting.name!)
        }, uiCtrl: self)
    }
    
    func loadCurrentSettingValues() {
        lbCurrentSetting.text = _currentSetting.name ?? "NULL"
        
        // Load setting name
        for settingValues in _currentSetting.values ?? [] {
            let values = settingValues as! CalibrationSettingValues
            _settingUIs[Int(values.frequency)]?.updateDisplayValues(values)
        }
        pbSaveCurrent.isEnabled = true
    }
    
    @IBAction func deleteCurrentSetting(_ sender: UIButton) {
        _coordinator.deleteCalibrationSetting(_currentSetting)
        _currentSetting = nil
        lbCurrentSetting.text = "None"
        
        pbSaveCurrent.isEnabled = false
        pbDeleteCurrent.isEnabled = false
    }
    
    // MARK:
    @IBAction func loadDefaultPresentationLv(_ sender: UIButton) {
        for settingUI in _settingUIs.values {
            settingUI.tfPresentationLv.text = String(_DB_DEFAULT)
        }
    }
    
    @IBAction func clearAllMeasuredLv(_ sender: UIButton) {
        for settingUI in _settingUIs.values {
            settingUI.tfMeasuredLv_L.text = ""
            settingUI.tfMeasuredLv_R.text = ""
        }
        
    }
    
    @IBAction func toggleSingal(_ sender: UIButton) {
        // No tone playing at all, simply toggle on
        if(!_player.isStarted()) {
            _currentPlayFreq = sender.tag
            _settingUIs[sender.tag]!.pbPlay.setTitle("On", for: .normal)
            _player.startPlaying()
            
            // Update freq & vol
            _player.updateFreq(_currentPlayFreq)
            _player.updateVolume(_settingUIs[sender.tag]!)
        }
            // Same tone, toggle it off
        else if(_currentPlayFreq == sender.tag) {
            _settingUIs[sender.tag]!.pbPlay.setTitle("Off", for: .normal)
            _currentPlayFreq = -1
            _player.stopPlaying()
        }
            // Else tone, switch frequency
        else {
            _settingUIs[_currentPlayFreq]!.pbPlay.setTitle("Off", for: .normal)
            _settingUIs[sender.tag]!.pbPlay.setTitle("On", for: .normal)
            
            _currentPlayFreq = sender.tag
            
            // Update freq & vol
            _player.updateFreq(_currentPlayFreq)
            _player.updateVolume(_settingUIs[sender.tag]!)
        }
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
