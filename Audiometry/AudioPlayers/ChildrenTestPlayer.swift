//
//  ChildrenTestPlayer.swift
//  Audiometry
//
//  Created by Xavier Chan on 12/11/18.
//  Copyright © 2018 TriCounty. All rights reserved.
//

import Foundation
import AudioKit

class ChildrenTestPlayer : TestPlayer {
    internal var _leftCorrFactor, _rightCorrFactor: Double!

    private var _file: AKAudioFile!
    private var _player: AKPlayer!
    private var _adsrEnvelope: AKAmplitudeEnvelope!
    private var _delay: AKDelay!

    private var _zFactor: Double!
    private var _currentVolume: Double!
    private var _isLeft: Bool!

    private var startTimer, startTimer2, stopTimer: Timer?
    
    required init() {
        do {
            try AKManager.stop()
        } catch {
            print(error)
        }
        
        _leftCorrFactor = 0.0
        _rightCorrFactor = 0.0
        
        do {
            _file = try AKAudioFile(readFileName: "\(ANIMAL_TONE_PATH)/250Hz.wav")
        } catch {
            print(error)
            return
        }
        
        _player = AKPlayer(audioFile: _file)
        AKManager.output = _player
        
        do {
            try AKManager.start()
        } catch {
            print(error)
        }
    }
    
    func updateFreq (_ newFreq: Int!) {
        do {
            _zFactor = Z_FACTORS[newFreq] ?? 0.0
            let path = "\(ANIMAL_TONE_PATH)/\(newFreq!)Hz.wav"
            let file = try AKAudioFile(readFileName: path)
            try _player.load(audioFile: file)
            _player.endTime = PULSE_TIME_CHILDREN * 2
        } catch {
            print(error)
        }
    }
    
    func updateVolume(_ newExpectedVol: Double!, _ isLeft: Bool!) {
        _currentVolume = newExpectedVol
        _isLeft = isLeft
        _player.pan = isLeft ? -1 : 1
        print(isLeft, _player.pan)
    }

    func playFirstInterval() {
        playInterval(delay: 0.0)
    }

    func playSecondInterval() {
        playInterval(delay: PULSE_TIME_CHILDREN * Double(NUM_OF_PULSE_CHILDREN) + PLAY_GAP_TIME)
    }

    private func playInterval(delay: Double){
        startTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false){ _ in
            self.start()
        }
        startTimer2 = Timer.scheduledTimer(withTimeInterval: delay + PULSE_TIME_CHILDREN + 0.01, repeats: false){ _ in
            self.start()
        }
    }

    internal func start() {
        print()
        _player.volume = 0
        _player.play()
        let corrFactor: Double! = _isLeft ? _leftCorrFactor : _rightCorrFactor
        let playingLevel: Double! = _currentVolume + corrFactor + _zFactor
        let timeNow = DispatchTime.now()

        print("Playing Actual: ", playingLevel)
        for i in stride(from: 0, through: 1, by: 0.1) {
            // Attacking/Ramping up
            DispatchQueue.main.asyncAfter(deadline: timeNow + i * ATTACK_TIME){
                self._player.volume = self.dbToAmp(playingLevel * i)
            }

            // Decaying/Ramping down
            let t = PULSE_TIME_CHILDREN - (1-i) * RELEASE_TIME

            DispatchQueue.main.asyncAfter(deadline: timeNow + t){
                self._player.volume = self.dbToAmp(playingLevel * (1-i))
            }
        }
    }

    internal func stop() {
        startTimer?.invalidate()
        startTimer2?.invalidate()
        stopTimer?.invalidate()
        self._player.stop()
    }
}

