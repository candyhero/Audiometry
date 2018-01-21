//
//  MenuViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 7/27/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import UIKit
import AudioKit
import MediaPlayer


let ARRAY_FREQ: [Double]! = [250.0, 500.0, 750.0, 1000.0, 1500.0,
                             2000.0, 3000.0, 4000.0, 6000.0, 8000.0]

let ARRAY_FREQ_DIR = ["250Hz_Bee", "500Hz_Owl", "750Hz_Dog",
                      "1000Hz_Cat", "1500Hz_Frog", "2000Hz_Mouse",
                      "3000Hz_Rattlesnake", "4000Hz_Bird",
                      "6000Hz_Cricket", "8000Hz_Bat"]

class TitleViewController: UIViewController {
    
    @IBAction func startTesting(_ sender: UIButton) {
        let currentSettingKey = UserDefaults.standard.string(
            forKey: "currentSetting") as? String
        
        if(currentSettingKey != nil){
            
            performSegue(withIdentifier: "segueFreqSelection", sender: nil)
        }
        else {
        
            // Prompt for user to input setting name
            let alertController = UIAlertController(
                title: "Error",
                message: "There is no calibration setting selected!", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                (_) in }
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func viewResults(_ sender: UIButton) {
        
        let patientProfiles = UserDefaults.standard.array(forKey: "patientProfiles") as? [String]
        
        // Validate results
        if(patientProfiles != nil) {
            // Display valid results in charts
            performSegue(withIdentifier: "segueResultFromMenu", sender: nil)
        }
        else { // Error
            
            // Prompt Error message
            let alertController = UIAlertController(
                title: "Error",
                message: "There is no result!", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                (_) in }
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func colorChange(_ sender: UIButton) {
        sender.backgroundColor = UIColor.gray
    }
    
    @IBAction func colorRevert(_ sender: UIButton) {
        sender.backgroundColor = UIColor.blue
    }
}
