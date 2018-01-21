//
//  FreqSelectionViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 10/31/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import UIKit

import Foundation

class FreqSelectionViewController: UIViewController {
    
    // play sequence track list
    private var array_freqSeq = [Int]() // Current Procotol
    private var array_pbFreq = [UIButton]()
    private var array_protocolList: [String]!
    private var dict_protocols: [String: [Int]]!
    private var _currentProtocol: Int! = -1
    private var _currentSelection: Int! = 0
    
    private let ARRAY_DEFAULT_FREQSEQ: [Double]! = [500, 4000, 1000, 8000, 250, 2000]
    
    @IBOutlet weak var svFreq: UIStackView!
    
    @IBOutlet weak var lbFreqSeq: UILabel!
    
    @IBAction func removeLastFreq(_ sender: UIButton) {
        if(array_freqSeq.count > 0){
            let removeID = array_freqSeq.popLast()
            updateLabel()
        }
    }
    
    @IBAction func removeAllFreq(_ sender: UIButton) {
        if(array_freqSeq.count > 0){
            array_freqSeq = [Int]()
            
            updateLabel()
        }
    }
    
    @IBAction func saveFreqSeqProtocol(_ sender: UIButton) {
    
        if(array_freqSeq.count == 0)
        {
            // Prompt for no freq selected error
            let alertController = UIAlertController(
                title: "Error",
                message: "There is no frequency selected!", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                (_) in }
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // Prompt for user to input protocol name
        let alertController = UIAlertController(
            title: "Save Freq Protocol",
            message: "Please Enter Protocol Name:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) {
            (_) in
            
            if let field = alertController.textFields?[0] {
                
                let protocolName = field.text!
                
                // If duplicated name
                if(self.array_protocolList.contains(protocolName))
                {
                    // Prompt for no freq selected error
                    let alertController = UIAlertController(
                        title: "Error",
                        message: "A duplicated protocol already existed.\nPlease save again with a different name.", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                        (_) in }
                    
                    alertController.addAction(cancelAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                // Else, save protocol
                self._currentProtocol = self.array_protocolList.count
                self.array_protocolList.append(protocolName)
                self.dict_protocols[protocolName] = self.array_freqSeq
                
                // Save user name and the test seq
                UserDefaults.standard.set(self.array_protocolList, forKey: "array_protocolList")
                UserDefaults.standard.set(self.dict_protocols, forKey: "dict_protocols")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = ""
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func loadFreqSeqProtocol(_ sender: UIButton) {
        
        // Prompt user protocol pickerview
        let alertController: UIAlertController!
        
        if array_protocolList!.count > 0 {
            
            alertController = UIAlertController(
                title: "Select a different setting",
                message: "\n\n\n\n\n\n\n\n\n",
                preferredStyle: .alert)
            
            let picker = UIPickerView(frame:
                CGRect(x: 0, y: 50, width: 260, height: 160))
            
            picker.delegate = self
            picker.dataSource = self
            
            alertController.view.addSubview(picker)
            
            let confirmAction = UIAlertAction(
            title: "Confirm", style: .default) {(_) in
                
                self._currentProtocol = self._currentSelection
                
                let protocolName = self.array_protocolList[self._currentSelection]
                self.array_freqSeq = self.dict_protocols[protocolName]!
                
                self.updateLabel()
            }
            
            alertController.addAction(confirmAction)
        }
        else {
            
            alertController = UIAlertController(
                title: "Error",
                message: "There is no saved protcol!",
                preferredStyle: .alert)
        }
        
        let cancelAction = UIAlertAction(
        title: "Cancel", style: .cancel) {(_) in }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteFreqSeqProtocol(_ sender: UIButton) {
        
        // Validate current protocol
        if(_currentProtocol < 0) {
            
            // Error case
            let alertController = UIAlertController(
                title: "Error",
                message: "There is no selected protcol!",
                preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(
            title: "Cancel", style: .cancel) {(_) in }
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // Delete the protocol from both list and dict
        let protocolName = array_protocolList[_currentProtocol]
        
        array_protocolList.remove(at: _currentProtocol)
        dict_protocols.removeValue(forKey: protocolName)
        
        // Nullify current protocol
        _currentProtocol = -1

        // Save user name and the test seq
        UserDefaults.standard.set(array_protocolList, forKey: "array_protocolList")
        UserDefaults.standard.set(dict_protocols, forKey: "dict_protocols")
    }
    
    @IBAction func startPracticeTest(_ sender: UIButton) {
        startTesting(true)
    }
    
    @IBAction func startMainTest(_ sender: UIButton) {
        startTesting(false)
    }
    
    func startTesting(_ isPracticeMode: Bool!) {
        
        // Error, no freq selected
        if(array_freqSeq.count == 0){
            
            let alertController = UIAlertController(
                title: "Error",
                message: "There is no frequency selected!", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                (_) in }
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // For practice mode validation
        if(isPracticeMode && (array_freqSeq.count > 1)) {
            
            // Prompt for user to input patient name
            let alertController = UIAlertController(
                title: "Error",
                message: "Only one frequency can be tested under practice mode!", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                (_) in }
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // Prompt for user to input setting name
        let alertController = UIAlertController(
            title: "Save Patient Profile",
            message: "Please Enter Patient's Name:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) {
            (_) in
            
            if let field = alertController.textFields?[0] {
                
                let date = NSDate();
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                
                let localDate = dateFormatter.string(from: date as Date)
                
                let patientName = field.text! + ", " + localDate
                
                // Save user name and the test seq
                UserDefaults.standard.set(patientName, forKey: "patientName")
                UserDefaults.standard.set(self.array_freqSeq, forKey: "array_freqSeq")
                
                self.performSegue(withIdentifier: "segueMainTest", sender: isPracticeMode)
            }
            else {
                // user did not fill field
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "i.e. John Smith 1"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueMainTest" {
            if let testViewController = segue.destination as? TestViewController {
                testViewController.flag_practiceMode = sender as! Bool
            }
        }
    }
    
    @IBAction func addNewFreq(_ sender: UIButton)
    {
        let freqID: Int! = array_pbFreq.index(of: sender)!
        
        if(!array_freqSeq.contains(freqID)) {
            
            array_freqSeq.append(freqID)
            updateLabel()
        }
    }
    
    func updateLabel()
    {
        var tempFreqSeqStr = String("Test Sequence: ")
        
        for i in 0..<array_freqSeq.count {
            
            let freqID: Int! = array_freqSeq[i]
            tempFreqSeqStr.append(array_pbFreq[freqID].currentTitle!)
            tempFreqSeqStr.append(" ► ")
            
            if(i == 4){
                tempFreqSeqStr.append("\n")
            }
        }
        
        if(array_freqSeq.count == 0){
            
            tempFreqSeqStr.append("None")
        }
        
        lbFreqSeq.text! = tempFreqSeqStr
    }
    
    // Init' function
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Load protocol list
        array_protocolList = UserDefaults.standard.array(forKey: "array_protocolList") as? [String]
        
        dict_protocols = UserDefaults.standard.dictionary(forKey: "dict_protocols") as? [String: [Int]]
        
        // If there is no protocol list yet
        if(array_protocolList == nil){
            array_protocolList = [String]()
            dict_protocols = [String: [Int]]()
        }
        
        // Setup UI
        svFreq.axis = .horizontal
        svFreq.distribution = .fillEqually
        svFreq.alignment = .center
        svFreq.spacing = 15
        
        lbFreqSeq.textAlignment = .center
        lbFreqSeq.numberOfLines = 0
        
        for i in 0..<ARRAY_FREQ.count {
            // Set up buttons
            
            let new_pbFreq = UIButton(type:.system)
            
            new_pbFreq.bounds = CGRect(x:0, y:0, width:300, height:300)
            new_pbFreq.setTitle(String(ARRAY_FREQ[i])+" Hz", for: .normal)
            new_pbFreq.backgroundColor = UIColor.gray
            new_pbFreq.setTitleColor(UIColor.white, for: .normal)
            
            
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if(segue.identifier == "segueMainTest") {
//            if let mainTest = segue.destination as? TestViewController {
//                mainTest.setFreqSeq(sender as? [Int])
//            }
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FreqSelectionViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return array_protocolList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return array_protocolList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        _currentSelection = row
    }
}
