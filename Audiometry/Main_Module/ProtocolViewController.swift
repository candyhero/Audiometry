//
//  FreqSelectionViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 10/31/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import UIKit
import RealmSwift

class ProtocolViewController: UIViewController {
    
    // play sequence track list
    private let realm = try! Realm()
    private var mainSetting: MainSetting? = nil
    private var currentProtocol: FrequencyProtocol? = nil
    
    private var array_pbFreq = [UIButton]()
    private var _currentPickerIndex: Int!
    
    private let ARRAY_DEFAULT_FREQSEQ: [Double]! = [500, 4000, 1000, 8000, 250, 2000]
    
    @IBOutlet weak var svFreq: UIStackView!
    @IBOutlet weak var lbFreqSeq: UILabel!
    @IBOutlet weak var lbEarOrder: UILabel!
    
    // -------
    //  Label update functions
    // -------
    @IBAction func addNewFreq(_ sender: UIButton){
        let freqID: Int! = sender.tag
        
        if(!(currentProtocol?.array_freqSeq.contains(freqID))!) {
            
            try! realm.write{
                currentProtocol?.array_freqSeq.append(freqID)
            }
            updateLabel()
        }
    }
    
    @IBAction func removeLastFreq(_ sender: UIButton) {
        if((currentProtocol?.array_freqSeq.count)! > 0){
            
            try! realm.write{
                currentProtocol?.array_freqSeq.removeLast()
            }
            updateLabel()
        }
    }
    
    @IBAction func removeAllFreq(_ sender: UIButton) {
        if((currentProtocol?.array_freqSeq.count)! > 0){
            
            try! realm.write{
                currentProtocol?.array_freqSeq.removeAll()
            }
            updateLabel()
        }
    }
    
    func updateLabel(){
        
        var tempFreqSeqStr = String("Test Sequence: ")
        
        for i in 0..<(currentProtocol?.array_freqSeq.count)! {
            
            let freqID: Int! = currentProtocol?.array_freqSeq[i]
            tempFreqSeqStr.append(array_pbFreq[freqID].currentTitle!)
            tempFreqSeqStr.append(" ► ")
            
            if(i == 4){
                tempFreqSeqStr.append("\n")
            }
        }
        
        if((currentProtocol?.array_freqSeq.count)! == 0){
            tempFreqSeqStr.append("None")
        }
        
        lbFreqSeq.text! = tempFreqSeqStr
    }
    
    // ------
    //  Protocol update functions
    // ------
    @IBAction func saveFreqSeqProtocol(_ sender: UIButton) {
    
        // Prompt for no freq selected error
        if((currentProtocol?.array_freqSeq.count)! == 0)
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
        if(isProtocolExisted(newProtocolName) ){
            errorPrompt(
                errorMsg: "Protocol name already exists!",
                uiCtrl: self)
            return
        }
        
        // Else, save protocol
        try! self.realm.write {
            let newProtocol = FrequencyProtocol()
            
            newProtocol.name = newProtocolName
            newProtocol.isTestBoth = (currentProtocol?.isTestBoth)!
            newProtocol.isLeft = (currentProtocol?.isLeft)!
            
            for freqID in (currentProtocol?.array_freqSeq)! {
                newProtocol.array_freqSeq.append(freqID)
            }
            
            let newID = mainSetting?.array_frequencyProtocols.count
            mainSetting?.frequencyProtocolIndex = newID!
            mainSetting?.array_frequencyProtocols.append(newProtocol)
        }
    }
    
    @IBAction func loadFreqSeqProtocol(_ sender: UIButton) {
        
        if (mainSetting?.array_frequencyProtocols.count)! > 0 {
            _currentPickerIndex =
                (mainSetting?.array_frequencyProtocols.count)! - 1
            pickerPrompt(confirmFunction: loadProtocol,
                         uiCtrl: self)
        }
        else {
            errorPrompt(errorMsg: "There is no saved protcol!",
                        uiCtrl: self)
        }
    }
    
    func loadProtocol(){
        let targetProtocol = mainSetting?.array_frequencyProtocols[_currentPickerIndex]
        
        try! realm.write {
            mainSetting?.frequencyProtocolIndex = _currentPickerIndex
//            currentProtocol?.isLeft = (targetProtocol?.isLeft)!
//            currentProtocol?.isTestBoth = (targetProtocol?.isTestBoth)!
            currentProtocol?.array_freqSeq.removeAll()
            
            for freqID in (targetProtocol?.array_freqSeq)! {
                currentProtocol?.array_freqSeq.append(freqID)
            }
        }
        updateLabel()
    }
    
    @IBAction func deleteFreqSeqProtocol(_ sender: UIButton) {
        
        // Validate current protocol
        if((mainSetting?.frequencyProtocolIndex)! < 0) {
            
            errorPrompt(errorMsg: "There is no selected protcol!",
                        uiCtrl: self)
            return
        }
        
        // Delete the protocol from both list and dict
        try! realm.write {
            let currentID = mainSetting?.frequencyProtocolIndex
            let targetProtocol = mainSetting?.array_frequencyProtocols[currentID!]
            
            mainSetting?.array_frequencyProtocols.remove(at: currentID!)
            mainSetting?.frequencyProtocolIndex = -1
            
            realm.delete(targetProtocol!)
        }
        
        updateLabel()
    }
    
    func isProtocolExisted(_ protocolName: String) -> Bool{
        
        return (mainSetting?.array_frequencyProtocols.filter("name = %@", protocolName).count)! > 0
    }
    
    
    // ------
    //  Test-related functions
    // ------
    @IBAction func setLeftFirst(_ sender: UIButton) {
        try! realm.write {
            mainSetting?.frequencyProtocol?.isLeft = true
            mainSetting?.frequencyProtocol?.isTestBoth = true
        }
        lbEarOrder.text = sender.titleLabel?.text!
    }
    
    @IBAction func setRightFirst(_ sender: UIButton) {
        try! realm.write {
            mainSetting?.frequencyProtocol?.isLeft = false
            mainSetting?.frequencyProtocol?.isTestBoth = true
        }
        lbEarOrder.text = sender.titleLabel?.text!
    }
    
    @IBAction func setLeftOnly(_ sender: UIButton) {
        try! realm.write {
            mainSetting?.frequencyProtocol?.isLeft = true
            mainSetting?.frequencyProtocol?.isTestBoth = false
        }
        lbEarOrder.text = sender.titleLabel?.text!
    }
    
    @IBAction func setRightOnly(_ sender: UIButton) {
        try! realm.write {
            mainSetting?.frequencyProtocol?.isLeft = false
            mainSetting?.frequencyProtocol?.isTestBoth = false
        }
        lbEarOrder.text = sender.titleLabel?.text!
    }
    
    @IBAction func startPracticeTest(_ sender: UIButton) {
        startTesting(isPracticeMode: true)
    }
    
    @IBAction func startMainTest(_ sender: UIButton) {
        startTesting(isPracticeMode: false)
    }
    
    func startTesting(isPracticeMode: Bool!) {
        
        // Error, no freq selected
        if(currentProtocol?.array_freqSeq.count == 0){
            errorPrompt(errorMsg: "There is no frequency selected!",
                        uiCtrl: self)
            return
        }
        
        // For practice mode validation
        if(isPracticeMode && (currentProtocol?.array_freqSeq.count)! > 1) {
            
            errorPrompt(
                errorMsg: "Only one frequency can be tested under practice mode!",
                uiCtrl: self)
            return
        }
        
        // Prompt for user to input setting name
        inputPrompt(promptMsg: "Please Enter Patient's Name:",
                    errorMsg: "Patient name cannot be empty!",
                    fieldMsg: "i.e. John Smith 1",
                    confirmFunction: {(patientName: String) -> Void in
                        self.savePatientProfile(patientName)
                        self.performSegue(withIdentifier: "segueMainTest",
                                          sender: isPracticeMode)},
                    uiCtrl: self)
        
    }
    
    func savePatientProfile(_ patientName: String) {
        // Format date
        let date = NSDate();
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        let localDate = dateFormatter.string(from: date as Date)
        
        // Prepare new profile to test
        let newPatientProfile = PatientProfile()
        newPatientProfile.name = patientName + ": " + localDate
        newPatientProfile.testDate = localDate
        
        try! realm.write {
            mainSetting?.frequencyTestIndex = 0
            mainSetting?.array_patientProfiles.insert(newPatientProfile, at: 0)
        }
        
        // Test Seq saved in main setting
        // Load & save calibration setting during testing for each frequency
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueMainTest" {
            if let testViewController = segue.destination as? TestViewController {
                testViewController.flag_practiceMode = sender as! Bool
            }
        }
    }
    
    // Init' function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try! realm.write {
            // Load Setting
            mainSetting = realm.objects(MainSetting.self).first
            
            if(mainSetting?.frequencyProtocol == nil)
            {
                mainSetting?.frequencyProtocol = FrequencyProtocol()
            }
            
            currentProtocol = mainSetting?.frequencyProtocol
            
            currentProtocol?.array_freqSeq.removeAll()
            
            currentProtocol?.isTestBoth = true
            currentProtocol?.isLeft = true
            lbEarOrder.text! = "L. Ear -> R. Ear"
        }
        
        setupUI()
        updateLabel()
    }
    
    func setupUI(){
        svFreq.axis = .horizontal
        svFreq.distribution = .fillEqually
        svFreq.alignment = .center
        svFreq.spacing = 15
        
        lbFreqSeq.textAlignment = .center
        lbFreqSeq.numberOfLines = 0
        
        for i in 0..<ARRAY_DEFAULT_FREQ.count {
            // Set up buttons
            let new_pbFreq = UIButton(type:.system)
            
            new_pbFreq.bounds = CGRect(x:0, y:0, width:300, height:300)
            new_pbFreq.setTitle(String(ARRAY_DEFAULT_FREQ[i])+" Hz", for: .normal)
            new_pbFreq.backgroundColor = UIColor.gray
            new_pbFreq.setTitleColor(UIColor.white, for: .normal)
            new_pbFreq.tag = i
            
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

extension ProtocolViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return (mainSetting?.array_frequencyProtocols.count)!
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        let count = (mainSetting?.array_frequencyProtocols.count)!
        return mainSetting?.array_frequencyProtocols[count - row - 1].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        let count = (mainSetting?.array_frequencyProtocols.count)!
        _currentPickerIndex = count - row - 1
    }
}
