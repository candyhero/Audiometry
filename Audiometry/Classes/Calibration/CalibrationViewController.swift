
import UIKit
import RxSwift
import RxRelay

class CalibrationViewController: UIViewController, Storyboardable {
    // MARK: UI Components
    @IBOutlet weak var returnButton: UIButton!
    
    @IBOutlet weak var setVolumeButton: UIButton!
    @IBOutlet weak var clearMeasuredLevelButton: UIButton!
    
    @IBOutlet weak var saveAsNewButton: UIButton!
    @IBOutlet weak var saveCurrentButton: UIButton!
    @IBOutlet weak var loadOtherButton: UIButton!
    @IBOutlet weak var deleteCurrentButton: UIButton!
    
    @IBOutlet weak var currentSettingLabel: UILabel!
    
    // MARK: Inputs
    private var _settingUIs: [Int: CalibrationSettingUi] = [:]
    
    @IBOutlet weak var expectedLevelStackView: UIStackView!
    @IBOutlet weak var presentationLevelStackView: UIStackView!
    @IBOutlet weak var leftMesauredLevelStackView: UIStackView!
    @IBOutlet weak var rightMeasuredLevelStackView: UIStackView!
    
    @IBOutlet weak var frequencyStackView: UIStackView!
    @IBOutlet weak var playButtonStackView: UIStackView!
    
    // MARK: Properties
    private var _pickerIndex: Int = 0;
    private var _playingFrequency: Int = -1;
    
    private var viewModel: CalibrationViewPresentable!
    var viewModelBuilder: CalibrationViewModel.ViewModelBuilder!
    
    private var calibrationSettingRelay = PublishRelay<CalibrationSetting>()
    
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupBinding()
        
        viewModel = viewModelBuilder((
            onClickReturn: returnButton.rx.tap.asSignal(),
//            onClickSaveAsNew: saveAsNewButton.rx.tap.asSignal(),
            calibrationSetting: calibrationSettingRelay.asObservable()
        ))
        
//        let currentSetting = coordinator.getCalibrationSetting()
//        if(currentSetting == nil){
//            lbCurrentSetting.text = "None"
//            pbSaveCurrent.isEnabled = false
//        } else {
//            lbCurrentSetting.text = currentSetting!.name
//            loadCurrentSettingValues(currentSetting!)
//            pbSaveCurrent.isEnabled = true
//        }
    }
    
    // MARK:
    private func setupBinding() {
        _ = saveAsNewButton.rx.tap.bind{[weak self] _ in
            // Prompt for user to input setting name
            let alertController = UIAlertController(title: "Save",
                                              message: "Please enter setting name:",
                                              preferredStyle: .alert)
            
            let actions = [
                UIAlertAction(title: "Confirm", style: .default){ _ in
                    if let field = alertController.textFields?[0] {
                        let setting = CalibrationService.shared.createNew(name: field.text!)
                        self?.calibrationSettingRelay.accept(setting)
                    }
                },
                UIAlertAction(title: "Cancel", style: .cancel)
            ]
            actions.forEach(alertController.addAction)
            
            alertController.addTextField { (textField) in
                textField.placeholder = "i.e. iPad1-EP1"
            }
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func setupView() {
        currentSettingLabel.text = "None"
        saveCurrentButton.isEnabled = false
        
        let stackviews = [frequencyStackView,
                          playButtonStackView,
                          expectedLevelStackView,
                          presentationLevelStackView,
                          leftMesauredLevelStackView,
                          rightMeasuredLevelStackView]
        
        _ = stackviews.map { sv in
            sv?.axis = .horizontal
            sv?.distribution = .fillEqually
            sv?.alignment = .center
            sv?.spacing = 20
        }
        
        _ = DEFAULT_FREQ.map { frequency in
            let settingUi = CalibrationSettingUiFactory.shared.getElement(frequency: frequency)
            _settingUIs[frequency] = settingUi
            
            expectedLevelStackView.addArrangedSubview(settingUi.expectedLvTextField)
            presentationLevelStackView.addArrangedSubview(settingUi.presentationLvTextField)
            leftMesauredLevelStackView.addArrangedSubview(settingUi.leftMeasuredLvTextField)
            rightMeasuredLevelStackView.addArrangedSubview(settingUi.rightMeasuredLvTextField)
            
            frequencyStackView.addArrangedSubview(settingUi.frequencyLabel)
            playButtonStackView.addArrangedSubview(settingUi.playButton)
        }
    }
    
//
//    // MARK: Calibration CRUD
//
//    @IBAction func updateCurrentSetting(_ sender: UIButton) {
//        coordinator.updateCalibrationSetting(ui: _settingUIs)
//    }
//
//    @IBAction func loadOtherSetting(_ sender: UIButton) {
//        _pickerIndex = 0
//        coordinator.fetchAllCalibrationSettings()
//
//        pickerPrompt(confirmFunction: { ()->Void in
//            let picked = self.coordinator.setCalibrationSettingByPicker(self._pickerIndex)
//            self.loadCurrentSettingValues(picked!)
//
//            self.pbSaveCurrent.isEnabled = true
//            self.pbDeleteCurrent.isEnabled = true
//        })
//    }
//
//    func loadCurrentSettingValues(_ setting: CalibrationSetting) {
//        lbCurrentSetting.text = setting.name ?? "NULL"
//
//        for settingValues in setting.values ?? [] {
//            let values = settingValues as! CalibrationSettingValues
//            _settingUIs[Int(values.frequency)]?.updateDisplayValues(values)
//        }
//        pbSaveCurrent.isEnabled = true
//    }
//
//    @IBAction func deleteCurrentSetting(_ sender: UIButton) {
//        coordinator.deleteCalibrationSetting()
//        lbCurrentSetting.text = "None"
//
//        pbSaveCurrent.isEnabled = false
//        pbDeleteCurrent.isEnabled = false
//    }
//
//    // MARK:
//    @IBAction func loadDefaultPresentationLv(_ sender: UIButton) {
//        for settingUI in _settingUIs.values {
//            settingUI.tfPresentationLv.text = String(DEFAULT_CALIBRATION_PLAYER_DB)
//        }
//    }
//
//    @IBAction func clearAllMeasuredLv(_ sender: UIButton) {
//        for settingUI in _settingUIs.values {
//            settingUI.tfMeasuredLv_L.text = ""
//            settingUI.tfMeasuredLv_R.text = ""
//        }
//
//    }
//
//    @IBAction func toggleSingal(_ sender: UIButton) {
//        // No tone playing at all, simply toggle on
//        let freq = sender.tag
//        let ui = _settingUIs[freq]!
//
//        let newFreq = coordinator.togglePlayer(_playingFrequency, freq, ui)
//
//        if(newFreq == -1) {
//            ui.pbPlay.setTitle("Off", for: .normal)
//        }
//        else if(_playingFrequency == -1) {
//            ui.pbPlay.setTitle("On", for: .normal)
//        }
//        else {
//            let uiOff = _settingUIs[_playingFrequency]!
//            uiOff.pbPlay.setTitle("Off", for: .normal)
//            ui.pbPlay.setTitle("On", for: .normal)
//        }
//
//        _playingFrequency = newFreq
//    }
}
//
//extension CalibrationViewController: UIPickerViewDelegate, UIPickerViewDataSource{
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView,
//                    numberOfRowsInComponent component: Int) -> Int {
//        let settings = coordinator.getAllCalibrationSettings()
//        return settings.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
//                    forComponent component: Int) -> String? {
//        let settings = coordinator.getAllCalibrationSettings()
//        return settings[row].name
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
//                    inComponent component: Int) {
//        _pickerIndex = row
//    }
//}
