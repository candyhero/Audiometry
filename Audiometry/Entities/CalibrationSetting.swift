//
//  CalibrationSetting.swift
//  Audiometry
//
//  Created by Xavier Chan on 22/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import Foundation
import CoreData

extension CalibrationSetting {
    
    func getSortedValues() -> [CalibrationSettingValues] {
        let sortByFreq = NSSortDescriptor(
            key: #keyPath(CalibrationSettingValues.frequency),
            ascending: true)
        return self.values?.sortedArray(using: [sortByFreq]) as! [CalibrationSettingValues]
    }
    
    func getDictionary() -> [Int: CalibrationSettingValues] {
        return self.values?.reduce(into: [Int: CalibrationSettingValues]()){
            (dict, v) in
            let v2 = v as! CalibrationSettingValues
            dict[Int(v2.frequency)] = v2
        } ?? [Int: CalibrationSettingValues] ()
    }
}
