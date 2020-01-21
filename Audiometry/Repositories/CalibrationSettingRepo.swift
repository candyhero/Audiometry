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
    
    func saveNewCalibrationSetting(_ settingName: String,
                                   _ valuesArray: [CalibrationSettingValues]
        ) throws -> CalibrationSetting
    {
        let setting = CalibrationSetting(context: _managedContext)
        setting.name = settingName
        setting.timestamp = Date()
        
        for values in valuesArray {
//            let values.s
        }
//        globalSetting.calibrationSetting = currentSetting
//
//        do{
//            try managedContext.save()
//        } catch let error as NSError{
//            print("Could not save calibration setting.")
//            print("\(error), \(error.userInfo)")
//        }
        
        return setting
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
}
