
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
        onLoadSelectedSetting: PublishRelay<String>(),
        onTogglePlayCalibration: PublishRelay<Int>()
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
            onLoadSelectedSetting: relays.onLoadSelectedSetting.asSignal(),
            
            onTogglePlayCalibration: relays.onTogglePlayCalibration.asSignal()
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
        bindLoadAllUiValues()
        bindClearAllMeasuredLevelValues()
        bindTogglePlayCalibration()
        bindSaveAsNew()
        bindSaveToCurrent()
        bindLoadOther()
    }
    
    private func bindLoadAllUiValues(){
        func loadCurrentValues(calibrationSetting: CalibrationSetting?){
            if let setting = calibrationSetting {
                currentSettingLabel.text = setting.name
                saveToCurrentButton.isEnabled = true
                
                _ = setting.values?.array.map{ v in
                    if let values = v as? CalibrationSettingValues,
                        let ui = _calibrationSettingUI[Int(values.frequency)] {
                        ui.loadValuesFrom(values: values)
                    }
                }
            } else {
                currentSettingLabel.text = "None"
                saveToCurrentButton.isEnabled = false
            }
        }
        _ = viewModel.output.currentCalibrationSetting
            .drive(onNext: loadCurrentValues)
            .disposed(by: disposeBag)
    }
    
    private func bindClearAllMeasuredLevelValues(){
        _ = clearMeasuredLevelButton.rx.tap
            .bind{clearAllMeasuredLevelValues()}
            .disposed(by: disposeBag)
        
        func clearAllMeasuredLevelValues(){
            for (_, ui) in _calibrationSettingUI {
                ui.clearMeasuredLevelValues()
            }
        }
    }
    
    private func bindTogglePlayCalibration(){
        _ = _calibrationSettingUI.map{ (_, ui) in
            ui.playButton.rx.tap
                .bind{ togglePlayCalibration(frequency: ui.frequency) }
                .disposed(by: disposeBag)
        }
        
        func togglePlayCalibration(frequency: Int){
            relays.onTogglePlayCalibration.accept(frequency)
        }
        
        func togglePlayCalibrationUi(){
            
        }
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
    }
    
    private func bindSaveAsNew() {
        _ = saveAsNewButton.rx.tap
            .bind{ promptSettingNameInputPrompt() }
            .disposed(by: disposeBag)
        
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
                relays.onSaveNewSetting.accept(params)
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
        _ = saveToCurrentButton.rx.tap
            .bind{ saveToCurrent() }
            .disposed(by: disposeBag)
        
        func saveToCurrent(){
            let uis = Array(_calibrationSettingUI.values)
            relays.onSaveCurrentSetting.accept(uis)
        }
    }
    
    private func bindLoadOther(){
        let allSettingNames = BehaviorRelay<[String]>(value: [])
        let onSelectedSetting = BehaviorRelay<String>(value: "")
        
        _ = viewModel.output.allCalibrationSettingNames
            .drive(loadSettingPickerView.rx.itemTitles){ (row, element) in
                return element
            }.disposed(by: disposeBag)
        
        _ = viewModel.output.allCalibrationSettingNames
            .drive(allSettingNames)
            .disposed(by: disposeBag)
        
        _ = loadSettingPickerView.rx.itemSelected.asDriver()
            .map{ allSettingNames.value[$0.row] }
            .drive(onSelectedSetting)
            .disposed(by: disposeBag)
        
        func promptPicker(allSettingNames: [String]){
            if let defaultSelectedSetting = allSettingNames.first{
                onSelectedSetting.accept(defaultSelectedSetting)
                promptPickerView()
            } else {
                promptPickerViewError()
            }
        }
        _ = viewModel.output.allCalibrationSettingNames.skip(1)
            .drive(onNext: promptPicker)
            .disposed(by: disposeBag)
        
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
        
        func promptPickerViewError(){
            let alertController = UIAlertController(
                title: "Error",
                message: "There is no other calibration settings!",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true, completion: nil)
        }
    }
}
