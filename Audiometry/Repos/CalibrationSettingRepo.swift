//
//  CalibrationSettingRepo.swift
//  Audiometry
//
//  Created by Xavier Chan on 20/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit
import CoreData

class CalibrationSettingRepo: IRepository<CalibrationSetting> {
    
    static let repo = CalibrationSettingRepo()
    
    func createNew(_ settingName: String,
                   _ dict_settingUI: [Int: CalibrationSettingUI]) -> CalibrationSetting {
        let newSetting = CalibrationSetting(context: _managedContext)
        newSetting.name = settingName
        newSetting.timestamp = Date()
        
        for (freq, settingUI) in dict_settingUI {
            let newValues = CalibrationSettingValues(context: _managedContext)
            newValues.frequency = Int16(freq)
            settingUI.extractValuesInto(newValues)
            newSetting.addToValues(newValues)
        }
        
        return newSetting
    }
    
    func fetchAllSorted() throws -> [CalibrationSetting] {
        let sortByTimestamp = NSSortDescriptor(
            key: #keyPath(CalibrationSetting.timestamp),
            ascending: true)
        return try self.fetchAll([sortByTimestamp])
    }
}
