//
//  AppConstants.swift
//  Audiometry
//
//  Created by Xavier Chan on 22/2/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import Foundation
import UIKit

enum TestLanguage: Int {
    case Invalid = -1
    case English = 0
    case Portuguese = 1
    case Spanish = 2
    
    func toString() -> String {
        switch self {
        case .Invalid: return "Invalid"
        case .English: return "English"
        case .Portuguese: return "Portuguese"
        case .Spanish: return "Spanish"
        }
    }
}

// Global Constants
let DEFAULT_FREQUENCIES: [Int] =
    [250, 500, 750, 1000, 1500, 2000, 3000, 4000, 6000, 8000]
//    [250.0, 500.0, 750.0, 1000.0, 1500.0, 2000.0, 3000.0, 4000.0, 6000.0, 8000.0]

let Z_FACTORS: [Int:Double] =
    [ 250 : 14.1,
      500 : 16.2,
      1000 : 18.5,
      2000 : 10.6,
      4000 : 15.3,
      8000 : 23.0 ]

// Calibration Setting Constants
let TEST_MAX_DB: Int! = 105 // At volume amplitude = 1.0
let TEST_MIN_DB: Int! = 0 // At volume amplitude = 0.0
let DEFAULT_PLAYER_DB: Int! = 70

let RAMP_TIME: Double! = 0.1
let RAMP_TIMESTEP: Double! = 0.01

// Main Test Constants

let NUM_OF_PULSE_ADULT: Int! = 3
let PULSE_TIME_ADULT: Double! = 0.37

let NUM_OF_PULSE_CHILDREN: Int! = 2
let PULSE_TIME_CHILDREN: Double! = 0.5

let ATTACK_TIME: Double! = 0.035
let HOLD_TIME: Double! = 0.25
let RELEASE_TIME: Double! = 0.035

let PLAY_GAP_TIME: Double! = 0.7
let PLAYER_STOP_DELAY: Double! = 0.04

let ANIMATE_SCALE: CGFloat! = 0.8
