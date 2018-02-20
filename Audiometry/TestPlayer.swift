//
//  TestPlayer.swift
//  Audiometry
//
//  Created by Xavier Chan on 10/27/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import Foundation
import AudioKit

class TestPlayer {
    let DB_SYSTEM_MAX: Double! = 105.0
    
    var generator: AKOperationGenerator! = nil
    var timer: Timer?
    
    // correction factors in dB
    var leftCorrFactor: Double!
    var rightCorrFactor: Double!
    
    init() {
        //*******************
        // Setup oscillator player which generates pure tones
        //*******************
        
        // generator to be configured by setting generator.parameter
        // param
        
        generator = AKOperationGenerator(numberOfChannels: 2) { parameters in
            
            let leftSine = AKOperation.sineWave(frequency: parameters[0],
                                                amplitude: parameters[1])
            let rightSine = AKOperation.sineWave(frequency: parameters[0],
                                                 amplitude: parameters[2])
            
            let clock = AKOperation.periodicTrigger(period: PULSE_TIME)

            let leftOutput = leftSine.triggeredWithEnvelope(
                trigger: clock,
                attack: ATTACK_TIME,
                hold: HOLD_TIME,
                release: RELEASE_TIME)

            let rightOutput = rightSine.triggeredWithEnvelope(
                trigger: clock,
                attack: ATTACK_TIME,
                hold: HOLD_TIME,
                release: RELEASE_TIME)

            return [leftOutput, rightOutput]
        }
        
        AudioKit.output = generator
        AudioKit.start()
    }
    
    func updateFreq (_ newFreq: Double!) {
        
        self.generator.parameters[0] = newFreq
//        print(newFreq)
    }
    
    func updateCorrectionFactors(_ left: Double!, _ right: Double!) {
        
        self.leftCorrFactor = left
        self.rightCorrFactor = right
        
//        print(left, right)
    }
    
    func updatePlayerVolume(_ newExpectedVol: Double!) {
        
        //        print(leftCorrectionFactor)
        //        print(rightCorrectionFactor)
        
        // Set left & right volume
        self.generator.parameters[1] = self.dbToAmp(
            newExpectedVol + leftCorrFactor)
        self.generator.parameters[2] = self.dbToAmp(
            newExpectedVol + rightCorrFactor)
        
//        print(newExpectedVol)
    }
    
    func play() {
        self.generator.start()
        
        timer = Timer.scheduledTimer(timeInterval: PULSE_TIME * NUM_OF_PULSE,
                             target: self,
                             selector: #selector(stop),
                             userInfo: nil,
                             repeats: false)
    }
    
    @objc func stop() {
        self.generator.stop()
    }
    
    // Covert dB to amplitude in double (0.0 to 1.0 range)
    func dbToAmp (_ dB: Double!) -> Double{
        
        // volume in absolute dB to be converted to amplitude
        // 1.0 amplitude <-> 0 absoulte dB
        let ampDB: Double! = dB - DB_SYSTEM_MAX
        
        let amp: Double! = pow(10.0, ampDB / 20.0)
        
        return ((amp > 1) ? 1 : amp)
    }
}
