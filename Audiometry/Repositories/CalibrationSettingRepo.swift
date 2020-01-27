//
//  CalibrationSettingRepo.swift
//  Audiometry
//
//  Created by Xavier Chan on 20/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit
import CoreData

class CalibrationSettingRepo {
    
    private let _managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
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
    
    func fetchAll() throws -> [CalibrationSetting] {
        // fetch all CalibrationSetting
        let request:NSFetchRequest<CalibrationSetting> =
            CalibrationSetting.fetchRequest()
        
        let sortByTimestamp = NSSortDescriptor(
            key: #keyPath(CalibrationSetting.timestamp),
            ascending: true)
        request.sortDescriptors = [sortByTimestamp]
        
        return try _managedContext.fetch(request)
    }
    
    func delete(_ setting: CalibrationSetting) throws {
        _managedContext.delete(setting)
    }
}
