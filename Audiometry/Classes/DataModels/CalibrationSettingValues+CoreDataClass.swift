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
    func loadValues(from request: CalibrationSettingValuesRequest) -> CalibrationSettingValues {
        frequency = request.frequency
        expectedLevel = request.expectedLevel
        presentationLevel = request.presentationLevel
        leftMeasuredLevel = request.leftMeasuredLevel
        rightMeasuredLevel = request.rightMeasuredLevel
        return self
    }
}
