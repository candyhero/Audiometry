//
//  GlobalSetting+CoreDataClass.swift
//  Audiometry
//
//  Created by Xavier Chan on 25/8/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//
//

import Foundation
import CoreData


public class GlobalSetting: NSManagedObject {
    
    var testLanguage: TestLanguage! {
        set {
            testLanguageInt16 = Int16(newValue.rawValue)
        }
        get {
            return TestLanguage(rawValue: Int(testLanguageInt16)) ?? .Invalid
        }
    }
}

extension GlobalSetting {
    
    
}

