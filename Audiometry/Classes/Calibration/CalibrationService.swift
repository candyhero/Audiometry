//
//  CalibrationService.swift
//  Audiometry
//
//  Created by Xavier Chan on 16/5/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
 
class CalibrationService: Repository<CalibrationSetting> {
    
    static let shared: CalibrationService = CalibrationService()
    
    override init() {
        
    }
    func createNew(name: String, values: [CalibrationSettingValues]) -> CalibrationSetting {
        let newSetting = CalibrationSetting(context: _managedContext)
        newSetting.name = name
        newSetting.timestamp = Date()
        
        for v in values {
//            let newValues = CalibrationSettingValues(context: _managedContext)
            newSetting.addToValues(v)
        }
        return newSetting
    }
    
    func fetchAllSortedByTime() -> Single<[CalibrationSetting]> {
        let sortByTimestamp = NSSortDescriptor(key: #keyPath(CalibrationSetting.timestamp),
                                               ascending: true)
        return Single.create { (single) -> Disposable in
            do {
                let settings = try self.fetchAll([sortByTimestamp])
                print(settings)
                single(.success(settings))
            } catch { }
            
            return Disposables.create()
        }
    }
}
