//
//  ViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 11/21/18.
//  Copyright © 2018 TriCounty. All rights reserved.
//

import UIKit
import CoreData
import AudioKit

class TitleViewController: UIViewController {
    
    private var globalSetting: GlobalSetting! = nil
    
    private let managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    @IBAction func startTesting(_ sender: Any) {
        if(globalSetting.calibrationSetting != nil){
            performSegue(withIdentifier: "segueProtocolFromTitle", sender: nil)
        } else {
            // Prompt for user error
            errorPrompt(
                errorMsg: "There is no calibration setting selected!",
                uiCtrl: self)
        }
    }
    
    @IBAction func viewResults(_ sender: UIButton) {
        // fetch all PatientProfiles
        let patientRequest:NSFetchRequest<PatientProfile> =
            PatientProfile.fetchRequest()
        
        do {
            var profiles = try managedContext.fetch(patientRequest)
            for emptyProfile in profiles.filter({$0.values?.count == 0}){
                managedContext.delete(emptyProfile)
            }
            profiles.removeAll(where: {$0.values?.count == 0})
            
            if (profiles.count > 0){
                performSegue(withIdentifier: "segueResultFromTitle", sender: nil)
            } else {
                // Prompt for user error
                errorPrompt(
                    errorMsg: "There is no result!",
                    uiCtrl: self)
            }
        } catch let error as NSError{
            print("Could not fetch patient profiles.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        do {
            try AudioKit.stop()
        } catch let error as NSError {
            print("gg")
        }
        
        // fetch all CalibrationSetting
        let request:NSFetchRequest<GlobalSetting> =
            GlobalSetting.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let settings = try managedContext.fetch(request)
            if (settings.count == 0){
                globalSetting = NSEntityDescription.insertNewObject(
                    forEntityName: "GlobalSetting",
                    into: managedContext) as? GlobalSetting
                do{
                    try managedContext.save()
                } catch let error as NSError{
                    print("Could not save global setting.")
                    print("\(error), \(error.userInfo)")
                }
            } else {
                globalSetting = settings.first
            }
        } catch let error as NSError{
            print("Could not fetch global setting.")
            print("\(error), \(error.userInfo)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

