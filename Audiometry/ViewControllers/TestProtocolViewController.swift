import UIKit

class TestProtocolViewController: UIViewController, Storyboarded {
    weak var coordinator: MainCoordinator?
    
    // MARK: Repo
    private let _globalSettingRepo = GlobalSettingRepo()
    private let _patientProfileRepo = PatientProfileRepo()
    private let _testProtocolRepo = TestProtocolRepo()
    
    // MARK: Local Variables
    private var _globalSetting: GlobalSetting! = nil
    private var _testProtocol: TestProtocol! = nil
    
    private var _testProtocols: [TestProtocol] = []
    private var _frequencyBuffer: [Int] = []
    
    private var _currentPickerIndex: Int = 0;
    
    private var _testLanguage: String = "English"
    
    // Segue definitions
    let SEGUE_TITLE = "segueTitle"
    let SEGUE_PROTOCOL = "segueProtocol"
    let SEGUE_ADULT_TEST = "segueAdultTest"
    let SEGUE_CHILDREN_TEST = "segueChildrenTest"
    let SEGUE_PAUSE = "seguePause"
    let SEGUE_RESULT = "segueResult"
    
    // MARK: PretestError
    enum PreTestError: Error {
        case invalidTestingFrequencies
        case invalidPaientGroup
        case invalidPatentName
    }
    
    // MARK: UI Components
    private var _array_pbFreq = [UIButton]()
    
    @IBOutlet weak var pbAdult: UIButton!
    @IBOutlet weak var pbChildren: UIButton!
    @IBOutlet weak var svFreq: UIStackView!
    @IBOutlet weak var lbFreqSeq: UILabel!
    @IBOutlet weak var lbEarOrder: UILabel!
    @IBOutlet weak var lbTestLanguage: UILabel!
    
    // MARK: Initialize ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateLabel()
        do {
            _globalSetting = try _globalSettingRepo.fetchGlobalSetting()
            self.setTestEarOrder(isLeft: true, isBoth: true, labelText: "L. Ear -> R. Ear")
            
            if(_globalSetting.isPractice) {
                pbAdult.setTitle("Adult Practice", for: .normal)
                pbChildren.setTitle("Children Practice", for: .normal)
            }
        } catch let error as NSError{
            print("Could not fetch global setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        svFreq.axis = .horizontal
        svFreq.distribution = .fillEqually
        svFreq.alignment = .center
        svFreq.spacing = 15
        
        lbFreqSeq.textAlignment = .center
        lbFreqSeq.numberOfLines = 0
        
        for freq in ARRAY_DEFAULT_FREQ {
            let newButton = ProtocolUIFactory.GetNewFrequencyButton(
                frequency: freq,
                action: #selector(addNewFreq(_:))
            )
            
            _array_pbFreq.append(newButton)
            svFreq.addArrangedSubview(newButton)
        }
    }
    
    func updateLabel() {
        var bufferString = String("Test Sequence: ")
        for freq in _frequencyBuffer {
            if(bufferString.count >= 60) { bufferString.append("\n") }
            bufferString.append(String(freq) + " Hz")
            bufferString.append(" ► ")
        }
        if(bufferString.count < 20) { bufferString.append("None") }
        lbFreqSeq.text! = bufferString
    }
    
    // MARK: UIButton Actions
    @IBAction func switchToEnglish(_ sender: UIButton) {
        _testLanguage = "English"
        lbTestLanguage.text = _testLanguage
    }
    
    @IBAction func switchToPortuguese(_ sender: UIButton) {
        _testLanguage = "Portuguese"
        lbTestLanguage.text = _testLanguage
    }
    
    @IBAction func setLeftFirst(_ sender: UIButton) {
        setTestEarOrder(isLeft: false, isBoth: false, labelText: sender.titleLabel?.text)
    }
    
    @IBAction func setRightFirst(_ sender: UIButton) {
        setTestEarOrder(isLeft: false, isBoth: false, labelText: sender.titleLabel?.text)
    }
    
    @IBAction func setLeftOnly(_ sender: UIButton) {
        setTestEarOrder(isLeft: false, isBoth: false, labelText: sender.titleLabel?.text)
    }
    
    @IBAction func setRightOnly(_ sender: UIButton) {
        setTestEarOrder(isLeft: false, isBoth: false, labelText: sender.titleLabel?.text)
    }
    
    func setTestEarOrder(isLeft: Bool, isBoth: Bool, labelText: String?) {
        _globalSetting.isTestingLeft = isLeft
        _globalSetting.isTestingBoth = isBoth
        lbEarOrder.text = labelText
    }
    
    @IBAction func addNewFreq(_ sender: UIButton) {
        let freqID: Int! = sender.tag
        if(!_frequencyBuffer.contains(freqID) ) {
            _frequencyBuffer.append(freqID)
            updateLabel()
        }
    }
    
    @IBAction func removeLastFreq(_ sender: UIButton) {
        if(_frequencyBuffer.count > 0) {
            _frequencyBuffer.removeLast()
            updateLabel()
        }
    }
    
    @IBAction func removeAllFreq(_ sender: UIButton) {
        if(_frequencyBuffer.count > 0) {
            _frequencyBuffer.removeAll()
            updateLabel()
        }
    }
    
    // MARK: CoreData
    @IBAction func saveFreqSeqProtocol(_ sender: UIButton) {
        if _frequencyBuffer.count == 0 {
            errorPrompt(errorMsg: "There is no test frequency selected", uiCtrl: self)
        } else {
            inputPrompt(promptMsg: "Please Enter Protocol Name:",
                        errorMsg: "Protocol name cannot be empty!",
                        fieldMsg: "",
                        confirmFunction: saveProtocol,
                        uiCtrl: self)
        }
    }
    
    func saveProtocol(_ protocolName: String) {
        // If duplicated name
        //        if(false) {
        //            errorPrompt(
        //                errorMsg: "Protocol name already exists!",
        //                uiCtrl: self)
        //            return
        //        }
        do{
            try _testProtocol = _testProtocolRepo.saveNewTestProtocol(protocolName, _globalSetting)
        } catch let error as NSError{
            print("Could not save test protocol.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    @IBAction func loadFreqSeqProtocol(_ sender: UIButton) {
        _currentPickerIndex = 0
        do{
            _testProtocols = try _testProtocolRepo.fetchAllTestProtocols()
            if _testProtocols.count > 0 {
                pickerPrompt(confirmFunction: loadProtocol,
                             uiCtrl: self)
            }
            else {
                errorPrompt(errorMsg: "There is no saved protcol!",
                            uiCtrl: self)
            }
        } catch let error as NSError{
            print("Could not fetch test protocols.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    func loadProtocol() {
        _testProtocol = _testProtocols[_currentPickerIndex]
        _frequencyBuffer = _testProtocol.frequencySequence ?? []
        updateLabel()
    }
    
    @IBAction func deleteFreqSeqProtocol(_ sender: UIButton) {
        
        // Validate current protocol
        if(_testProtocol == nil) {
            errorPrompt(errorMsg: "There is no selected protcol!", uiCtrl: self)
            return
        }
        
        do {
            try _testProtocolRepo.deleteTestProtocol(_testProtocol)
            _testProtocol = nil
            _frequencyBuffer = []
            updateLabel()
        } catch let error as NSError {
            print("Could not fetch test protocols.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    func savePatientProfile(_ patientGroup: String,
                            _ patientName: String,
                            _ isAdult: Bool) throws {
        //        // Format date
        //        let date = NSDate();
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateStyle = .short
        //        dateFormatter.timeStyle = .short
        //
        //        let localDate = dateFormatter.string(from: date as Date)
        
        // Prepare new profile to test
        //        do{
        //            let profile = try _patientProfileRepo.save(
        //                patientName, patientGroup, _frequencyBuffer, _globalSetting)
        //        } catch let error as NSError{
        //            print("Could not save test settings to global setting.")
        //            print("\(error), \(error.userInfo)")
        //        }
        
        // Test Seq saved in main setting
        // Load & save calibration setting during testing for each frequency
    }
    
    @IBAction func startAdultTest(_ sender: UIButton) {
        _globalSetting.isAdult = true
        startTest()
    }
    
    @IBAction func startChildrenTest(_ sender: UIButton) {
        _globalSetting.isAdult = false
        startTest()
    }
    
    func startTest() {
        // Error, no freq selected
        if(_frequencyBuffer.count == 0) {
            errorPrompt(errorMsg: "There is no frequency selected!",
                        uiCtrl: self)
            return
        }
        
        // Double Textfield Prompt
        let alertCtrl = UIAlertController(
            title: "Save",
            message: "Please Enter Patient's Group & Name:",
            preferredStyle: .alert)
        
        alertCtrl.addTextField { (textField) in textField.placeholder = "Patient's Group" }
        alertCtrl.addTextField { (textField) in
            textField.placeholder = "Patient's Name, i.e. John Smith 1"
        }
        
        let confirmActionHandler = { (action: UIAlertAction) in
            if let patientGroup = alertCtrl.textFields?[0].text,
                let patientName = alertCtrl.textFields?[1].text{
                
                let isAdult = self._globalSetting.isAdult
                
                do{
                    guard patientGroup.count > 0 else { throw PreTestError.invalidPaientGroup }
                    guard patientName.count > 0 else { throw PreTestError.invalidPatentName }
                    
                    try self.savePatientProfile(patientGroup, patientName, isAdult)
                    let segueId = isAdult ? self.SEGUE_ADULT_TEST : self.SEGUE_CHILDREN_TEST
                    self.performSegue(withIdentifier: segueId, sender: nil)
                } catch PreTestError.invalidPaientGroup {
                    errorPrompt(errorMsg: "Patient group cannot be empty!", uiCtrl: self)
                } catch PreTestError.invalidPatentName {
                    errorPrompt(errorMsg: "Patient name cannot be empty!", uiCtrl: self)
                } catch {
                    print("[Error] Unexpected error: \(error).")
                }
            }
        }
        
        alertCtrl.addAction(UIAlertAction(title: "Confirm",
                                          style: .default,
                                          handler: confirmActionHandler))
        alertCtrl.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alertCtrl, animated: true, completion: nil)
    }
}

extension TestProtocolViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return _testProtocols.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return _testProtocols[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        _currentPickerIndex = row
    }
}
