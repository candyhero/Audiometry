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

class PauseViewController: UIViewController {
    
    @IBOutlet weak var pbReturnToTitle: UIButton!
    @IBOutlet weak var pbContinue: UIButton!
    
    @IBOutlet weak var lbCaption: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pbReturnToTitle.setTitle(
            NSLocalizedString("Return To Title", comment: ""), for: .normal)
        pbContinue.setTitle(
            NSLocalizedString("Continue", comment: ""), for: .normal)
        
        lbCaption.text = NSLocalizedString("Pause Caption", comment: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
