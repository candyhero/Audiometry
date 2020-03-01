//
//  TestPlayer.swift
//  Audiometry
//
//  Created by Xavier Chan on 10/27/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import Foundation
import AudioKit

protocol TestPlayer {
    // correction factors in dB
    var _leftCorrFactor: Double!  { get set }
    var _rightCorrFactor: Double!  { get set }
    var _isStarted: Bool! { get set }
    
    init()
    
    func updateFreq (_ newFreq: Int!)
    func updateVolume(_ newExpectedVol: Double!, _ isLeft: Bool!)
    
    func start()
    func stop()
    
    func playFirstInterval()
    func playSecondInterval()
    
    func dbToAmp (_ dB: Double!) -> Double
}

extension TestPlayer {
    mutating func updateCorrectionFactors(_ left: Double!, _ right: Double!) {
        
        _leftCorrFactor = left
        _rightCorrFactor = right
        
        print("L.Vol.: ", left, "; R.Vol.: ", right)
    }
    
    // Covert dB to amplitude in double (0.0 to 1.0 range)
    internal func dbToAmp (_ dB: Double!) -> Double{
        
        // volume in absolute dB to be converted to amplitude
        // 1.0 amplitude <-> 0 absoulte dB
        let ampDB: Double! = dB - SYSTEM_MAX_DB
        
        let amp: Double! = pow(10.0, ampDB / 20.0)
        
        return ((amp > 1) ? 1 : amp)
    }
    
    mutating func terminate() {
        do {
            _isStarted = false
            try AudioKit.stop()
        } catch {
            print(error)
        }
    }
}

