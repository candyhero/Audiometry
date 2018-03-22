//
//  MenuViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 7/27/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import UIKit
import RealmSwift

class TitleViewController: UIViewController {

    private let realm = try! Realm()
    private var mainSetting: MainSetting? = nil
    
    @IBAction func startTesting(_ sender: UIButton) {

        if((mainSetting?.calibrationSettingIndex)! >= 0){
            performSegue(withIdentifier: "segueProtocolFromMenu", sender: nil)
        } else {
            // Prompt for user error
            errorPrompt(
                errorMsg: "There is no calibration setting selected!",
                uiCtrl: self)
        }
    }
    
    @IBAction func viewResults(_ sender: UIButton) {
        // Validate results
        if((mainSetting?.array_patientProfiles.count)! > 0) {
            // Display valid results in charts
            performSegue(withIdentifier: "segueResultFromMenu", sender: nil)
        } else {
            // Prompt Error
            errorPrompt(errorMsg: "There is no result!", uiCtrl: self)
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init' a new one if not already existed
        if(realm.objects(MainSetting.self).count == 0){
            
            try! realm.write {
                realm.add(MainSetting())
            }
        }
        
        // Load Setting
        mainSetting = self.realm.objects(MainSetting.self).first!
        
        // Remove last nil patient profiles
        let mostCurrentPatient = mainSetting?.array_patientProfiles.first
        
        // Validate last patient profile
        try! realm.write{
            if(mostCurrentPatient?.array_testResults.count == 0)
            {
                mainSetting?.array_patientProfiles.removeFirst()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
