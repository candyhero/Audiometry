//
//  Enum.swift
//  Audiometry
//
//  Created by Xavier Chan on 14/7/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

enum TestLanguage: Int {
    case Invalid = 0
    case English = 1
    case Portuguese = 2
    case Spanish = 3
    
    func toString() -> String {
        switch self {
        case .Invalid: return "Invalid"
        case .English: return "English"
        case .Portuguese: return "Portuguese"
        case .Spanish: return "Spanish"
        }
    }
}

enum TestEarOrder: Int {
    case Invalid = 0
    case LeftOnly = 1
    case RightOnly = 2
    case LeftRight = 3
    case RightLeft = 4
    
    func next() -> TestEarOrder{
        switch self {
            case .LeftRight: return .RightOnly
            case .RightLeft: return .LeftOnly
            default: return .Invalid
        }
    }
}

enum TestType: Int {
    case Invalid = 0
    case TestMode = 1
    case PracticeMode = 2
}

enum PatientType: Int {
    case Invalid = 0
    case Adult = 1
    case Children = 2
}

