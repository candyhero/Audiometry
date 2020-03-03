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
    private var _generator: AKOperationGenerator!

    private var _startTimer, _stopTimer: Timer?

    internal var _isStarted: Bool!
    internal var _leftCorrFactor, _rightCorrFactor: Double!
    
    required init() {
        do {
            try AudioKit.stop()
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
        
        AudioKit.output = _generator
        
        do {
            _isStarted = true
            try AudioKit.start()
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
        _startTimer = Timer.scheduledTimer(
            timeInterval: 0.0,
            target: self,
            selector: #selector(start),
            userInfo: nil,
            repeats: false)
        
        _stopTimer = Timer.scheduledTimer(
            timeInterval: PULSE_TIME_ADULT * NUM_OF_PULSE_ADULT - PLAYER_STOP_DELAY,
            target: self,
            selector: #selector(stop),
            userInfo: nil,
            repeats: false)
    }
    
    func playSecondInterval() {
        let delay: Double! = PULSE_TIME_ADULT * Double(NUM_OF_PULSE_ADULT) + PLAY_GAP_TIME
        _startTimer = Timer.scheduledTimer(
            timeInterval: delay,
            target: self,
            selector: #selector(start),
            userInfo: nil,
            repeats: false)
        
        _stopTimer = Timer.scheduledTimer(
            timeInterval: delay+PULSE_TIME_ADULT*NUM_OF_PULSE_ADULT-PLAYER_STOP_DELAY,
            target: self,
            selector: #selector(stop),
            userInfo: nil,
            repeats: false)
    }
    
    @objc internal func start() {
        if(!_isStarted) {return}
        self._generator.restart()
    }
    
    @objc func stop() {
        _startTimer?.invalidate()
        _stopTimer?.invalidate()
        self._generator.stop()
    }
}

