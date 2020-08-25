//
//  CalibrationSetting+CoreDataClass.swift
//  Audiometry
//
//  Created by Xavier Chan on 25/8/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//
//

import Foundation
import CoreData


public class CalibrationSetting: NSManagedObject {
    
    var values: [CalibrationSettingValues] {
        set {
            calibrationSettingValues = NSOrderedSet(array: newValue)
        }
        get {
            return calibrationSettingValues?.array as! [CalibrationSettingValues]
        }
    }
}
