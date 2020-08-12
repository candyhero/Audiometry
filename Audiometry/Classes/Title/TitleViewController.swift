
import UIKit
import RxSwift
import RxCocoa

class TitleViewController: UIViewController, Storyboardable {
    // MARK: UI Components
    @IBOutlet private weak var testButton: UIButton!
    @IBOutlet private weak var practiceButton: UIButton!
    @IBOutlet private weak var calibrationButton: UIButton!
    @IBOutlet private weak var resultButton: UIButton!
    
    // MARK: Properties
    private var _viewModel: TitleViewPresentable!
    var viewModelBuilder: TitleViewPresentable.ViewModelBuilder!
    
    private let _disposeBag = DisposeBag()
    
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _viewModel = viewModelBuilder((
            onClickTest: testButton.rx.tap.asSignal(),
            onClickPractice: practiceButton.rx.tap.asSignal(),
            onClickCalibration: calibrationButton.rx.tap.asSignal(),
            onClickResult: resultButton.rx.tap.asSignal()
        ))
        
        setupBinding()
    }
}

extension TitleViewController {
    private func setupBinding() {
        _viewModel.output.validateCalibrationSetting
            .skip(1)
            .filter{ _ in true }
            .drive(onNext: { _ in
                promptError(errorMessage: "There is no calibration setting!")
            })
            .disposed(by: _disposeBag)
        
        _viewModel.output.validatePatientProfile
            .skip(1)
            .filter{ _ in true }
            .drive(onNext: { _ in
                promptError(errorMessage: "There is no patient profiles!")
            })
            .disposed(by: _disposeBag)
        
        
        func promptError(errorMessage: String) {
            let alertController = UIAlertController(
                title: "Error",
                message: errorMessage,
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true, completion: nil)
        }
    }
}

