
import UIKit
import RxSwift
import RxCocoa

class CalibrationViewController: UIViewController, Storyboardable {
    // MARK: UI Components
    @IBOutlet weak var returnButton: UIButton!
    
    @IBOutlet weak var updateVolumeButton: UIButton!
    @IBOutlet weak var clearMeasuredLevelButton: UIButton!
    @IBOutlet weak var clearAllValuesButton: UIButton!
    
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
    
    private var _calibrationSettingUiLookup: [Int: CalibrationSettingValueUi] = [:]
    
    private let loadSettingPickerView = UIPickerView(
        frame: CGRect(x: 0, y: 50, width: 260, height: 160)
    )
    
    // MARK: I/O for viewmodel
    private var _viewModel: CalibrationViewPresentable!
    var viewModelBuilder: CalibrationViewModel.ViewModelBuilder!
    
    private lazy var _relays = (
//        onSubmitCablirationSettingName: PublishRelay<String>(), // Relay for prompt
        onSaveNewSetting: PublishRelay<(String, [Int: CalibrationSettingValueUi])>(),
        onSaveCurrentSetting: PublishRelay<[Int: CalibrationSettingValueUi]>(),
        onLoadSelectedSetting: PublishRelay<String>(),
        onTogglePlayCalibration: PublishRelay<(Bool, CalibrationSettingValueUi)>()
    )
    
    private let _disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _viewModel = viewModelBuilder((
            onClickReturn: returnButton.rx.tap.asSignal(),
            onClickLoadOther: loadOtherButton.rx.tap.asSignal(),
            onClickDeleteCurrent: deleteCurrentButton.rx.tap.asSignal(),
            
            onSaveNewSetting: _relays.onSaveNewSetting.asSignal(),
            onSaveCurrentSetting: _relays.onSaveCurrentSetting.asSignal(),
            onLoadSelectedSetting: _relays.onLoadSelectedSetting.asSignal(),
            
            onTogglePlayCalibration: _relays.onTogglePlayCalibration.asSignal()
        ))
        
        setupView()
        setupBinding()
    }
}
// MARK: Methods
extension CalibrationViewController {
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
            let settingUi = CalibrationSettingUiFactory.shared.getElement(frequency: frequency)
            _calibrationSettingUiLookup[frequency] = settingUi
            
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
        
        bindTogglePlayCalibration()
        bindUpdateVolume()
        bindClearAllMeasuredLevelValues()
        bindClearAllValues()
        
        bindSaveAsNew()
        bindSaveToCurrent()
        bindLoadOther()
    }
    
    private func bindLoadAllUiValues() {
        func loadCurrentValues(calibrationSetting: CalibrationSetting?) {
            if let setting = calibrationSetting {
                currentSettingLabel.text = setting.name
                saveToCurrentButton.isEnabled = true
                
                _ = setting.values.map { values in
                    if let settingUi = _calibrationSettingUiLookup[values.frequency] {
                        settingUi.loadValues(from: values)
                    }
                }
            } else {
                currentSettingLabel.text = "None"
                saveToCurrentButton.isEnabled = false
            }
        }
        
        _viewModel.output.currentCalibrationSetting
            .drive(onNext: loadCurrentValues)
            .disposed(by: _disposeBag)
    }
    
    private func bindTogglePlayCalibration() {
        _ = self._calibrationSettingUiLookup.map { [_calibrationSettingUiLookup] (_, settingUi) in
            settingUi.playButton.rx.tap
                .withLatestFrom(_viewModel.output.currentPlayerFrequency) { $1 }
                .map {  currentFrequency in
                    if let ui = _calibrationSettingUiLookup[currentFrequency]{
                        ui.playButton.setTitle("Off", for: .normal)
                    }
                    if currentFrequency != settingUi.frequency{
                        settingUi.playButton.setTitle("On", for: .normal)
                    }
                    return (true, settingUi)
                }.bind(to: _relays.onTogglePlayCalibration)
                .disposed(by: _disposeBag)
        }
    }
    
    private func bindUpdateVolume() {
        updateVolumeButton.rx.tap
            .withLatestFrom(_viewModel.output.currentPlayerFrequency) { $1 }
            .filter { $0 > 0 }
            .map { [_calibrationSettingUiLookup] currentFrequency in
                return (false, _calibrationSettingUiLookup[currentFrequency]!)
            }.bind(to: _relays.onTogglePlayCalibration)
            .disposed(by: _disposeBag)
    }
    
    private func bindClearAllValues() {
        clearAllValuesButton.rx.tap
            .bind { [_calibrationSettingUiLookup] in
                _ = _calibrationSettingUiLookup.map {
                    $0.value.clearAllValues()
                }
            }.disposed(by: _disposeBag)
    }
    private func bindClearAllMeasuredLevelValues() {
        clearMeasuredLevelButton.rx.tap
            .bind { [_calibrationSettingUiLookup] in
                _ = _calibrationSettingUiLookup.map {
                    $0.value.clearMeasuredLevelValues()
                }
            }
            .disposed(by: _disposeBag)
    }
    
    private func bindSaveAsNew() {
        saveAsNewButton.rx.tap
            .bind { promptSettingNameInput() }
            .disposed(by: _disposeBag)
        
        func promptSettingNameInput() {
            let alertController = UIAlertController(
                title: "Save",
                message: "Please enter setting name:",
                preferredStyle: .alert
            )
            alertController.addTextField { $0.placeholder = "i.e. iPad1-EP1" }
            
            let actions = [
                UIAlertAction(title: "Confirm", style: .default) { _ in
                    if let settingName = alertController.textFields?[0].text {
                        confirmAction(settingName: settingName)
                    }
                },
                UIAlertAction(title: "Cancel", style: .cancel)
            ]
            actions.forEach(alertController.addAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        func confirmAction(settingName: String) {
            if(settingName.isNotEmpty) {
                let params = (settingName, _calibrationSettingUiLookup)
                _relays.onSaveNewSetting.accept(params)
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
    
    private func bindSaveToCurrent() {
        saveToCurrentButton.rx.tap
            .map { self._calibrationSettingUiLookup }
            .bind(to: _relays.onSaveCurrentSetting)
            .disposed(by: _disposeBag)
    }
    
    private func bindLoadOther() {
        let onSelectedSetting = BehaviorRelay<String>(value: "")
        let allCalibrationSettingNames = _viewModel.output.allCalibrationSettingNames.skip(1)
        
        loadSettingPickerView.rx.itemSelected.asDriver()
            .withLatestFrom(allCalibrationSettingNames) { $1[$0.row] }
            .drive(onSelectedSetting)
            .disposed(by: _disposeBag)
            
        allCalibrationSettingNames
            .drive(loadSettingPickerView.rx.itemTitles) { (row, element) in
                return element
            }.disposed(by: _disposeBag)
        
        allCalibrationSettingNames
            .drive(onNext: { allNames in
                if let defaultName = allNames.first{
                    onSelectedSetting.accept(defaultName)
                    promptPickerView()
                } else {
                    promptPickerViewError()
                }
            }).disposed(by: _disposeBag)

        func promptPickerView() {
            let alertController: UIAlertController! = UIAlertController(
                title: "Select a different setting",
                message: "\n\n\n\n\n\n\n\n\n",
                preferredStyle: .alert
            )
            let actions = [
                UIAlertAction(title: "Confirm", style: .default) { [_relays] _ in
                    _relays.onLoadSelectedSetting.accept(onSelectedSetting.value)
                },
                UIAlertAction(title: "Cancel", style: .cancel)
            ]
            actions.forEach(alertController.addAction)
            alertController.view.addSubview(loadSettingPickerView)
            present(alertController, animated: true, completion: nil)
        }
        
        func promptPickerViewError() {
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
