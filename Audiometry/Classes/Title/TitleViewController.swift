
import UIKit
import RxSwift
import RxCocoa

class TitleViewController: UIViewController, Storyboarded {
    // MARK: Properties
    var viewModel: TitleViewModel!
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var pbStart: UIButton!
    @IBOutlet weak var pbPractice: UIButton!
    @IBOutlet weak var pbCalibration: UIButton!
    @IBOutlet weak var pbResult: UIButton!
    
    override func viewDidLoad() {
        setupBindings()
        super.viewDidLoad()
    }

    
    private func setupBindings() {
        pbCalibration.rx.tap
            .bind(to: viewModel.clickCalibration)
            .disposed(by: disposeBag)
    }
//    // MARK:
//    private let _coordinator = AppDelegate.mainCoordinator
//    private let _patientProfileRepo = PatientProfileRepo.repo
//
//    // MARK:
//    override func viewDidLoad() {
//        print(String(describing: Self.self))
//        super.viewDidLoad()
//    }
//
//    // MARK: Controller functions
//    @IBAction func showCalibrationView(_ sender: UIButton) {
//        _coordinator.showCalibrationView(sender: sender)
//    }
//
//    @IBAction func prepareTest(_ sender: UIButton) {
//        if _coordinator.getCurrentCalibrationSetting() == nil{
//            errorPrompt(errorMsg: "There is no calibration setting selected!")
//            return
//        }
//        _coordinator.showTestProtocolView(sender: sender, isPractice: false)
//    }
//
//    @IBAction func preparePractice(_ sender: UIButton) {
//        if _coordinator.getCurrentCalibrationSetting() == nil{
//            errorPrompt(errorMsg: "There is no calibration setting selected!")
//            return
//        }
//        _coordinator.showTestProtocolView(sender: sender, isPractice: true)
//    }
//
//    @IBAction func showResultView(_ sender: UIButton) {
//        do {
//            if try !_patientProfileRepo.validateAnyPatientProfiles(){
//                errorPrompt(errorMsg: "There is no result!")
//                return
//            }
//        } catch let error as NSError {
//            print("[Error] There is no patient profileg.")
//            print("\(error), \(error.userInfo)")
//        }
//        _coordinator.showResultView(sender: sender)
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
}

