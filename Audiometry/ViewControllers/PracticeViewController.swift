
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
    
    private var _array_settings: [TestSetting] = []
    private var _array_testFreqSeq: [Int] = []
    
//    private let ARRAY_DEFAULT_FREQSEQ: [Double]! = [500, 4000, 1000, 8000, 250, 2000]
    
    private var _currentPickerIndex: Int = 0;
    
    //------------------------------------------------------------------------------
    // UI Components
    //------------------------------------------------------------------------------
    private var _array_pbFreq = [UIButton]()
    
    @IBOutlet weak var svFreq: UIStackView!
    @IBOutlet weak var lbFreqSeq: UILabel!
    @IBOutlet weak var lbEarOrder: UILabel!
    
    //------------------------------------------------------------------------------
    // CoreData
    //------------------------------------------------------------------------------
    @IBAction func saveFreqSeqProtocol(_ sender: UIButton) {
        
        // Prompt for no freq selected error
        if(_array_testFreqSeq.count == 0)
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
            into: _managedContext) as! TestSetting
        
        setting.name = newProtocolName
        setting.timestamp = Date()
        setting.frequencySequence = _array_testFreqSeq
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
            _array_settings = try _managedContext.fetch(request)
        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }
        
        if _array_settings.count > 0 {
            pickerPrompt(confirmFunction: loadProtocol,
                         uiCtrl: self)
        }
        else {
            errorPrompt(errorMsg: "There is no saved protcol!",
                        uiCtrl: self)
        }
    }
    
    func loadProtocol(){
        _currentSetting = _array_settings[_currentPickerIndex]
        _array_testFreqSeq = _currentSetting.frequencySequence ?? []
        updateLabel()
    }
    
    @IBAction func deleteFreqSeqProtocol(_ sender: UIButton) {
        
        // Validate current protocol
        if(_currentSetting == nil) {
            
            errorPrompt(errorMsg: "There is no selected protcol!",
                        uiCtrl: self)
            return
        }
        
        _managedContext.delete(_currentSetting)
        _currentSetting = nil
        _array_testFreqSeq = []
        
        updateLabel()
    }
    
    //------------------------------------------------------------------------------
    // Test Settings
    //------------------------------------------------------------------------------
    @IBAction func setLeftFirst(_ sender: UIButton) {
        _globalSetting.isTestingLeft = true
        _globalSetting.isTestingBoth = true
        lbEarOrder.text = sender.titleLabel?.text!
    }
    
    @IBAction func setRightFirst(_ sender: UIButton) {
        _globalSetting.isTestingLeft = false
        _globalSetting.isTestingBoth = true
        lbEarOrder.text = sender.titleLabel?.text!
    }
    
    @IBAction func setLeftOnly(_ sender: UIButton) {
        _globalSetting.isTestingLeft = true
        _globalSetting.isTestingBoth = false
        lbEarOrder.text = sender.titleLabel?.text!
    }
    
    @IBAction func setRightOnly(_ sender: UIButton) {
        _globalSetting.isTestingLeft = false
        _globalSetting.isTestingBoth = false
        lbEarOrder.text = sender.titleLabel?.text!
    }
    
    @IBAction func addNewFreq(_ sender: UIButton){
        let freqID: Int! = sender.tag
        if(!_array_testFreqSeq.contains(freqID) ){
            _array_testFreqSeq.append(freqID)
            updateLabel()
        }
    }
    
    @IBAction func removeLastFreq(_ sender: UIButton) {
        if(_array_testFreqSeq.count > 0) {
            _array_testFreqSeq.removeLast()
            updateLabel()
        }
    }
    
    @IBAction func removeAllFreq(_ sender: UIButton) {
        if(_array_testFreqSeq.count > 0) {
            _array_testFreqSeq.removeAll()
            updateLabel()
        }
    }
    
    func updateLabel(){
        
        var tempFreqSeqStr = String("Test Sequence: ")
        
        var freqCount = 0
        for freq in _array_testFreqSeq {
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
        if(_array_testFreqSeq.count == 0){
            errorPrompt(errorMsg: "There is no frequency selected!",
                        uiCtrl: self)
            return
        }
        
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
            into: _managedContext) as! PatientProfile
        
        profile.name = patientName
        profile.timestamp = Date()
        profile.isAdult = isAdult
        profile.isPractice = true
        
        _globalSetting.testFrequencySequence = _array_testFreqSeq
        _globalSetting.currentTestCount = 0
        _globalSetting.totalTestCount = Int16(_globalSetting.isTestingBoth ? _array_testFreqSeq.count*2 : _array_testFreqSeq.count)
        _globalSetting.patientProfile = profile
        
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateLabel()
        
        // fetch global setting
        let request:NSFetchRequest<GlobalSetting> =
            GlobalSetting.fetchRequest()
        request.fetchLimit = 1
        
        do {
            _globalSetting = try _managedContext.fetch(request).first
            _globalSetting.isTestingLeft = true
            _globalSetting.isTestingBoth = true
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
            _array_pbFreq += [new_pbFreq]
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
        return _array_settings.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return _array_settings[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        _currentPickerIndex = row
    }
}
