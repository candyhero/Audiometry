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
    
//    var player: AKPlayer = AKPlayer()
    var file: AKAudioFile!
    var player: AKPlayer!
    var adsr: AKAmplitudeEnvelope!
    var delay: AKDelay!
    
    
    var startTimer: Timer?
    var startTimer2: Timer?
    var stopTimer: Timer?
    
    var isStarted: Bool!
    var leftCorrFactor: Double!
    var rightCorrFactor: Double!
    
    var zFactor: Double!
    var currentVol: Double!
    var isLeft: Bool!
    
    required init() {
        
        leftCorrFactor = 0.0
        rightCorrFactor = 0.0
        
        do {
            file = try AKAudioFile(readFileName: "\(ANIMAL_TONE_PATH)/250Hz.wav")
            isStarted = true
        } catch {
            print(error)
            return
        }
        
        player = AKPlayer(audioFile: file)
        AudioKit.output = player
        
        do {
            try AudioKit.start()
        } catch {
            print(error)
        }
    }
    
    func updateFreq (_ newFreq: Int!) {
        do {
            zFactor = Z_FACTORS[newFreq] ?? 0.0
            let file = try AKAudioFile(readFileName: "\(ANIMAL_TONE_PATH)/\(newFreq)Hz.wav")
            player.load(audioFile: file)
            player.endTime = PULSE_TIME_CHILDREN * 2
        } catch {
            print(error)
        }
    }
    
    func updateVolume(_ newExpectedVol: Double!, _ isLeft: Bool!) {
        self.currentVol = newExpectedVol
        self.isLeft = isLeft
        player.pan = isLeft ? -1 : 1
    }
    
    func playFirstInterval() {
        startTimer = Timer.scheduledTimer(timeInterval: 0.0,
                                          target: self,
                                          selector: #selector(start),
                                          userInfo: nil,
                                          repeats: false)
        
        startTimer2 = Timer.scheduledTimer(timeInterval: PULSE_TIME_CHILDREN,
                                           target: self,
                                           selector: #selector(start),
                                           userInfo: nil,
                                           repeats: false)
    }
    func playSecondInterval() {
        let delay: Double! = PULSE_TIME_CHILDREN*Double(NUM_OF_PULSE_CHILDREN)+PLAY_GAP_TIME
        startTimer = Timer.scheduledTimer(timeInterval: delay,
                                          target: self,
                                          selector: #selector(start),
                                          userInfo: nil,
                                          repeats: false)
        
        startTimer2 = Timer.scheduledTimer(timeInterval: delay+PULSE_TIME_CHILDREN,
                                           target: self,
                                           selector: #selector(start),
                                           userInfo: nil,
                                           repeats: false)
    }
    
    @objc internal func start() {
        if(!isStarted) {return}
        
        self.player.volume = 0
        self.player.play()
        let corrFactor: Double! = isLeft ? leftCorrFactor : rightCorrFactor
        let playingLevel: Double! = self.currentVol + corrFactor + zFactor
        print("Playing Actual: ", playingLevel)
        for i in stride(from: 0, through: 1, by: 0.1) {
            // Attacking/Ramping up
            DispatchQueue.main.asyncAfter(
                deadline: .now() + i * ATTACK_TIME, execute:
                {
                    self.player.volume = self.dbToAmp(playingLevel * i)
            })
            // Decaying/Ramping down
            let t = PULSE_TIME_CHILDREN - (1-i) * RELEASE_TIME
            DispatchQueue.main.asyncAfter(
                deadline: .now() + t, execute:
                {
                    self.player.volume = self.dbToAmp(playingLevel * (1-i))
            })
        }
    }
    
    @objc func stop() {
        startTimer?.invalidate()
        startTimer2?.invalidate()
        stopTimer?.invalidate()
        self.player.stop()
    }
}

