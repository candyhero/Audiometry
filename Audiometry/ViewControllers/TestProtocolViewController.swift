
import UIKit

class TestProtocolViewController: UIViewController, Storyboarded {
    // MARK:
    let coordinator = AppDelegate.testProcotolCoordinator
    
    // MARK: Local Variables
    private var _pickerIndex: Int = 0;
    
    // MARK: PretestError
    enum PreTestError: Error {
        case invalidTestingFrequencies
        case invalidPaientGroup
        case invalidPatentName
    }
    
    // MARK: UI Components
    private var _freqButtons = [UIButton]()
    
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
        coordinator.setTestEarOrder(isLeft: true, isBoth: true)
        lbTestLanguage.text = coordinator.getTestLanguage().toString()
        if coordinator.isPractice() {
            pbAdult.setTitle("Adult Practice", for: .normal)
            pbChildren.setTitle("Children Practice", for: .normal)
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        coordinator.back()
    }
    
    func setupUI() {
        svFreq.axis = .horizontal
        svFreq.distribution = .fillEqually
        svFreq.alignment = .center
        svFreq.spacing = 15
        
        lbFreqSeq.textAlignment = .center
        lbFreqSeq.numberOfLines = 0
        
        for freq in DEFAULT_FREQ {
            let newButton = ProtocolUIFactory.GetNewFrequencyButton(frequency: freq)
            newButton.addTarget(self, action: #selector(addNewFreq(_:)), for: .touchUpInside)

            _freqButtons.append(newButton)
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
        lbTestLanguage.text = coordinator.setTestLanguage(language: .English).toString()
    }
    
    @IBAction func switchToPortuguese(_ sender: UIButton) {
        lbTestLanguage.text = coordinator.setTestLanguage(language: .Portuguese).toString()
    }
    
    // MARK: Set test order
    @IBAction func setLeftFirst(_ sender: UIButton) {
        coordinator.setTestEarOrder(isLeft: true, isBoth: true)
        lbEarOrder.text = sender.titleLabel?.text
    }
    
    @IBAction func setRightFirst(_ sender: UIButton) {
        coordinator.setTestEarOrder(isLeft: false, isBoth: true)
        lbEarOrder.text = sender.titleLabel?.text
    }
    
    @IBAction func setLeftOnly(_ sender: UIButton) {
        coordinator.setTestEarOrder(isLeft: true, isBoth: false)
        lbEarOrder.text = sender.titleLabel?.text
    }
    
    @IBAction func setRightOnly(_ sender: UIButton) {
        coordinator.setTestEarOrder(isLeft: false, isBoth: false)
        lbEarOrder.text = sender.titleLabel?.text
    }
    // MARK:
    @IBAction func addNewFreq(_ sender: UIButton) {
        updateFreqSeqLabel(coordinator.addTestFrequencyValue(sender.tag) )
    }
    
    @IBAction func removeLastFreq(_ sender: UIButton) {
        updateFreqSeqLabel(coordinator.removeLastTestFrequencyValue() )
    }
    
    @IBAction func removeAllFreq(_ sender: UIButton) {
        updateFreqSeqLabel(coordinator.removeAllTestFrequencyValues() )
    }
    
    // MARK: CoreData
    @IBAction func saveFreqSeqProtocol(_ sender: UIButton) {
        if coordinator.getFrequencyBufferCount() == 0 {
            errorPrompt(errorMsg: "There is no test frequency selected")
        } else {
            inputPrompt(promptMsg: "Please Enter Protocol Name:",
                        errorMsg: "Protocol name cannot be empty!",
                        fieldMsg: "",
                        confirmFunction: saveProtocol)
        }
    }
    
    @IBAction func loadFreqSeqProtocol(_ sender: UIButton) {
        _pickerIndex = 0

        if !coordinator.isAnyTestProtocols() {
            errorPrompt(errorMsg: "There is no saved protocol!")
        }
        else {
            pickerPrompt(confirmFunction: { () in
                self.updateFreqSeqLabel(
                        self.coordinator.loadProtocol(self._pickerIndex)
                )
            })
        }
    }

    func saveProtocol(_ protocolName: String) {
        if coordinator.isProtocolNameExisted(protocolName) {
            errorPrompt(errorMsg: "Protocol name already exists!")
            return
        }
        coordinator.saveAsNewProtocol(protocolName)
    }
    
    @IBAction func deleteFreqSeqProtocol(_ sender: UIButton) {
        if coordinator.deleteCurrentTestProtocol() {
            errorPrompt(errorMsg: "There is no selected protcol!")
        } else {
            clearFreqSeqLabel()
        }
    }
    
    @IBAction func startAdultTest(_ sender: UIButton) {
        coordinator.setIsAdult(isAdult: true)
        promptToStartTest()
    }
    
    @IBAction func startChildrenTest(_ sender: UIButton) {
        coordinator.setIsAdult(isAdult: false)
        promptToStartTest()
    }
    
    func promptToStartTest() {
        // Error, no freq selected
        if(coordinator.getFrequencyBufferCount() == 0) {
            errorPrompt(errorMsg: "There is no frequency selected!")
            return
        }
        
        // Double Textfield Prompt
        let alertCtrl = UIAlertController(
            title: "Save",
            message: "Please Enter Patient's Group & Name:",
            preferredStyle: .alert)
        
        alertCtrl.addTextField { (textField) in textField.placeholder = "Patient's Group" }
        alertCtrl.addTextField { (textField) in textField.placeholder = "Patient's Name, i.e. John Smith 1" }
        
        let confirmActionHandler = { (action: UIAlertAction) in
            if let patientGroup = alertCtrl.textFields?[0].text,
                let patientName = alertCtrl.textFields?[1].text{
                self.startTest(patientGroup, patientName)
            }
        }

        alertCtrl.addAction(UIAlertAction(title: "Confirm", style: .default, handler: confirmActionHandler))
        alertCtrl.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alertCtrl, animated: true, completion: nil)
    }
    
    func startTest(_ patientGroup: String, _ patientName: String) {
        let isAdult = coordinator.isAdult()
        do{
            guard patientGroup.count > 0 else { throw PreTestError.invalidPaientGroup }
            guard patientName.count > 0 else { throw PreTestError.invalidPatentName }

            coordinator.saveNewPatientProfile(patientGroup, patientName, lbEarOrder.text!)
            coordinator.showInstructionView(sender: nil, isAdult: isAdult)
        } catch PreTestError.invalidPaientGroup {
            errorPrompt(errorMsg: "Patient group cannot be empty!")
        } catch PreTestError.invalidPatentName {
            errorPrompt(errorMsg: "Patient name cannot be empty!")
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
        return coordinator.getTestProtocolCount()
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return coordinator.getTestProtocolName(_pickerIndex)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        _pickerIndex = row
    }
}
