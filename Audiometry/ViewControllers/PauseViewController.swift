//
//  PauseViewController.swift
//  Audiometry
//
//  Created by Xavier on 31/7/19.
//  Copyright © 2019 TriCounty. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class PauseViewController: UIViewController, Storyboarded {

    var coordinator: TestCoordinator! = AppDelegate.testCoordinator

    @IBOutlet weak var lbCaption: UILabel!
    @IBOutlet weak var pbContinue: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbCaption.text = "Great job! Half way done!"
        pbContinue.setTitle("Continue", for: .normal)
    }
    
    @IBAction func backToTitle(_ sender: UIButton) {
        coordinator.backToTitle()
    }
    
    @IBAction func continueToTest(_ sender: UIButton) {
        coordinator.back()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
