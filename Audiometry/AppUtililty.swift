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
                  uiCtrl: UIViewController) {
    
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

func getSortedValues(_ patient: PatientProfile) -> [PatientProfileValues]{
    let sortByFrequency = NSSortDescriptor(
        key: #keyPath(PatientProfileValues.frequency),
        ascending: true)
    let sortedValues = patient.values?.sortedArray(
        using: [sortByFrequency]) as! [PatientProfileValues]
    
    return sortedValues
}

//
func exportAllPatientsInRows(_ array_patients:[PatientProfile])->String{
    
    // Create CSV
    var csvText = ""
    
    // Top Title Bar
    csvText.append("Patient Name,")
    csvText.append("Group,")
    csvText.append("Start Time,")
    csvText.append("End Time,")
    csvText.append("Duration(sec),")
    csvText.append("Ear Test Order,")
    csvText.append("Frequency Test Order,")
    
    csvText.append("LSpam,")
    for FREQ in ARRAY_DEFAULT_FREQ{
        csvText.append("\(FREQ),")
    }
    csvText.append("RSpam,")
    for FREQ in ARRAY_DEFAULT_FREQ{
        csvText.append("\(FREQ),")
    }
    
    csvText.append("Result (L),")
    for FREQ in ARRAY_DEFAULT_FREQ{
        csvText.append("\(FREQ),")
    }
    csvText.append("Result (R),")
    for FREQ in ARRAY_DEFAULT_FREQ{
        csvText.append("\(FREQ),")
    }
    
    csvText.append("\n")
    
    // Each patient row
    for patientProfile in array_patients{
        csvText.append(extractPatientValues(patientProfile))
    }
    
    return csvText
}

fileprivate func extractPatientValues(_ patientProfile: PatientProfile) -> String {
    var csvText = ""
    csvText.append("\(patientProfile.name!),")
    csvText.append("\(patientProfile.group ?? "N/A"),")
    
    csvText.append(
        (patientProfile.timestamp != nil) ?
            "\(patientProfile.timestamp!)," : "N/A,"
    )
    csvText.append(
        (patientProfile.endTime != nil) ?
            "\(patientProfile.endTime!)," : "N/A,"
    )
    csvText.append(
        (patientProfile.durationSeconds > 0) ?
            "\(patientProfile.durationSeconds)," : "N/A,"
    )
    
    csvText.append("\(patientProfile.earOrder ?? "N/A"),")
    let str_freqOrder = patientProfile.frequencyOrder?.map{String($0)}
    csvText.append("\(str_freqOrder?.joined(separator: "->") ?? "N/A"),")
    
    
    // Prepare threshold values
    let patientProfileValues = getSortedValues(patientProfile)
    var dict_threshold_L = [Int:Int]()
    var dict_threshold_R = [Int:Int]()
    var dict_spamCount_L = [Int:Int]()
    var dict_spamCount_R = [Int:Int]()
    
    for values in patientProfileValues{
        dict_spamCount_L[Int(values.frequency)] = Int(values.spamCount_L)
        dict_spamCount_R[Int(values.frequency)] = Int(values.spamCount_R)
        
        dict_threshold_L[Int(values.frequency)] = Int(values.threshold_L)
        dict_threshold_R[Int(values.frequency)] = Int(values.threshold_R)
    }
    
    // Left Ear Spam Count
    csvText.append( ",")
    for FREQ in ARRAY_DEFAULT_FREQ{
        let spamCount_L = dict_spamCount_L[FREQ, default:0]
        csvText.append((spamCount_L > 0) ? "\(spamCount_L)," : " ,")
    }
    
    // Left Ear Spam Count
    csvText.append( ",")
    for FREQ in ARRAY_DEFAULT_FREQ{
        let spamCount_R = dict_spamCount_R[FREQ, default:0]
        csvText.append((spamCount_R > 0) ? "\(spamCount_R)," : " ,")
    }
    
    // Left Ear Frequency Thresholds
    csvText.append( ",")
    for FREQ in ARRAY_DEFAULT_FREQ{
        let threshold_L = dict_threshold_L[FREQ, default:0]
        switch threshold_L{
        case 0:
            csvText.append(",")
            break
        case -1:
            csvText.append("NR,")
            break
        default:
            csvText.append("\(threshold_L),")
        }
    }
    
    // Right Ear Frequency Thresholds
    csvText.append( ",")
    for FREQ in ARRAY_DEFAULT_FREQ{
        let threshold_R = dict_threshold_R[FREQ, default:0]
        switch threshold_R{
        case 0:
            csvText.append(",")
            break
        case -1:
            csvText.append("NR,")
            break
        default:
            csvText.append("\(threshold_R),")
        }
    }
    
    csvText.append("\n")
    return csvText
}
