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
    var array_freqSeq = [Int]()
    
    var array_pbFreq = [UIButton]()
    
    let ARRAY_DEFAULT_FREQSEQ: [Double]! = [500, 4000, 1000, 8000, 250, 2000]
    
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
            
            print("Remove all freqs")
            updateLabel()
        }
    }
    
    @IBAction func loadDefaultFreq(_ sender: UIButton) {
        
        array_freqSeq = [Int]()
        
        for freq in ARRAY_DEFAULT_FREQSEQ {
            let freqID: Int! = ARRAY_FREQ.index(of: freq)
            array_freqSeq.append(freqID)
            print(array_freqSeq)
        }
        updateLabel()
    }
    
    @IBAction func startTesting(_ sender: UIButton) {
        UserDefaults.standard.set(array_freqSeq, forKey: "array_freqSeq")
        
        if(array_freqSeq.count == 0){
            
            // Prompt for user to input setting name
            let alertController = UIAlertController(
                title: "Error",
                message: "There is no frequency selected!", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                (_) in }
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            performSegue(withIdentifier: "segueMainTest", sender: nil)
        }
    }
    
    @IBAction func addNewFreq(_ sender: UIButton)
    {
        let freqID: Int! = array_pbFreq.index(of: sender)!
        
        if(array_freqSeq.contains(freqID)) {
            print("Redundant freq added")
        }
        else {
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
        
        // Setup UI
        svFreq.axis = .horizontal
        svFreq.distribution = .fillEqually
        svFreq.alignment = .center
        svFreq.spacing = 20
        
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
