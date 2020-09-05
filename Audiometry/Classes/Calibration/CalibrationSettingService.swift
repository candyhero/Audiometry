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
    
    func createNewSetting(name: String, from requests: [CalibrationSettingValuesRequest]) -> CalibrationSetting {
        let newSetting = CalibrationSetting(context: _managedContext)
        newSetting.name = name
        newSetting.timestamp = Date()
        
        newSetting.values = requests.map {
            return CalibrationSettingValues(context: _managedContext).loadValues(from: $0)
        }
        
        do {
            try _managedContext.save()
        } catch let error as NSError {
            print("Failed to save new calibration setting")
            print(error)
        }
        return newSetting
    }
    
    func updateSettingValues(setting: CalibrationSetting, from requests: [CalibrationSettingValuesRequest]) -> CalibrationSetting {
        // update setting values here
        return setting
    }
    
    func fetchAllSortedByTime() throws -> [CalibrationSetting]{
        let sortByTimestamp = NSSortDescriptor(key: #keyPath(CalibrationSetting.timestamp),
                                               ascending: false)
        return try self.fetchAll([sortByTimestamp])
    }
}
