//
//  CalibrationService.swift
//  Audiometry
//
//  Created by Xavier Chan on 16/5/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import Foundation
import CoreData
 
class CalibrationSettingService: Repository<CalibrationSetting> {
    
    static let shared: CalibrationSettingService = CalibrationSettingService()
    
    override init() {
    }
    
    func createNewSetting(name: String, values: [CalibrationSettingValues] = []) -> CalibrationSetting {
        let newSetting = CalibrationSetting(context: _managedContext)
        newSetting.name = name
        newSetting.timestamp = Date()
        
        for v in values {
            newSetting.addToValues(v)
        }
        
        do {
            try _managedContext.save()
        } catch let error as NSError {
            print("Failed to save new calibration setting")
            print(error)
        }
        return newSetting
    }
    
    func createNewSettingValues(frequency: Int) -> CalibrationSettingValues{
        let newSettingValues = CalibrationSettingValues(context: _managedContext)
        newSettingValues.frequency = Int16(frequency)
        return newSettingValues
    }
    
    func fetchAllSortedByTime() throws -> [CalibrationSetting]{
        let sortByTimestamp = NSSortDescriptor(key: #keyPath(CalibrationSetting.timestamp),
                                               ascending: false)
        return try self.fetchAll([sortByTimestamp])
    }
}
