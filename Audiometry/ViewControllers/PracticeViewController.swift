
import UIKit
import CoreData

class PracticeViewController: UIViewController {
    
    //------------------------------------------------------------------------------
    // Local Variables
    //------------------------------------------------------------------------------
    private let managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    private var globalSetting: GlobalSetting! = nil
    private var currentSetting: TestSetting! = nil
    
    private var array_settings: [TestSetting] = []
    private var array_testFreqSeq: [Int] = []
    
    private let ARRAY_DEFAULT_FREQSEQ: [Double]! = [500, 4000, 1000, 8000, 250, 2000]
    
    private var _currentPickerIndex: Int = 0;
    
    //------------------------------------------------------------------------------
    // UI Components
    //------------------------------------------------------------------------------
    private var array_pbFreq = [UIButton]()
    
    @IBOutlet weak var svFreq: UIStackView!
    @IBOutlet weak var lbFreqSeq: UILabel!
    @IBOutlet weak var lbEarOrder: UILabel!
    
    //------------------------------------------------------------------------------
    // CoreData
    //------------------------------------------------------------------------------
    @IBAction func saveFreqSeqProtocol(_ sender: UIButton) {
        
        // Prompt for no freq selected error
        if(array_testFreqSeq.count == 0)
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
        
        // If duplicated name
//        if(false){
//            errorPrompt(
//                errorMsg: "Protocol name already exists!",
//                uiCtrl: self)
//            return
//        }
        
        // Else, save protocol
        let setting = NSEntityDescription.insertNewObject(
            forEntityName: "TestSetting",
            into: managedContext) as! TestSetting
        
        setting.name = newProtocolName
        setting.timestamp = Date()
        setting.frequencySequence = array_testFreqSeq
        setting.isTestLeftFirst = globalSetting.isTestingLeft
        setting.isTestBoth = globalSetting.isTestingBoth
        
        currentSetting = setting
        
        do{
            try managedContext.save()
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
            array_settings = try managedContext.fetch(request)
        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }
        
        if array_settings.count > 0 {
            pickerPrompt(confirmFunction: loadProtocol,
                         uiCtrl: self)
        }
        else {
            errorPrompt(errorMsg: "There is no saved protcol!",
                        uiCtrl: self)
        }
    }
    
    func loadProtocol(){
        currentSetting = array_settings[_currentPickerIndex]
        array_testFreqSeq = currentSetting.frequencySequence ?? []
        updateLabel()
    }
    
    @IBAction func deleteFreqSeqProtocol(_ sender: UIButton) {
        
        // Validate current protocol
        if(currentSetting == nil) {
            
            errorPrompt(errorMsg: "There is no selected protcol!",
                        uiCtrl: self)
            return
        }
        
        managedContext.delete(currentSetting)
        currentSetting = nil
        array_testFreqSeq = []
        
        updateLabel()
    }
    
    //------------------------------------------------------------------------------
    // Test Settings
    //------------------------------------------------------------------------------
    @IBAction func setLeftFirst(_ sender: UIButton) {
        globalSetting.isTestingLeft = true
        globalSetting.isTestingBoth = true
        lbEarOrder.text = sender.titleLabel?.text!
    }
    
    @IBAction func setRightFirst(_ sender: UIButton) {
        globalSetting.isTestingLeft = false
        globalSetting.isTestingBoth = true
        lbEarOrder.text = sender.titleLabel?.text!
    }
    
    @IBAction func setLeftOnly(_ sender: UIButton) {
        globalSetting.isTestingLeft = true
        globalSetting.isTestingBoth = false
        lbEarOrder.text = sender.titleLabel?.text!
    }
    
    @IBAction func setRightOnly(_ sender: UIButton) {
        globalSetting.isTestingLeft = false
        globalSetting.isTestingBoth = false
        lbEarOrder.text = sender.titleLabel?.text!
    }
    
    @IBAction func addNewFreq(_ sender: UIButton){
        let freqID: Int! = sender.tag
        if(!array_testFreqSeq.contains(freqID) ){
            array_testFreqSeq.append(freqID)
            updateLabel()
        }
    }
    
    @IBAction func removeLastFreq(_ sender: UIButton) {
        if(array_testFreqSeq.count > 0) {
            array_testFreqSeq.removeLast()
            updateLabel()
        }
    }
    
    @IBAction func removeAllFreq(_ sender: UIButton) {
        if(array_testFreqSeq.count > 0) {
            array_testFreqSeq.removeAll()
            updateLabel()
        }
    }
    
    func updateLabel(){
        
        var tempFreqSeqStr = String("Test Sequence: ")
        
        var freqCount = 0
        for freq in array_testFreqSeq {
            freqCount += 1
            tempFreqSeqStr.append(String(freq) + " Hz")
            tempFreqSeqStr.append(" ► ")
            
            if(freqCount == 5){
                tempFreqSeqStr.append("\n")
            }
        }
        
        if(freqCount == 0){
            tempFreqSeqStr.append("None")
        }
        
        lbFreqSeq.text! = tempFreqSeqStr
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
        if(array_testFreqSeq.count == 0){
            errorPrompt(errorMsg: "There is no frequency selected!",
                        uiCtrl: self)
            return
        }
        
        globalSetting.testFrequencySequence = array_testFreqSeq
        
        // Prompt for user to input setting name
        inputPrompt(promptMsg: "Please Enter Patient's Name:",
                    errorMsg: "Patient name cannot be empty!",
                    fieldMsg: "i.e. John Smith 1",
                    confirmFunction: {(patientName: String) -> Void in
                        self.savePatientProfile(patientName, isAdult)
                        
                        if(isAdult){
                            self.performSegue(withIdentifier: "segueAdultPractice", sender: nil)
                        } else {
                            self.performSegue(withIdentifier: "segueChildrenPractice", sender: nil)
                        }
        },
                    uiCtrl: self)
    }
    
    func savePatientProfile(_ patientName: String, _ isAdult: Bool) {
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
            into: managedContext) as! PatientProfile
        
        profile.name = patientName
        profile.timestamp = Date()
        profile.isAdult = isAdult
        profile.isPractice = true
        
        globalSetting.patientProfile = profile
        
        do{
            try managedContext.save()
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateLabel()
        
        // fetch global setting
        let request:NSFetchRequest<GlobalSetting> =
            GlobalSetting.fetchRequest()
        request.fetchLimit = 1
        
        do {
            globalSetting = try managedContext.fetch(request).first
            globalSetting.isTestingLeft = true
            globalSetting.isTestingBoth = true
            lbEarOrder.text! = "L. Ear -> R. Ear"
            
        } catch let error as NSError{
            print("Could not fetch global setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    func setupUI(){
        svFreq.axis = .horizontal
        svFreq.distribution = .fillEqually
        svFreq.alignment = .center
        svFreq.spacing = 15
        
        lbFreqSeq.textAlignment = .center
        lbFreqSeq.numberOfLines = 0
        
        for freq in DEFAULT_FREQ {
            // Set up buttons
            let new_pbFreq = UIButton(type:.system)
            
            new_pbFreq.bounds = CGRect(x:0, y:0, width:300, height:300)
            new_pbFreq.setTitle(String(freq)+" Hz", for: .normal)
            new_pbFreq.backgroundColor = UIColor.gray
            new_pbFreq.setTitleColor(UIColor.white, for: .normal)
            new_pbFreq.tag = freq
            
            // Binding an action function to the new button
            // i.e. to play signal
            new_pbFreq.addTarget(self, action: #selector(addNewFreq(_:)),
                                 for: .touchUpInside)
            new_pbFreq.titleEdgeInsets = UIEdgeInsets(
                top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
            
            // Add the button to our current button array
            array_pbFreq += [new_pbFreq]
            svFreq.addArrangedSubview(new_pbFreq)
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
        return array_settings.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return array_settings[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        _currentPickerIndex = row
    }
}
