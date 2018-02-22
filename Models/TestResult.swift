//
//  TestResult.swift
//  Audiometry
//
//  Created by Xavier Chan on 2/6/18.
//  Copyright © 2018 Xavier Chan. All rights reserved.
//

import RealmSwift

class TestResult: Object {
    @objc dynamic var freq: Int = 0
    
    @objc dynamic var thresholdDB_L: Double = 0
    var array_trackingDB_L = List<Double>()
    
    @objc dynamic var thresholdDB_R: Double = 0
    var array_trackingDB_R = List<Double>()
    
    @objc dynamic var expectedDBSPL: Double = 0.0
    @objc dynamic var presentDBHL: Double = 0.0
    @objc dynamic var measuredDBSPL_L: Double = 0.0
    @objc dynamic var measuredDBSPL_R: Double = 0.0
}
