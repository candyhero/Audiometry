//
//  CurrentSetting.swift
//  Audiometry
//
//  Created by Xavier Chan on 2/6/18.
//  Copyright © 2018 Xavier Chan. All rights reserved.
//

import RealmSwift

class MainSetting: Object {
    @objc dynamic var calibrationSettingIndex: Int = -1
    var array_calibrationSettings = List<CalibrationSetting>()
    
    // A sperate protocol used during testing
    @objc dynamic var frequencyTestIndex: Int = -1
    @objc dynamic var frequencyProtocol: FrequencyProtocol? = nil
    
    @objc dynamic var frequencyProtocolIndex: Int = -1
    var array_frequencyProtocols = List<FrequencyProtocol>()
    
    var array_patientProfiles = List<PatientProfile>()
}
