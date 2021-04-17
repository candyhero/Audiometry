
import UIKit
import CoreData
import AudioKit

class TitleViewController: UIViewController {
    
    private var globalSetting: GlobalSetting! = nil
    
    @IBOutlet weak var pbTest: UIButton!
    @IBOutlet weak var pbPractice: UIButton!
    @IBOutlet weak var pbCalibration: UIButton!
    @IBOutlet weak var pbViewResult: UIButton!
    
    @IBOutlet weak var pbChangeLanguage: UIButton!
    
    private let managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    @IBAction func startTest(_ sender: Any) {
        if(globalSetting.calibrationSetting != nil){
            performSegue(withIdentifier: "segueTestFromTitle", sender: nil)
        } else {
            // Prompt for user error
            errorPrompt(
                errorMsg: "There is no calibration setting selected!",
                uiCtrl: self)
        }
    }
    
    @IBAction func startPractice(_ sender: Any) {
        if(globalSetting.calibrationSetting != nil){
            performSegue(withIdentifier: "seguePracticeFromTitle", sender: nil)
        } else {
            // Prompt for user error
            errorPrompt(
                errorMsg: "There is no calibration setting selected!",
                uiCtrl: self)
        }
    }
    
    @IBAction func viewResults(_ sender: UIButton) {
        // fetch all PatientProfiles
        let patientRequest:NSFetchRequest<PatientProfile> =
            PatientProfile.fetchRequest()
        
        do {
            var profiles = try managedContext.fetch(patientRequest)
            for emptyProfile in profiles.filter({$0.values?.count == 0}){
                managedContext.delete(emptyProfile)
            }
            profiles.removeAll(where: {$0.values?.count == 0})
            
            if (profiles.count > 0){
                performSegue(withIdentifier: "segueResultFromTitle", sender: nil)
            } else {
                // Prompt for user error
                errorPrompt(
                    errorMsg: "There is no result!",
                    uiCtrl: self)
            }
        } catch let error as NSError{
            print("Could not fetch patient profiles.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    //
    private func LoadGlobalSetting() {
        // fetch all CalibrationSetting
        let request:NSFetchRequest<GlobalSetting> =
            GlobalSetting.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let settings = try managedContext.fetch(request)
            if (settings.count == 0){
                globalSetting = NSEntityDescription.insertNewObject(
                    forEntityName: "GlobalSetting",
                    into: managedContext) as? GlobalSetting
                do{
                    try managedContext.save()
                } catch let error as NSError{
                    print("Could not save global setting.")
                    print("\(error), \(error.userInfo)")
                }
            } else {
                globalSetting = settings.first
            }
        } catch let error as NSError{
            print("Could not fetch global setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    private func reloadLocaleStrings() {
        pbTest.setTitle(
            NSLocalizedString("Test", comment: ""), for: .normal)
        pbPractice.setTitle(
            NSLocalizedString("Practice", comment: ""), for: .normal)
        pbCalibration.setTitle(
            NSLocalizedString("Calibration", comment: ""), for: .normal)
        pbViewResult.setTitle(
            NSLocalizedString("View Results", comment: ""), for: .normal)
        pbChangeLanguage.setTitle(
            NSLocalizedString("Change Language", comment: ""), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start AudioKit
        do {
            try AudioKit.stop()
        } catch let error as NSError {
            print("Cant stop AudioKit", error)
        }
        
        LoadGlobalSetting()
        
        // Load language option
        Bundle.set(language: .portuguese)
        reloadLocaleStrings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

