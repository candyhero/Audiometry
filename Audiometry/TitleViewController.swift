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

class TitleViewController: UIViewController {
    
    let ARRAY_FREQUENCY: [Double]! = [250.0, 500.0, 750.0, 1000.0, 1500.0,
                                      2000.0, 3000.0, 4000.0, 6000.0, 8000.0]

    @IBAction func startTesting(_ sender: UIButton) {
        let currentSettingKey = UserDefaults.standard.string(
            forKey: "currentSetting") ?? nil
        
        if(currentSettingKey == nil){
            
            // Prompt for user to input setting name
            let alertController = UIAlertController(
                title: "Error",
                message: "There is no calibration setting selected!", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                (_) in }
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            
            performSegue(withIdentifier: "segueMainTest", sender: nil)
        }
    }
    
    @IBAction func viewResults(_ sender: UIButton) {
        
        let result = UserDefaults.standard.string(
            forKey: "result") ?? nil
        
        if(result == nil){
            
            // Prompt for user to input setting name
            let alertController = UIAlertController(
                title: "Error",
                message: "There is no result!", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                (_) in }
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            
            performSegue(withIdentifier: "segueResultFromMenu", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        UserDefaults.standard.set(ARRAY_FREQUENCY, forKey: "freqArray")
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
