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
    internal var _leftCorrFactor, _rightCorrFactor: Double!

    private var _generator: AKOperationGenerator!
    private var _startTimer, _stopTimer: Timer?


    required init() {
        do {
            try AKManager.stop()
        } catch {
            print(error)
        }

        _leftCorrFactor = 0.0
        _rightCorrFactor = 0.0
        
        _generator = AKOperationGenerator(channelCount: 2) { parameters in
            
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
        
        AKManager.output = _generator
        
        do {
            try AKManager.start()
            // Initialize / warm up player to eliminate the "first time click sound"
            // Don't remove
            updateFreq(Int(1))
            start()
            stop()
        } catch {
            print(error)
        }
    }
    
    func updateFreq (_ newFreq: Int!) {
        _generator.parameters[0] = Double(newFreq)
        _generator.parameters[1] = 0
        _generator.parameters[2] = 0
    }
    
    func updateVolume(_ newExpectedVol: Double!, _ isLeft: Bool!) {
        // Set left & right volume
        if(isLeft) {
            _generator.parameters[1] = dbToAmp(newExpectedVol + _leftCorrFactor)
        } else {
            _generator.parameters[2] = dbToAmp(newExpectedVol + _rightCorrFactor)
        }
        print(_generator.parameters[1], _generator.parameters[2])
    }

    func playFirstInterval() {
        playInterval(delay: 0.0)
    }

    func playSecondInterval() {
        playInterval(delay: PULSE_TIME_ADULT * Double(NUM_OF_PULSE_ADULT) + PLAY_GAP_TIME)
    }

    private func playInterval(delay: Double){
        _startTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false){ _ in
            self.start()
        }
        let duration = PULSE_TIME_ADULT * Double(NUM_OF_PULSE_ADULT) - PLAYER_STOP_DELAY
        _stopTimer = Timer.scheduledTimer(withTimeInterval: delay + duration, repeats: false){ _ in
            self.stop()
        }
    }
    
    internal func start() {
        _generator.restart()
    }

    internal func stop() {
        _startTimer?.invalidate()
        _stopTimer?.invalidate()
        _generator.stop()
    }
}

