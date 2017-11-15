//
//  TestFlow.swift
//  Audiometry
//
//  Created by Xavier Chan on 10/27/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import Foundation

class TestFlow {
    
    // Pre-init'ed
    private var array_correctionFactors = [Double]()
    
    private var dict_thresholdDB = [String: Double]()
    private var dict_freqTrackList = [String: [Double]]()
    
    // Temp buff for each freq run,
    // Init before each run
    private var dict_rightCount: [Double: Int]!
    private var dict_wrongCount: [Double: Int]!
    
    private var flag_initialPhase: Bool!
    
    private var _currentPlayCase: Int!
    private var _currentDB: Double!
    private var _currentFreqIndex: Int!
    private var _currentSetting: [String: [String]]!
    
//    private var thresholdDB: Double! = nil
    private var player: TestPlayer! = nil
    
    init() {
        player = TestPlayer()
        
        loadCalibrationSetting()
    }
    
    // Getters & setters
//    func setFreqSeq (array_freqSeq:[Int]!) {
//        self.array_freqSeq = array_freqSeq
//    }
    
    func currentPlayCase() -> Int! {
        return _currentPlayCase
    }
    
    func currentDB() -> Double! {
        return _currentDB
    }
    
    // functions
    private func loadCalibrationSetting() {
        
        // retrieve calibration setting for all freqs
        let currentSettingKey =
            UserDefaults.standard.string(forKey: "currentSetting") ?? nil
        
        _currentSetting = UserDefaults.standard.dictionary(
            forKey: currentSettingKey!) as? [String : [String]]
        
        
        
        flag_initialPhase = false
        
        for i in 0..<ARRAY_FREQ.count {
            
            // Retrieve saved volume strings by trying every key (freq)
            let freqKey: String = String(ARRAY_FREQ[i])
            var array_db = _currentSetting[freqKey] as [String]! ?? nil
            
            // In case a new frequency is added,
            // which has no default UserDefaults.standard
            if(array_db != nil){
                
                let expectedTxt: String! = array_db?[0] ?? nil
                let leftMeasuredTxt: String! = array_db?[2] ?? nil
                let rightMeasuredTxt: String! = array_db?[3] ?? nil
                
                let expectedDBSPL: Double! = Double(expectedTxt) ?? 0.0
                
                let leftMeasuredDBSPL: Double! =
                    Double(leftMeasuredTxt) ?? expectedDBSPL
                let rightMeasuredDBSPL: Double! =
                    Double(rightMeasuredTxt) ?? expectedDBSPL
                
                // Extract the correction factors in dB
                array_correctionFactors.append(
                    expectedDBSPL - leftMeasuredDBSPL)
                array_correctionFactors.append(
                    expectedDBSPL - rightMeasuredDBSPL)
            }
        }
    }
    
    func findThresholdAtFreq(_ freqIndex: Int!){
        
        // Update player settings
        _currentFreqIndex = freqIndex
        let currentFreq: Double = ARRAY_FREQ[freqIndex]
        
        let leftCorrFactor: Double! =
            array_correctionFactors[_currentFreqIndex * 2]
        let rightCorrFactor: Double! =
            array_correctionFactors[_currentFreqIndex * 2 + 1]
        
        _currentDB = 70.0
        flag_initialPhase = false
        
        player.updateFreq(currentFreq)
        player.updateCorrectionFactors(leftCorrFactor, rightCorrFactor)
        
        // Init buffs at current Freq to storing results
        dict_freqTrackList[String(currentFreq)] = [Double]()
        
        dict_rightCount = [Double:Int]()
        dict_wrongCount = [Double:Int]()
        
        // Start playing
        playSignalCase()
    }
    
    private func playSignalCase() {
        
        // Set init volume & random play case
        player.updatePlayerVolume(_currentDB)
        
        // Update playe case
        //currentPlaycase = Int(arc4random_uniform(3))
        _currentPlayCase = Int(arc4random_uniform(2) + 1)
        
        switch _currentPlayCase {
            
        case 0: // Slient interval
            break
            
        case 1: // First interval
            DispatchQueue.main.asyncAfter(
                deadline: .now(),
                execute:{self.player.play()}
            )
            break
            
        case 2: // Second interval
            // First interval time + Slience gap 0.5s
            let delayTime = PULSE_TIME * NUM_OF_PULSE + PLAY_GAP_TIME
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + Double(delayTime),
                execute:{self.player.play()}
            )
            break
            
        default: // Should never be this case
            print("Playcase ERROR!!!")
            break
        }
    }
    
    func checkThreshold(_ bool_sender: Bool!) -> Bool!{
        // Update dB track list at this freq
        let currentFreq = ARRAY_FREQ[_currentFreqIndex]
        dict_freqTrackList[String(currentFreq)]?.append(_currentDB)
        
        // Update right/wrong counts
        if(bool_sender){
            dict_rightCount[_currentDB] = (dict_rightCount[_currentDB] ?? 0) + 1
        }
        else {
            dict_wrongCount[_currentDB] = (dict_wrongCount[_currentDB] ?? 0) + 1
        }
        
        // Compute next dB
        var nextDB: Double!
        
        if(!flag_initialPhase) {
            nextDB = _currentDB + (bool_sender ? -10 : 20)
        }
        else {
            nextDB = _currentDB + (bool_sender ? -5 : 10)
        }
        
        // Bound next db between [0, 100] dbHL
        nextDB = (nextDB > 100) ? 100 : nextDB
        nextDB = (nextDB < 0) ? 0 : nextDB
        
        if(!flag_initialPhase){
            if((dict_rightCount[_currentDB] ?? 0) > 0 &&
                (dict_wrongCount[nextDB] ?? 0) > 0){
                
                flag_initialPhase = true
            }
        }
        else {
            if(bool_sender){
                let rightCurrent: Int! = dict_rightCount[_currentDB] ?? 0
                let wrongCurrent: Int! = dict_wrongCount[_currentDB] ?? 1
                let wrongNext: Int! = dict_wrongCount[nextDB] ?? 0
                let rightNext: Int! = dict_rightCount[nextDB] ?? 1
                
                if(rightCurrent > wrongCurrent && wrongNext > rightNext){
                    dict_thresholdDB[String(currentFreq)] = _currentDB
                }
            }
            else {
                let rightUpper: Int! = dict_rightCount[_currentDB + 5] ?? 0
                let wrongUpper: Int! = dict_wrongCount[_currentDB + 5] ?? 1
                let wrongCurrent: Int! = dict_wrongCount[_currentDB] ?? 0
                let rightCurrent: Int! = dict_rightCount[_currentDB] ?? 1
                
                if(rightUpper > wrongUpper && wrongCurrent > rightCurrent){
                    dict_thresholdDB[String(currentFreq)] = _currentDB + 5
                }
            }
        }
        
        // Load new volume
        player.updatePlayerVolume(nextDB)
        _currentDB = nextDB!
        
        // Draw new case
        //currentPlaycase = Int(arc4random_uniform(3))
        _currentPlayCase = Int(arc4random_uniform(2) + 1)
        
        if(dict_thresholdDB[String(currentFreq)] == nil){
            
            playSignalCase()
            return false
        }
        else {
            return true
        }
    }
    
    func saveResult() {
        // Save threshold and track history if threshold found
        print("Saving Test Result")
        UserDefaults.standard.set(dict_thresholdDB, forKey: "dict_thresholdDB")
        UserDefaults.standard.set(dict_freqTrackList, forKey: "dict_result")
    }
}
