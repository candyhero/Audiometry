
import UIKit
import CoreData

class PracticeViewController: UIViewController {
    
    //------------------------------------------------------------------------------
    // Local Variables
    //------------------------------------------------------------------------------
    private let _managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    private var _globalSetting: GlobalSetting! = nil
    private var _currentSetting: TestSetting! = nil
    
    private var _calibrationSettings: [TestSetting] = []
    private var _testSequenceFrequencies: [Int] = []
    
    private var _currentPickerIndex: Int = 0;
    
    private var _testLanguage: String = "English"
    
    //------------------------------------------------------------------------------
    // UI Components
    //------------------------------------------------------------------------------
    private var _frequencyToggleButtons = [UIButton]()
    
    @IBOutlet weak var pbReturnToTitle: UIButton!
    
    @IBOutlet weak var pbLeftEarOnly: UIButton!
    @IBOutlet weak var pbRightEarOnly: UIButton!
    @IBOutlet weak var pbLeftRightEar: UIButton!
    @IBOutlet weak var pbRightLeftEar: UIButton!
    
    @IBOutlet weak var pbRemoveLast: UIButton!
    @IBOutlet weak var pbClearAll: UIButton!
    @IBOutlet weak var pbSaveProtocol: UIButton!
    @IBOutlet weak var pbLoadProtocol: UIButton!
    @IBOutlet weak var pbDeleteCurrentProtocol: UIButton!
    
    @IBOutlet weak var pbAdultPractice: UIButton!
    @IBOutlet weak var pbChildrenPractice: UIButton!
    
    @IBOutlet weak var lbTestSequence: UILabel!
    @IBOutlet weak var lbTestEarOrderCaption: UILabel!
    @IBOutlet weak var lbTestEarOrder: UILabel!
    
    @IBOutlet weak var svFrequencyToggleButtons: UIStackView!
    
    //------------------------------------------------------------------------------
    // CoreData
    //------------------------------------------------------------------------------
    @IBAction func saveFreqSeqProtocol(_ sender: UIButton) {
        
        // Prompt for no freq selected error
        if(_testSequenceFrequencies.count == 0)
        {
            errorPrompt(errorMsg: "There is no frequency selected!", uiCtrl: self)
            return
        }
        
        inputPrompt(promptMsg: "Please Enter Protocol Name:",
                    errorMsg: "Protocol name cannot be empty!",
                    fieldMsg: "",
                    confirmFunction: saveProtocol,
                    uiCtrl: self)
    }
    
    func saveProtocol(_ newProtocolName: String){
        let setting = NSEntityDescription.insertNewObject(
            forEntityName: "TestSetting",
            into: _managedContext) as! TestSetting
        
        setting.name = newProtocolName
        setting.timestamp = Date()
        setting.frequencySequence = _testSequenceFrequencies
        setting.isTestLeftFirst = _globalSetting.isTestingLeft
        setting.isTestBoth = _globalSetting.isTestingBoth
        
        _currentSetting = setting
        
        do{
            try _managedContext.save()
        } catch let error as NSError{
            print("Could not save test protocol.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    @IBAction func loadFreqSeqProtocol(_ sender: UIButton) {
        _currentPickerIndex = 0
        
        // fetch all CalibrationSetting
        let request:NSFetchRequest<TestSetting> =
            TestSetting.fetchRequest()
        
        do {
            _calibrationSettings = try _managedContext.fetch(request)
        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }
        
        if _calibrationSettings.count > 0 {
            pickerPrompt(confirmFunction: loadProtocol,
                         uiCtrl: self)
        }
        else {
            errorPrompt(errorMsg: "There is no saved protcol!",
                        uiCtrl: self)
        }
    }
    
    func loadProtocol(){
        _currentSetting = _calibrationSettings[_currentPickerIndex]
        _testSequenceFrequencies = _currentSetting.frequencySequence ?? []
        reloadTestSequenceLabel()
    }
    
    @IBAction func deleteFreqSeqProtocol(_ sender: UIButton) {
        
        // Validate current protocol
        if(_currentSetting == nil) {
            errorPrompt(errorMsg: "There is no selected protcol!", uiCtrl: self)
            return
        }
        
        _managedContext.delete(_currentSetting)
        _currentSetting = nil
        _testSequenceFrequencies = []
        
        reloadTestSequenceLabel()
    }
    
    //------------------------------------------------------------------------------
    // Test Settings
    //------------------------------------------------------------------------------
    @IBAction func setLeftFirst(_ sender: UIButton) {
        _globalSetting.isTestingLeft = true
        _globalSetting.isTestingBoth = true
        lbTestEarOrder.text = sender.titleLabel?.text!
    }
    
    @IBAction func setRightFirst(_ sender: UIButton) {
        _globalSetting.isTestingLeft = false
        _globalSetting.isTestingBoth = true
        lbTestEarOrder.text = sender.titleLabel?.text!
    }
    
    @IBAction func setLeftOnly(_ sender: UIButton) {
        _globalSetting.isTestingLeft = true
        _globalSetting.isTestingBoth = false
        lbTestEarOrder.text = sender.titleLabel?.text!
    }
    
    @IBAction func setRightOnly(_ sender: UIButton) {
        _globalSetting.isTestingLeft = false
        _globalSetting.isTestingBoth = false
        lbTestEarOrder.text = sender.titleLabel?.text!
    }
    
    @IBAction func addNewTestSequenceFrequency(_ sender: UIButton){
        let freqID: Int! = sender.tag
        if(!_testSequenceFrequencies.contains(freqID) ){
            _testSequenceFrequencies.append(freqID)
            reloadTestSequenceLabel()
        }
    }
    
    @IBAction func removeLastFreq(_ sender: UIButton) {
        if(_testSequenceFrequencies.count > 0) {
            _testSequenceFrequencies.removeLast()
            reloadTestSequenceLabel()
        }
    }
    
    @IBAction func removeAllFreq(_ sender: UIButton) {
        if(_testSequenceFrequencies.count > 0) {
            _testSequenceFrequencies.removeAll()
            reloadTestSequenceLabel()
        }
    }
    
    func reloadTestSequenceLabel(){
        var labelTextBuffer = NSLocalizedString("Test Sequence Caption", comment: "")
        
        var count = 0
        for frequency in _testSequenceFrequencies {
            count += 1
            labelTextBuffer.append(String(frequency) + " Hz")
            labelTextBuffer.append(" ► ")
            
            if(count == 5){
                labelTextBuffer.append("\n")
            }
        }
        
        if(count == 0){
            labelTextBuffer.append(NSLocalizedString("None", comment: ""))
        }
        
        lbTestSequence.text! = labelTextBuffer
    }
    
    //------------------------------------------------------------------------------
    // Start Testing
    //------------------------------------------------------------------------------
    @IBAction func startAdultTest(_ sender: UIButton) {
        startPracticeTest(isAdult: true)
    }
    
    @IBAction func startChildrenTest(_ sender: UIButton) {
        startPracticeTest(isAdult: false)
    }
    
    func startPracticeTest(isAdult: Bool!) {
        
        // Error, no freq selected
        if(_testSequenceFrequencies.count == 0){
            errorPrompt(errorMsg: "There is no frequency selected!",
                        uiCtrl: self)
            return
        }
        
        // Double Textfield Prompt
        let alertCtrl = UIAlertController(
            title: "Save",
            message: "Please Enter Patient's Group & Name:",
            preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) {
            (_) in
            
            if let groupField = alertCtrl.textFields?[0],
                let nameField = alertCtrl.textFields?[1]{
                
                if(groupField.text!.count == 0) {
                    errorPrompt(errorMsg: "Patient group cannot be empty!",
                                uiCtrl: self)
                }
                else if(nameField.text!.count == 0) {
                    errorPrompt(errorMsg: "Patient name cannot be empty!",
                                uiCtrl: self)
                }
                else {
                    self.savePatientProfile(groupField.text!,
                                            nameField.text!,
                                            isAdult)
                    
                    if(isAdult){
                        self.performSegue(withIdentifier: "segueAdultPractice",
                                          sender: nil)
                    } else {
                        self.performSegue(withIdentifier: "segueChildrenPractice",
                                          sender: nil)
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel) {(_) in }
        
        alertCtrl.addTextField { (textField) in
            textField.placeholder = "Patient's Group"
        }
        
        alertCtrl.addTextField { (textField) in
            textField.placeholder = "Patient's Name, i.e. John Smith 1"
        }
        
        alertCtrl.addAction(confirmAction)
        alertCtrl.addAction(cancelAction)
        
        self.present(alertCtrl, animated: true, completion: nil)
    }
    
    func savePatientProfile(_ patientGroup: String,
                            _ patientName: String,
                            _ isAdult: Bool) {
        //        // Format date
        //        let date = NSDate();
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateStyle = .short
        //        dateFormatter.timeStyle = .short
        //
        //        let localDate = dateFormatter.string(from: date as Date)
        
        // Prepare new profile to test
        let profile = NSEntityDescription.insertNewObject(
            forEntityName: "PatientProfile",
            into: _managedContext) as! PatientProfile
        
        profile.name = patientName
        profile.group = patientGroup
        profile.timestamp = Date()
        profile.isAdult = isAdult
        profile.isPractice = true
        
        profile.earOrder = _globalSetting.isTestingLeft ? "L" : "R"
        profile.frequencyOrder = _testSequenceFrequencies
        print(profile)
        
        _globalSetting.patientProfile = profile
        
        _globalSetting.testFrequencySequence = _testSequenceFrequencies
        _globalSetting.testLanguage = _testLanguage
        
        _globalSetting.currentTestCount = 0
        _globalSetting.totalTestCount = Int16(_globalSetting.isTestingBoth ? _testSequenceFrequencies.count*2 : _testSequenceFrequencies.count)
        
        do{
            try _managedContext.save()
        } catch let error as NSError{
            print("Could not save test settings to global setting.")
            print("\(error), \(error.userInfo)")
        }
        
        // Test Seq saved in main setting
        // Load & save calibration setting during testing for each frequency
    }
    
    //------------------------------------------------------------------------------
    // Initialize View
    //------------------------------------------------------------------------------
    func setupUI(){
        svFrequencyToggleButtons.axis = .horizontal
        svFrequencyToggleButtons.distribution = .fillEqually
        svFrequencyToggleButtons.alignment = .center
        svFrequencyToggleButtons.spacing = 15
        
        lbTestSequence.textAlignment = .center
        lbTestSequence.numberOfLines = 0
        
        for frequency in DEFAULT_FREQUENCIES {
            // Set up buttons
            let pbNewFrequencyToggle = UIButton(type:.system)
            
            pbNewFrequencyToggle.bounds = CGRect(x:0, y:0, width:300, height:300)
            pbNewFrequencyToggle.setTitle(String(frequency)+" Hz", for: .normal)
            pbNewFrequencyToggle.backgroundColor = UIColor.gray
            pbNewFrequencyToggle.setTitleColor(UIColor.white, for: .normal)
            pbNewFrequencyToggle.tag = frequency
            
            // Binding an action function to the new button
            // i.e. to play signal
            pbNewFrequencyToggle.addTarget(self, action: #selector(addNewTestSequenceFrequency(_:)),
                                 for: .touchUpInside)
            pbNewFrequencyToggle.titleEdgeInsets = UIEdgeInsets(
                top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
            
            // Add the button to our current button array
            _frequencyToggleButtons += [pbNewFrequencyToggle]
            svFrequencyToggleButtons.addArrangedSubview(pbNewFrequencyToggle)
        }
    }
    
    private func reloadLocaleStrings() {
        pbReturnToTitle.setTitle(
            NSLocalizedString("Return To Title", comment: ""), for: .normal)
            
        lbTestEarOrderCaption.text =
            NSLocalizedString("Test Ear Order Caption", comment: "")
    
        pbLeftEarOnly.setTitle(
            NSLocalizedString("Left Ear", comment: ""), for: .normal)
        pbRightEarOnly.setTitle(
            NSLocalizedString("Right Ear", comment: ""), for: .normal)
        pbLeftRightEar.setTitle(
            NSLocalizedString("Left Right Ear", comment: ""), for: .normal)
        pbRightLeftEar.setTitle(
            NSLocalizedString("Right Left Ear", comment: ""), for: .normal)
        
        pbRemoveLast.setTitle(
            NSLocalizedString("Remove Last", comment: ""), for: .normal)
        pbClearAll.setTitle(
            NSLocalizedString("Clear All", comment: ""), for: .normal)
        pbSaveProtocol.setTitle(
            NSLocalizedString("Save Protocol", comment: ""), for: .normal)
        pbLoadProtocol.setTitle(
            NSLocalizedString("Load Protocol", comment: ""), for: .normal)
        pbDeleteCurrentProtocol.setTitle(
            NSLocalizedString("Delete Current Protocol", comment: ""), for: .normal)
        pbAdultPractice.setTitle(
            NSLocalizedString("Adult Practice", comment: ""), for: .normal)
        pbChildrenPractice.setTitle(
            NSLocalizedString("Children Practice", comment: ""), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        reloadTestSequenceLabel()
        reloadLocaleStrings()
        
        // fetch global setting
        let request:NSFetchRequest<GlobalSetting> = GlobalSetting.fetchRequest()
        request.fetchLimit = 1
        
        do {
            _globalSetting = try _managedContext.fetch(request).first
            _globalSetting.isTestingLeft = true
            _globalSetting.isTestingBoth = true
            lbTestEarOrder.text! = NSLocalizedString("Left Right Ear", comment: "")
        }
        catch let error as NSError{
            print("Could not fetch global setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PracticeViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return _calibrationSettings.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return _calibrationSettings[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        _currentPickerIndex = row
    }
}
