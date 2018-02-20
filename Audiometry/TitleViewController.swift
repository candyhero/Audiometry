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
            performSegue(withIdentifier: "segueFreqSelection", sender: nil)
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
            // Error
            errorPrompt(errorMsg: "There is no result!",
                        uiCtrl: self)
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
