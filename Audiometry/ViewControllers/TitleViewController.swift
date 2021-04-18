
import UIKit
import CoreData
import AudioKit

class TitleViewController: UIViewController {

//------------------------------------------------------------------------------
// Local Variables
//------------------------------------------------------------------------------
    private let _managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    private var _globalSetting: GlobalSetting! = nil
    private var _currentPickerIndex: Int = 0;

//------------------------------------------------------------------------------
// UI Components
//------------------------------------------------------------------------------
    @IBOutlet weak var pbChangeLanguage: UIButton!
    
    @IBOutlet weak var pbTest: UIButton!
    @IBOutlet weak var pbPractice: UIButton!
    @IBOutlet weak var pbCalibration: UIButton!
    @IBOutlet weak var pbViewResult: UIButton!
    
//------------------------------------------------------------------------------
// UI Action
//------------------------------------------------------------------------------
    @IBAction func changeLanguage(_ sender: UIButton) {
        _currentPickerIndex = 0
        
        pickerPrompt(confirmFunction: {()->Void in
            do{
                self._globalSetting.testLanguageId = Int16(self._currentPickerIndex)
                try self._managedContext.save()
                
                self.reloadLocaleSetting()
            } catch let error as NSError{
                print("Could not update calibration setting.")
                print("\(error), \(error.userInfo)")
            }
        }, uiCtrl: self)
    }
    
    @IBAction func startTest(_ sender: UIButton) {
        if(_globalSetting.calibrationSetting != nil){
            performSegue(withIdentifier: "segueTestFromTitle", sender: nil)
        } else {
            // Prompt for user error
            errorPrompt(
                errorMsg: "There is no calibration setting selected!",
                uiCtrl: self)
        }
    }

    @IBAction func startPractice(_ sender: UIButton) {
        if(_globalSetting.calibrationSetting != nil){
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
            var profiles = try _managedContext.fetch(patientRequest)
            for emptyProfile in profiles.filter({$0.values?.count == 0}){
                _managedContext.delete(emptyProfile)
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
    
//------------------------------------------------------------------------------
// Init
//------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start AudioKit
        do {
            try AudioKit.stop()
        } catch let error as NSError {
            print("Cant stop AudioKit", error)
        }
        
        reloadGlobalSetting()
        reloadLocaleSetting()
    }
    
    private func reloadGlobalSetting() {
        // fetch all CalibrationSetting
        let request:NSFetchRequest<GlobalSetting> =
            GlobalSetting.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let settings = try _managedContext.fetch(request)
            if (settings.count == 0){
                _globalSetting = NSEntityDescription.insertNewObject(
                    forEntityName: "GlobalSetting",
                    into: _managedContext) as? GlobalSetting
                _globalSetting.testLanguageId = Int16(DEFAULT_TEST_LANGUAGE.rawValue)
                
                do{
                    try _managedContext.save()
                } catch let error as NSError{
                    print("Could not save global setting.")
                    print("\(error), \(error.userInfo)")
                }
            } else {
                _globalSetting = settings.first
            }
        } catch let error as NSError{
            print("Could not fetch global setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    private func reloadLocaleSetting() {
        // Load language option
        Bundle.set(language: _globalSetting.getTestLanguage())
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TitleViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return TestLanguage.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        let testLanguage = TestLanguage(rawValue: row) ?? TestLanguage.english
        return testLanguage.name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        _currentPickerIndex = row
    }
}
