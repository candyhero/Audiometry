//
//  CalibrationSetting.swift
//  Audiometry
//
//  Created by Xavier Chan on 2/6/18.
//  Copyright © 2018 Xavier Chan. All rights reserved.
//

import RealmSwift

class CalibrationSetting: Object {
    @objc dynamic var name: String = ""
    var array_freq = List<Int>() // Corresponding Frequencies
    
    var array_expectedDBSPL = List<Double>() // Presentation Lv
    var array_presentDBHL = List<Double>() // Presentation Lv
    var array_measuredDBSPL_L = List<Double>() // Measured Lv (L)
    var array_measuredDBSPL_R = List<Double>() // Measured Lv (R)
    
    override static func primaryKey() -> String? {
        return "name"
    }
}
