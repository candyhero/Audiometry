
import UIKit

class TestProtocolViewController: UIViewController, Storyboarded {
    
    // MARK:
    private let _coordinator = AppDelegate.testProcotolCoordinator
    
    // MARK: Repo
    private let _globalSettingRepo = GlobalSettingRepo()
    private let _patientProfileRepo = PatientProfileRepo()
    
    // MARK: Local Variables
    private var _currentPickerIndex: Int = 0;
    
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
        clearFreqSeqLabel()
        lbEarOrder.text = "L. Ear -> R. Ear"
        _coordinator.setTestEarOrder(isLeft: true, isBoth: true)
        if _coordinator.isPractice() {
            pbAdult.setTitle("Adult Practice", for: .normal)
            pbChildren.setTitle("Children Practice", for: .normal)
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
    func clearFreqSeqLabel(){
        updateFreqSeqLabel([])
    }
    func updateFreqSeqLabel(_ frequencies: [Int]) {
        var bufferString = String("Test Sequence: ")
        for freq in frequencies {
            if(bufferString.count >= 60) { bufferString.append("\n") }
            bufferString.append(String(freq) + " Hz")
            bufferString.append(" ► ")
        }
        if(bufferString.count < 20) { bufferString.append("None") }
        lbFreqSeq.text! = bufferString
    }
    
    // MARK: UIButton Actions
    @IBAction func switchToEnglish(_ sender: UIButton) {
        lbTestLanguage.text = _coordinator.setTestLanguage(langauge: .English)
    }
    
    @IBAction func switchToPortuguese(_ sender: UIButton) {
        lbTestLanguage.text = _coordinator.setTestLanguage(langauge: .Portuguese)
    }
    
    // MARK: Set test order
    @IBAction func setLeftFirst(_ sender: UIButton) {
        _coordinator.setTestEarOrder(isLeft: false, isBoth: false)
        lbEarOrder.text = sender.titleLabel?.text
    }
    
    @IBAction func setRightFirst(_ sender: UIButton) {
        _coordinator.setTestEarOrder(isLeft: false, isBoth: false)
        lbEarOrder.text = sender.titleLabel?.text
    }
    
    @IBAction func setLeftOnly(_ sender: UIButton) {
        _coordinator.setTestEarOrder(isLeft: false, isBoth: false)
        lbEarOrder.text = sender.titleLabel?.text
    }
    
    @IBAction func setRightOnly(_ sender: UIButton) {
        _coordinator.setTestEarOrder(isLeft: false, isBoth: false)
        lbEarOrder.text = sender.titleLabel?.text
    }
    
    // MARK:
    @IBAction func addNewFreq(_ sender: UIButton) {
        updateFreqSeqLabel(_coordinator.addTestFrequencyValue(sender.tag) )
    }
    
    @IBAction func removeLastFreq(_ sender: UIButton) {
        updateFreqSeqLabel(_coordinator.removeLastTestFrequencyValue() )
    }
    
    @IBAction func removeAllFreq(_ sender: UIButton) {
        updateFreqSeqLabel(_coordinator.removeAllTestFrequencyValues() )
    }
    
    // MARK: CoreData
    @IBAction func saveFreqSeqProtocol(_ sender: UIButton) {
        if _coordinator.getFrequencyBufferCount() == 0 {
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
        _coordinator.saveAsNewProtocol(protocolName)
    }
    
    @IBAction func loadFreqSeqProtocol(_ sender: UIButton) {
        _currentPickerIndex = 0
        let protocols = _coordinator.getAllTestProtocols()
        if protocols.count > 0 {
            pickerPrompt(confirmFunction: { () in
                self.updateFreqSeqLabel(self._coordinator.loadProtocol(self._currentPickerIndex))
            }, uiCtrl: self)
        } else {
            errorPrompt(errorMsg: "There is no saved protcol!", uiCtrl: self)
        }
    }
    
    @IBAction func deleteFreqSeqProtocol(_ sender: UIButton) {
        if _coordinator.deleteCurrentTestProtocol() {
            errorPrompt(errorMsg: "There is no selected protcol!", uiCtrl: self)
        } else {
            clearFreqSeqLabel()
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
        _coordinator.setIsAdult(isAdult: true)
        promptToStartTest()
    }
    
    @IBAction func startChildrenTest(_ sender: UIButton) {
        _coordinator.setIsAdult(isAdult: false)
        promptToStartTest()
    }
    
    func promptToStartTest() {
        // Error, no freq selected
        if(_coordinator.getFrequencyBufferCount() == 0) {
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
                self.startTest(patientGroup, patientName)
            }
        }
        
        alertCtrl.addAction(UIAlertAction(title: "Confirm",
                                          style: .default,
                                          handler: confirmActionHandler))
        alertCtrl.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alertCtrl, animated: true, completion: nil)
    }
    
    func startTest(_ patientGroup: String, _ patientName: String) {
        let isAdult: Bool! = _coordinator.isAdult()
        
        do{
            guard patientGroup.count > 0 else { throw PreTestError.invalidPaientGroup }
            guard patientName.count > 0 else { throw PreTestError.invalidPatentName }
            
            try self.savePatientProfile(patientGroup, patientName, isAdult)
            self._coordinator.showInstructionView(sender: nil, isAdult: isAdult)
        } catch PreTestError.invalidPaientGroup {
            errorPrompt(errorMsg: "Patient group cannot be empty!", uiCtrl: self)
        } catch PreTestError.invalidPatentName {
            errorPrompt(errorMsg: "Patient name cannot be empty!", uiCtrl: self)
        } catch {
            print("[Error] Unexpected error: \(error).")
        }
    }
}

extension TestProtocolViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
//        return _testProtocols.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return "Error"
//        return _testProtocols[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        _currentPickerIndex = row
    }
}
