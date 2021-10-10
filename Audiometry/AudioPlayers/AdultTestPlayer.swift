//
//  TestPlayer.swift
//  Audiometry
//
//  Created by Xavier Chan on 10/27/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import Foundation
import AudioKit

class AdultTestPlayer : TestPlayer {
    var generator: AKOperationGenerator!
    
    var startTimer: Timer?
    var stopTimer: Timer?
    
    var leftCorrFactor: Double!
    var rightCorrFactor: Double!
    
    required init() {
        do {
            try AKManager.stop()
        } catch {
            print(error)
        }
        
        leftCorrFactor = 0.0
        rightCorrFactor = 0.0
        
        generator = AKOperationGenerator(channelCount: 2) { parameters in
            
            let leftSine = AKOperation.sineWave(frequency: parameters[0],
                                                amplitude: parameters[1])
            let rightSine = AKOperation.sineWave(frequency: parameters[0],
                                                 amplitude: parameters[2])
            
            let clock = AKOperation.periodicTrigger(period: PULSE_TIME_ADULT)
            
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
        
        AKManager.output = generator
        
        updateFreq(Int(1))
    }
    
    func updateFreq (_ newFreq: Int!) {
        do {
            if !AKManager.engine.isRunning {
                try AKManager.start()
            }
        } catch {
            print(error)
        }
        
        // update params
        generator.parameters[0] = Double(newFreq)
        generator.parameters[1] = 0
        generator.parameters[2] = 0
        
        // force a short play to fix bug
        start()
        stop()
    }
    
    func updateVolume(_ newExpectedVol: Double!, _ isLeft: Bool!) {
        // Set left & right volume
        if(isLeft) {
            generator.parameters[1] = dbToAmp(newExpectedVol + leftCorrFactor)
        } else {
            generator.parameters[2] = dbToAmp(newExpectedVol + rightCorrFactor)
        }
        
        print(generator.parameters[1], generator.parameters[2])
    }
    
    func playFirstInterval() {
        startTimer = Timer.scheduledTimer(
            timeInterval: 0.0,
            target: self,
            selector: #selector(start),
            userInfo: nil,
            repeats: false)
        
        stopTimer = Timer.scheduledTimer(
            timeInterval: PULSE_TIME_ADULT*NUM_OF_PULSE_ADULT-PLAYER_STOP_DELAY,
            target: self,
            selector: #selector(stop),
            userInfo: nil,
            repeats: false)
    }
    
    func playSecondInterval() {
        let delay: Double! = PULSE_TIME_ADULT*Double(NUM_OF_PULSE_ADULT)+PLAY_GAP_TIME
        startTimer = Timer.scheduledTimer(
            timeInterval: delay,
            target: self,
            selector: #selector(start),
            userInfo: nil,
            repeats: false)
        
        stopTimer = Timer.scheduledTimer(
            timeInterval: delay+PULSE_TIME_ADULT*NUM_OF_PULSE_ADULT-PLAYER_STOP_DELAY,
            target: self,
            selector: #selector(stop),
            userInfo: nil,
            repeats: false)
    }
    
    @objc internal func start() {
        self.generator.restart()
    }
    
    @objc func stop() {
        startTimer?.invalidate()
        stopTimer?.invalidate()
        self.generator.stop()
    }
}

