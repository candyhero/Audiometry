//
//  CalibrationSettingValues+CoreDataClass.swift
//  Audiometry
//
//  Created by Xavier Chan on 25/8/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//
//

import Foundation
import CoreData


public class CalibrationSettingValues: NSManagedObject {
    
    var frequency: Int {
        set {
            frequencyInt16 = Int16(newValue)
        }
        get {
            return Int(frequencyInt16)
        }
    }
}

extension CalibrationSettingValues {
    
    func loadValues(from ui: CalibrationSettingValueUi) -> CalibrationSettingValues {
        frequency = ui.frequency
        expectedLevel = Double(ui.expectedLevelTextField.text!) ?? 0.0
        presentationLevel = Double(ui.presentationLevelTextField.text!) ?? 0.0
        leftMeasuredLevel = Double(ui.leftMeasuredLevelTextField.text!) ?? 0.0
        rightMeasuredLevel = Double(ui.rightMeasuredLevelTextField.text!) ?? 0.0
        return self
    }
}
