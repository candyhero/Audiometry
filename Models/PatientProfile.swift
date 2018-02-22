//
//  PatientProfile.swift
//  Audiometry
//
//  Created by Xavier Chan on 2/6/18.
//  Copyright © 2018 Xavier Chan. All rights reserved.
//

import RealmSwift

class PatientProfile: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var testDate: String = ""
    
    var array_testResults = List<TestResult>()
    
    override static func primaryKey() -> String? {
        return "name"
    }
}
