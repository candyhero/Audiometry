//
//  GlobalSettingExtension.swift
//  Audiometry
//
//  Created by Xavier Chan on 18/4/21.
//  Copyright © 2021 TriCounty. All rights reserved.
//

import Foundation

extension GlobalSetting {

    func getTestLanguage() -> TestLanguage! {
        let rawValue = Int(testLanguageId)
        return TestLanguage(rawValue: rawValue) ?? .english
    }
}
