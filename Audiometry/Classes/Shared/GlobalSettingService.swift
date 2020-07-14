//
//  GlobalSettingService.swift
//  Audiometry
//
//  Created by Xavier Chan on 24/6/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import Foundation
import CoreData
 
class GlobalSettingService: Repository<GlobalSetting> {
    
    static let shared: GlobalSettingService = GlobalSettingService()
    
    override init() {
        super.init()
        guard let _ = try? fetchAll().first else{
            let globalSetting = GlobalSetting(context: _managedContext)
            globalSetting.testLanguage = Int16(TestLanguage.English.rawValue)
            
            try? _managedContext.save()
            
            return
        }
    }
    
    func fetch() throws -> GlobalSetting {
        return try fetchAll().first!
    }
    
    func updateCalibrationSetting(calibrationSetting: CalibrationSetting?) {
        do {
            let globalSetting = try fetch()
            globalSetting.calibrationSetting = calibrationSetting
            try _managedContext.save()
        } catch {
            print("Failed to update global setting")
        }
    }
    
    func updateTestLanguage(testLanguage: TestLanguage) {
        do {
            let globalSetting = try fetch()
            globalSetting.testLanguage = Int16(testLanguage.rawValue)
            try _managedContext.save()
        } catch {
            print("Failed to update global setting")
        }
    }
    
}
