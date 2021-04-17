//
//  BundleExtension.swift
//  Audiometry
//
//  Created by Xavier Chan on 17/4/21.
//  Copyright © 2021 TriCounty. All rights reserved.
//

import UIKit

private var bundleKey: UInt8 = 0

final class BundleExtension: Bundle {

     override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        return (objc_getAssociatedObject(self, &bundleKey) as? Bundle)?.localizedString(forKey: key, value: value, table: tableName) ?? super.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {

    static let once: Void = { object_setClass(Bundle.main, type(of: BundleExtension())) }()

    static func set(language: TestLanguage) {
        Bundle.once

        let isLanguageRTL = Locale.characterDirection(forLanguage: language.code) == .rightToLeft
        UIView.appearance().semanticContentAttribute = isLanguageRTL == true ? .forceRightToLeft : .forceLeftToRight

        UserDefaults.standard.set(isLanguageRTL, forKey: "AppleTextDirection")
        UserDefaults.standard.set(isLanguageRTL, forKey: "NSForceRightToLeftWritingDirection")
        UserDefaults.standard.set([language.code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()

        guard let path = Bundle.main.path(forResource: language.code, ofType: "lproj") else {
            print("Failed to get a bundle path.")
            return
        }

        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle(path: path), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

enum TestLanguage: Int {
    case english = 0
    case portuguese = 1
    case spanish = 2
}

extension TestLanguage {
    var code: String {
        switch self {
        case .english:
            return "en"
        case .portuguese:
            return "pt-BR"
        case .spanish:
            return "es-419"
        }
    }

    var name: String {
        switch self {
        case .english:
            return "English"
        case .portuguese:
            return "Português"
        case .spanish:
            return "Español"
        }
    }
}
