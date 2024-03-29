//
//  AppUtililty.swift
//  Audiometry
//
//  Created by Xavier Chan on 2/20/18.
//  Copyright © 2018 Xavier Chan. All rights reserved.
//

import Foundation
import UIKit

// Global Constants
let ARRAY_DEFAULT_FREQ: [Int] =
    [250, 500, 750, 1000, 1500, 2000, 3000, 4000, 6000, 8000]
//    [250.0, 500.0, 750.0, 1000.0, 1500.0, 2000.0, 3000.0, 4000.0, 6000.0, 8000.0]

let Z_FACTORS: [Int:Double] =
    [ 250 : 14.1,
      500 : 16.2,
     1000 : 18.5,
     2000 : 10.6,
     4000 : 15.3,
     8000 : 23.0 ]

// Calibration Setting Constants
let _DB_SYSTEM_MAX: Int! = 105 // At volume amplitude = 1.0
let _DB_SYSTEM_MIN: Int! = 0 // At volume amplitude = 0.0
let _DB_DEFAULT: Int! = 70

let _RAMP_TIME: Double! = 0.1
let _RAMP_TIMESTEP: Double! = 0.01

// Main Test Constants

let NUM_OF_PULSE_ADULT: Int! = 3
let PULSE_TIME_ADULT: Double! = 0.37

let NUM_OF_PULSE_CHILDREN: Int! = 2
let PULSE_TIME_CHILDREN: Double! = 0.5

let ATTACK_TIME: Double! = 0.035
let HOLD_TIME: Double! = 0.25
let RELEASE_TIME: Double! = 0.035

let PLAY_GAP_TIME: Double! = 0.7
let PLAYER_STOP_DELAY: Double! = 0.04

let ANIMATE_SCALE: CGFloat! = 0.8

// Global Functions
func errorPrompt(errorMsg: String,
                 uiCtrl: UIViewController) {
    
    // user did not fill field
    let alertCtrl = UIAlertController(title: "Error",
                                      message: errorMsg,
                                      preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .cancel) {(_) in }
    
    alertCtrl.addAction(cancelAction)
    
    uiCtrl.present(alertCtrl, animated: true, completion: nil)
}

func alertPrompt(alertTitle: String,
                 alertMsg: String,
                 confirmFunction: @escaping () -> Void,
                 uiCtrl: UIViewController) {
    
    // Prompt for user to input setting name
    let alertCtrl = UIAlertController(
        title: alertTitle,
        message: alertMsg,
        preferredStyle: .alert)
    
    let confirmAction = UIAlertAction(title: "Confirm", style: .default) {
        (_) in confirmFunction() }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
        (_) in }
    
    alertCtrl.addAction(confirmAction)
    alertCtrl.addAction(cancelAction)
    
    uiCtrl.present(alertCtrl, animated: true, completion: nil)
}

func inputPrompt(promptMsg: String,
                 errorMsg: String,
                 fieldMsg: String,
                 confirmFunction: @escaping (String) -> Void,
                 uiCtrl: UIViewController) {
    
    // Prompt for user to input setting name
    let alertCtrl = UIAlertController(
        title: "Save",
        message: promptMsg,
        preferredStyle: .alert)
    
    let confirmAction = UIAlertAction(title: "Confirm", style: .default) {
        (_) in
        
        if let field = alertCtrl.textFields?[0] {
            if(field.text!.count == 0) {
                errorPrompt(errorMsg: errorMsg, uiCtrl: uiCtrl)
            }
            else {
                confirmFunction(field.text!)
            }
        }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .cancel) {(_) in }
    
    alertCtrl.addTextField { (textField) in
        textField.placeholder = fieldMsg
    }
    
    alertCtrl.addAction(confirmAction)
    alertCtrl.addAction(cancelAction)
    
    uiCtrl.present(alertCtrl, animated: true, completion: nil)
}

func pickerPrompt(confirmFunction: @escaping () -> Void,
                  uiCtrl: UIViewController){
    
    let alertCtrl: UIAlertController! = UIAlertController(
        title: "Select a different setting",
        message: "\n\n\n\n\n\n\n\n\n",
        preferredStyle: .alert)
    
    let picker = UIPickerView(frame:
        CGRect(x: 0, y: 50, width: 260, height: 160))
    
    picker.delegate = uiCtrl as? UIPickerViewDelegate
    picker.dataSource = uiCtrl as? UIPickerViewDataSource
    
    alertCtrl.view.addSubview(picker)
    
    let confirmAction = UIAlertAction(title: "Confirm", style: .default) {
        (_) in
        
        confirmFunction()
    }
    
    let cancelAction = UIAlertAction(
    title: "Cancel", style: .cancel) {(_) in }
    
    alertCtrl.addAction(confirmAction)
    alertCtrl.addAction(cancelAction)
    
    uiCtrl.present(alertCtrl, animated: true, completion: nil)
}

func getSortedPatientProfileValues(_ patient: PatientProfile) -> [PatientProfileValues]{
    let sortByFrequency = NSSortDescriptor(
        key: #keyPath(PatientProfileValues.frequency),
        ascending: true)
    let sortedValues = patient.values?.sortedArray(
        using: [sortByFrequency]) as! [PatientProfileValues]
    
    return sortedValues
}
