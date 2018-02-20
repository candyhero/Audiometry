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
    
    @objc dynamic var frequencyProtocol: FrequencyProtocol? = nil
    @objc dynamic var frequencyProtocolIndex: Int = -1
    var array_frequencyProtocols = List<FrequencyProtocol>()
    
    @objc dynamic var patientProfile: PatientProfile? = nil
    var array_patientProfiles = List<FrequencyProtocol>()
}
