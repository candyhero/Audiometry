
import UIKit
import RxSwift
import RxCocoa

class TitleViewController: UIViewController, Storyboardable {
    // MARK: Properties
    var viewModel: TitleViewModel!
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var testButton: UIButton!
    @IBOutlet private weak var practiceButton: UIButton!
    @IBOutlet private weak var calibrationButton: UIButton!
    @IBOutlet private weak var resultButton: UIButton!
    
    override func viewDidLoad() {
        setupBindings()
        super.viewDidLoad()
    }
    
    private func setupBindings() {

        // Input
//        // How to error prompt from view model
//        errorPrompt(errorMsg: "There is no calibration setting selected!")
//
//        testButton.rx.tap
//            .bind(to: nil)
//            .disposed(by: disposeBag)
//
//        practiceButton.rx.tap
//            .bind(to: nil)
//            .disposed(by: disposeBag)
        
        calibrationButton.rx.tap
            .bind(to: viewModel.onClickCalibration)
            .disposed(by: disposeBag)
        
        resultButton.rx.tap
            .bind(to: viewModel.onClickResult)
            .disposed(by: disposeBag)
        
        // Output
        viewModel.showAlertMessage
            .subscribe(onNext: { [weak self] in
                self?.errorPrompt(errorMsg: $0)
            })
            .disposed(by: disposeBag)
    }
}

