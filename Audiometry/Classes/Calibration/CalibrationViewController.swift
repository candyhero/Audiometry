
import UIKit
import RxSwift
import RxCocoa
import RxRelay

class CalibrationViewController: UIViewController, Storyboardable {
    // MARK: UI Components
    @IBOutlet weak var returnButton: UIButton!
    
    @IBOutlet weak var setVolumeButton: UIButton!
    @IBOutlet weak var clearMeasuredLevelButton: UIButton!
    
    @IBOutlet weak var saveAsNewButton: UIButton!
    @IBOutlet weak var saveToCurrentButton: UIButton!
    @IBOutlet weak var loadOtherButton: UIButton!
    @IBOutlet weak var deleteCurrentButton: UIButton!
    
    @IBOutlet weak var currentSettingLabel: UILabel!
    
    @IBOutlet weak var expectedLevelStackView: UIStackView!
    @IBOutlet weak var presentationLevelStackView: UIStackView!
    @IBOutlet weak var leftMesauredLevelStackView: UIStackView!
    @IBOutlet weak var rightMeasuredLevelStackView: UIStackView!
    
    @IBOutlet weak var frequencyStackView: UIStackView!
    @IBOutlet weak var playButtonStackView: UIStackView!
    
    private var _calibrationSettingUI: [Int: CalibrationSettingValueUI] = [:]
    
    let loadSettingPickerView = UIPickerView(
        frame: CGRect(x: 0, y: 50, width: 260, height: 160)
    )
    
    // MARK: I/O for viewmodel
    private var viewModel: CalibrationViewPresentable!
    var viewModelBuilder: CalibrationViewModel.ViewModelBuilder!
    
    private lazy var relays = (
//        onSubmitCablirationSettingName: PublishRelay<String>(), // Relay for prompt
        onSaveNewSetting: PublishRelay<(String, [CalibrationSettingValueUI])>(),
        onSaveCurrentSetting: PublishRelay<[CalibrationSettingValueUI]>(),
        onLoadSelectedSetting: PublishRelay<String>()
    )
    
    private let disposeBag = DisposeBag()
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = viewModelBuilder((
            onClickReturn: returnButton.rx.tap.asSignal(),
            onClickLoadOther: loadOtherButton.rx.tap.asSignal(),
            onClickDeleteCurrent: deleteCurrentButton.rx.tap.asSignal(),
            
            onSaveNewSetting: relays.onSaveNewSetting.asSignal(),
            onSaveCurrentSetting: relays.onSaveCurrentSetting.asSignal(),
            onLoadSelectedSetting: relays.onLoadSelectedSetting.asSignal()
        ))
        
        setupView()
        setupBinding()
    }
    
    private func setupView() {
        let stackviews = [
            frequencyStackView,
            playButtonStackView,
            expectedLevelStackView,
            presentationLevelStackView,
            leftMesauredLevelStackView,
            rightMeasuredLevelStackView
        ]
        
        _ = stackviews.map { sv in
            sv?.axis = .horizontal
            sv?.distribution = .fillEqually
            sv?.alignment = .center
            sv?.spacing = 20
        }
        
        _ = DEFAULT_FREQ.map { frequency in
            let settingUi = CalibrationSettingUIFactory.shared.getElement(frequency: frequency)
            _calibrationSettingUI[frequency] = settingUi
            
            expectedLevelStackView.addArrangedSubview(settingUi.expectedLevelTextField)
            presentationLevelStackView.addArrangedSubview(settingUi.presentationLevelTextField)
            leftMesauredLevelStackView.addArrangedSubview(settingUi.leftMeasuredLevelTextField)
            rightMeasuredLevelStackView.addArrangedSubview(settingUi.rightMeasuredLevelTextField)
            
            frequencyStackView.addArrangedSubview(settingUi.frequencyLabel)
            playButtonStackView.addArrangedSubview(settingUi.playButton)
        }
    }
    
    private func setupBinding() {
        bindSaveAsNew()
        bindSaveToCurrent()
        bindLoadOther()
        
        _ = viewModel.output.currentCalibrationSetting.drive(
            onNext: { [weak self] calibrationSetting in
                if let setting = calibrationSetting{
                    self?.currentSettingLabel.text = setting.name
                    self?.saveToCurrentButton.isEnabled = true
                } else {
                    self?.currentSettingLabel.text = "None"
                    self?.saveToCurrentButton.isEnabled = false
                }
            }
        ).disposed(by: disposeBag)
    }
    
    private func bindSaveAsNew() {
        _ = saveAsNewButton.rx.tap.bind{ [weak self] _ in
            promptSettingNameInputPrompt()
        }.disposed(by: disposeBag)
        
        func promptSettingNameInputPrompt(){
            // Prompt for user to input setting name
            let alertController = UIAlertController(
                title: "Save",
                message: "Please enter setting name:",
                preferredStyle: .alert
            )
            let actions = [
                UIAlertAction(title: "Confirm", style: .default){ _ in
                    if let settingName = alertController.textFields?[0].text {
                        confirmAction(settingName: settingName)
                    }
                },
                UIAlertAction(title: "Cancel", style: .cancel)
            ]
            actions.forEach(alertController.addAction)
            alertController.addTextField { $0.placeholder = "i.e. iPad1-EP1" }
            self.present(alertController, animated: true, completion: nil)
        }
        
        func confirmAction(settingName: String){
            if(settingName.isNotEmpty) {
                let params = (settingName, Array(_calibrationSettingUI.values))
                self.relays.onSaveNewSetting.accept(params)
            } else {
                promptSettingNameInputError()
            }
        }
        
        func promptSettingNameInputError() {
            let alertController = UIAlertController(
                title: "Error",
                message: "Setting name cannot be empty!",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    private func bindSaveToCurrent(){
        _ = saveToCurrentButton.rx.tap.bind{ [weak self] _ in
            if let settingUIs = self?._calibrationSettingUI.values {
                self?.relays.onSaveCurrentSetting.accept(Array(settingUIs))
            }
        }
    }
    
    private func bindLoadOther(){
        _ = viewModel.output.allCalibrationSettingNames
            .drive(loadSettingPickerView.rx.itemTitles){ (row, element) in
                return element
            }
            .disposed(by: disposeBag)
        
        let onSelectedSetting = BehaviorRelay<String>(value: "")
        
        _ = Driver.combineLatest(
            loadSettingPickerView.rx.itemSelected.asDriver(),
            viewModel.output.allCalibrationSettingNames
        ).drive(onNext: {(selected, allSettingNames) in
            onSelectedSetting.accept(allSettingNames[selected.row]) // selected.row not updated when triggerred
        }).disposed(by: disposeBag)
        
        _ = viewModel.output.allCalibrationSettingNames.skip(1)
            .drive(onNext: { allSettingNames in
                if let defaultSelectedSetting = allSettingNames.first{
                    onSelectedSetting.accept(defaultSelectedSetting)
                    promptPickerView()
                } else {
                    promptPickerViewError()
                }
            }).disposed(by: disposeBag)
        
        func promptPickerViewError(){
            let alertController = UIAlertController(
                title: "Error",
                message: "There is no other calibration settings!",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true, completion: nil)
        }
        
        func promptPickerView(){
            let alertController: UIAlertController! = UIAlertController(
                title: "Select a different setting",
                message: "\n\n\n\n\n\n\n\n\n",
                preferredStyle: .alert
            )
            let actions = [
                UIAlertAction(title: "Confirm", style: .default){ [weak self] _ in
                    self?.relays.onLoadSelectedSetting.accept(onSelectedSetting.value)
                },
                UIAlertAction(title: "Cancel", style: .cancel)
            ]
            actions.forEach(alertController.addAction)
            alertController.view.addSubview(loadSettingPickerView)
            present(alertController, animated: true, completion: nil)
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
