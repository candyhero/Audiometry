
import UIKit

class TitleViewController: UIViewController {
    
    // MARK:
    private var _globalSetting: GlobalSetting!
    
    // MARK:
    private let _globalSettingRepo = GlobalSettingRepo()
    private let _patientProfileRepo = PatientProfileRepo()
    
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            _globalSetting = try _globalSettingRepo.fetchGlobalSetting()
//            try AudioKit.stop()
        } catch let error as NSError {
            print("[Error] Could not initialize global setting.")
            print("\(error), \(error.userInfo)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Controller functions
    @IBAction func startTesting(_ sender: UIButton) {
        // Validator
        if _globalSetting.calibrationSetting == nil {
            errorPrompt(
                errorMsg: "There is no calibration setting selected!",
                uiCtrl: self)
            return
        }
        
        performSegue(withIdentifier: "segueProtocolFromTitle", sender: nil)
    }
    
    @IBAction func viewResults(_ sender: UIButton) {
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
    }
}

