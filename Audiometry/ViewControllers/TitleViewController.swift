
import UIKit

class TitleViewController: UIViewController, Storyboarded {
    weak var coordinator: MainCoordinator?
    // MARK:
    private var _globalSetting: GlobalSetting!
    
    // MARK:
    private let _globalSettingRepo = GlobalSettingRepo()
    private let _patientProfileRepo = PatientProfileRepo()
    
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TitleView loaded!")
        //            try AudioKit.stop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Controller functions
    @IBAction func showCalibrationView(_ sender: UIButton) {
        coordinator?.showCalibrationView(sender: sender)
    }
    
    @IBAction func prepareTestProtocol(_ sender: UIButton) {
        if coordinator?.getCurrentCalibrationSetting() == nil{
            errorPrompt(
                errorMsg: "There is no calibration setting selected!",
                uiCtrl: self)
            return
        }
        coordinator?.showTestProtoclView(sender: sender)
    }
    
    @IBAction func showResultView(_ sender: UIButton) {
        do {
            if try _patientProfileRepo.validateAnyPatientProfiles() {
                performSegue(withIdentifier: "segueResultFromTitle", sender: nil)
            } else {
                errorPrompt(
                    errorMsg: "There is no result!",
                    uiCtrl: self)
            }
        } catch let error as NSError {
            print("[Error] There is no patient profileg.")
            print("\(error), \(error.userInfo)")
        }
        coordinator?.showResultView(sender: sender)
    }
}

