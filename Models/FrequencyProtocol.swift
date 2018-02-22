//
//  FrequencyProtocol.swift
//  Audiometry
//
//  Created by Xavier Chan on 2/12/18.
//  Copyright © 2018 Xavier Chan. All rights reserved.
//

import RealmSwift

class FrequencyProtocol: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var isLeft: Bool = true
    @objc dynamic var isTestBoth: Bool = true
    
    var array_freqSeq = List<Int>()
    
    override static func primaryKey() -> String? {
        return "name"
    }
}
