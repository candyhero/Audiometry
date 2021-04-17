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
    
    private let managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    private var globalSetting: GlobalSetting! = nil
    
    @IBOutlet weak var lbCaption: UILabel!
    @IBOutlet weak var pbContinue: UIButton!
    
    func initCaption(){
        // fetch global setting
        let request:NSFetchRequest<GlobalSetting> =
            GlobalSetting.fetchRequest()
        request.fetchLimit = 1
        
        do {
            globalSetting = try managedContext.fetch(request).first
            
        } catch let error as NSError{
            print("Could not fetch global setting.")
            print("\(error), \(error.userInfo)")
        }
        
        lbCaption.text = NSLocalizedString("Pause Caption", comment: "Instruction")
        let continueString = NSLocalizedString("Continue", comment: "Continue")
        pbContinue.setTitle(continueString, for: .normal)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initCaption()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
