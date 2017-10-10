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

class ThresholdViewController: UIViewController {

    @IBOutlet weak var lbThreshold: UILabel!
    @IBOutlet weak var lbResult: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let thresholdDB: Double! = UserDefaults.standard.double(forKey: "thresholdValue")
        
        let array_result: [Double]! = UserDefaults.standard.array(forKey: "result") as! [Double]
        
        lbThreshold.text = "Threshold DB: " + String(thresholdDB)
        lbResult.text = String(describing: array_result)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
