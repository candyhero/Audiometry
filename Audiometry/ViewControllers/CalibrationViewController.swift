
import UIKit

class CalibrationViewController: UIViewController, Storyboarded {
    // MARK: Properties
    let coordinator = AppDelegate.calibrationCoordinator

    private var _pickerIndex: Int = 0;
    private var _playingFrequency: Int = -1;
    
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
        let currentSetting = coordinator.getCalibrationSetting()
        if(currentSetting == nil){
            lbCurrentSetting.text = "None"
            pbSaveCurrent.isEnabled = false
        } else {
            lbCurrentSetting.text = currentSetting!.name
            loadCurrentSettingValues(currentSetting!)
            pbSaveCurrent.isEnabled = true
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
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
        
        for freq in DEFAULT_FREQ {
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
                    confirmFunction: saveSetting)
    }
    
    func saveSetting(_ settingName: String) {
        coordinator.saveCalibrationSetting(settingName, ui: _settingUIs)
        lbCurrentSetting.text = settingName
        pbSaveCurrent.isEnabled = true
        pbDeleteCurrent.isEnabled = true
    }
    
    @IBAction func updateCurrentSetting(_ sender: UIButton) {
        coordinator.updateCalibrationSetting(ui: _settingUIs)
    }
    
    @IBAction func loadOtherSetting(_ sender: UIButton) {
        _pickerIndex = 0
        coordinator.fetchAllCalibrationSettings()

        pickerPrompt(confirmFunction: { ()->Void in
            let picked = self.coordinator.setCalibrationSettingByPicker(self._pickerIndex)
            self.loadCurrentSettingValues(picked!)
            
            self.pbSaveCurrent.isEnabled = true
            self.pbDeleteCurrent.isEnabled = true
        })
    }
    
    func loadCurrentSettingValues(_ setting: CalibrationSetting) {
        lbCurrentSetting.text = setting.name ?? "NULL"

        for settingValues in setting.values ?? [] {
            let values = settingValues as! CalibrationSettingValues
            _settingUIs[Int(values.frequency)]?.updateDisplayValues(values)
        }
        pbSaveCurrent.isEnabled = true
    }
    
    @IBAction func deleteCurrentSetting(_ sender: UIButton) {
        coordinator.deleteCalibrationSetting()
        lbCurrentSetting.text = "None"
        
        pbSaveCurrent.isEnabled = false
        pbDeleteCurrent.isEnabled = false
    }
    
    // MARK:
    @IBAction func loadDefaultPresentationLv(_ sender: UIButton) {
        for settingUI in _settingUIs.values {
            settingUI.tfPresentationLv.text = String(DEFAULT_CALIBRATION_PLAYER_DB)
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
        let freq = sender.tag
        let ui = _settingUIs[freq]!

        let newFreq = coordinator.togglePlayer(_playingFrequency, freq, ui)

        if(newFreq == -1) {
            ui.pbPlay.setTitle("Off", for: .normal)
        }
        else if(_playingFrequency == -1) {
            ui.pbPlay.setTitle("On", for: .normal)
        }
        else {
            let uiOff = _settingUIs[_playingFrequency]!
            uiOff.pbPlay.setTitle("Off", for: .normal)
            ui.pbPlay.setTitle("On", for: .normal)
        }

        _playingFrequency = newFreq
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
        let settings = coordinator.getAllCalibrationSettings()
        return settings.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        let settings = coordinator.getAllCalibrationSettings()
        return settings[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        _pickerIndex = row
    }
}
