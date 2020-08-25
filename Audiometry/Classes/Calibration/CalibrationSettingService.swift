//
//  CalibrationService.swift
//  Audiometry
//
//  Created by Xavier Chan on 16/5/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import Foundation
 
class CalibrationSettingService: Repository<CalibrationSetting> {
    
    static let shared: CalibrationSettingService = CalibrationSettingService()
    
    override init() {
    }
    
    func createNewSetting(name: String, values: [CalibrationSettingValues] = []) -> CalibrationSetting {
        let newSetting = CalibrationSetting(context: _managedContext)
        newSetting.name = name
        newSetting.timestamp = Date()
        newSetting.values = values
        
        do {
            try _managedContext.save()
        } catch let error as NSError {
            print("Failed to save new calibration setting")
            print(error)
        }
        return newSetting
    }
    
    func createNewSettingValues() -> CalibrationSettingValues{
        return CalibrationSettingValues(context: _managedContext)
    }
    
    func fetchAllSortedByTime() throws -> [CalibrationSetting]{
        let sortByTimestamp = NSSortDescriptor(key: #keyPath(CalibrationSetting.timestamp),
                                               ascending: false)
        return try self.fetchAll([sortByTimestamp])
    }
}
