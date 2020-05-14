
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
    private var viewModel: TitleViewPresentable!
    var viewModelBuilder: TitleViewPresentable.ViewModelBuilder!
    
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = viewModelBuilder((
            onClickTest: testButton.rx.tap.asSignal(),
            onClickPractice: practiceButton.rx.tap.asSignal(),
            onClickCalibration: calibrationButton.rx.tap.asSignal(),
            onClickResult: resultButton.rx.tap.asSignal()
        ))
    }
}

