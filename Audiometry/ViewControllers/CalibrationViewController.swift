
import UIKit
import CoreData

class CalibrationViewController: UIViewController, Storyboarded {

    // MARK: Properties
    weak var coordinator: CalibrationCoordinator!
    private var currentSetting: CalibrationSetting!
    private var array_settings: [CalibrationSetting] = []
    
    private var player: CalibrationPlayer!
    private var _currentPickerIndex: Int = 0;
    private var _currentPlayFreq: Int = -1;
    
    // MARK: UI Components
    private var dict_settingUI: [Int: CalibrationSettingUI] = [:]
    
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
        currentSetting = coordinator.getCurrentCalibrationSetting()
        if(currentSetting == nil){
            lbCurrentSetting.text = "None"
            pbSaveCurrent.isEnabled = false
        } else {
            lbCurrentSetting.text = currentSetting.name
            loadCurrentSettingValues()
            pbSaveCurrent.isEnabled = true
        }
    }
    
    @IBAction func back(_ sender: Any) {
        coordinator.back()
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
            dict_settingUI[freq] = settingUI
            
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
        currentSetting = coordinator.saveCalibrationSetting(settingName, ui: dict_settingUI)
        lbCurrentSetting.text = settingName
        pbSaveCurrent.isEnabled = true
        pbDeleteCurrent.isEnabled = true
    }
    
    @IBAction func updateCurrentSetting(_ sender: UIButton) {
        currentSetting.timestamp = Date()
        let allValues = currentSetting.getDictionary()
        
        for (freq, settingUI) in dict_settingUI {
            settingUI.extractValuesInto(allValues[freq]!)
        }
        coordinator.updateCalibrationSetting(currentSetting)
    }
    
    @IBAction func loadOtherSetting(_ sender: UIButton) {
        array_settings = coordinator.fetchAllCalibrationSettings()
        
        _currentPickerIndex = 0
        pickerPrompt(confirmFunction: {()->Void in
            let picked = self.array_settings[self._currentPickerIndex]
            self.coordinator.updateCalibrationSetting(picked)
            self.currentSetting = picked
            self.loadCurrentSettingValues()
            
            self.pbSaveCurrent.isEnabled = true
            self.pbDeleteCurrent.isEnabled = true
            
            print("Done Loading", self.currentSetting.name!)
        }, uiCtrl: self)
    }
    
    func loadCurrentSettingValues() {
        lbCurrentSetting.text = currentSetting.name ?? "NULL"
        
        // Load setting name
        for settingValues in currentSetting.values ?? [] {
            let values = settingValues as! CalibrationSettingValues
            dict_settingUI[Int(values.frequency)]?.updateDisplayValues(values)
        }
        pbSaveCurrent.isEnabled = true
    }
    
    @IBAction func deleteCurrentSetting(_ sender: UIButton) {
        coordinator.deleteCalibrationSetting(currentSetting)
        currentSetting = nil
        lbCurrentSetting.text = "None"
        
        pbSaveCurrent.isEnabled = false
        pbDeleteCurrent.isEnabled = false
    }
    
    // MARK:
    @IBAction func loadDefaultPresentationLv(_ sender: UIButton) {
        for settingUI in dict_settingUI.values {
            settingUI.tfPresentationLv.text = String(_DB_DEFAULT)
        }
    }
    
    @IBAction func clearAllMeasuredLv(_ sender: UIButton) {
        for settingUI in dict_settingUI.values {
            settingUI.tfMeasuredLv_L.text = ""
            settingUI.tfMeasuredLv_R.text = ""
        }
        
    }
    
    @IBAction func toggleSingal(_ sender: UIButton) {
        // No tone playing at all, simply toggle on
        if(!player.isStarted()) {
            _currentPlayFreq = sender.tag
            dict_settingUI[sender.tag]!.pbPlay.setTitle("On", for: .normal)
            player.startPlaying()
            
            // Update freq & vol
            player.updateFreq(_currentPlayFreq)
            player.updateVolume(dict_settingUI[sender.tag]!)
        }
            // Same tone, toggle it off
        else if(_currentPlayFreq == sender.tag) {
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
