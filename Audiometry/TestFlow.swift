//
//  TestFlow.swift
//  Audiometry
//
//  Created by Xavier Chan on 10/27/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import Foundation

class TestFlow {
    
    private let SYSTEM_DEFAULT_DB = 50.0
    
    // Pre-init'ed
    private var array_correctionFactors = [Double]()
    
    private var dict_thresholdDB = [String: Double]()
    private var dict_freqTrackList = [String: [Double]]()
    
    private var dict_hasBeenAscendingCorrect = [Int: Bool]()
    
    private var _flag_initialPhase: Bool!
    
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
        
//        _flag_initialPhase = true
        
        for i in 0..<ARRAY_DEFAULT_FREQ.count {
            
            // Retrieve saved volume strings by trying every key (freq)
            let freqKey: String = String(ARRAY_DEFAULT_FREQ[i])
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
        let currentFreq: Double = Double(ARRAY_DEFAULT_FREQ[freqIndex])
        
        let leftCorrFactor: Double! =
            array_correctionFactors[_currentFreqIndex * 2]
        let rightCorrFactor: Double! =
            array_correctionFactors[_currentFreqIndex * 2 + 1]
        
        _currentDB = SYSTEM_DEFAULT_DB
        
        player.updateFreq(currentFreq)
        player.updateCorrectionFactors(leftCorrFactor, rightCorrFactor)
        
        // Init buffs at current Freq to storing results
        _flag_initialPhase = true
        dict_freqTrackList[String(currentFreq)] = [Double]()
        dict_hasBeenAscendingCorrect.removeAll()
        
        // Start playing
        playSignalCase()
    }
    
    private func playSignalCase() {
        
        // Set init volume & random play case
        player.updatePlayerVolume(_currentDB)
        
        // Draw new case
        _currentPlayCase = Int(arc4random_uniform(2) + 1)
        // Uncomment to enable no sound interval
        //currentPlaycase = Int(arc4random_uniform(3))
        
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
        let currentFreq = ARRAY_DEFAULT_FREQ[_currentFreqIndex]
        let lastDB: Double? = dict_freqTrackList[String(currentFreq)]?.last
        
        dict_freqTrackList[String(currentFreq)]!.append(_currentDB)
        
        let wasLastCorrect = (_currentDB < lastDB ?? _currentDB + 1)
        
        // Determine if this is an ascending + response
        if(!wasLastCorrect && bool_sender) {
            
            let currentDB_intKey: Int = Int(_currentDB)
            let hasBeenAscendingCorrect: Bool! = dict_hasBeenAscendingCorrect[currentDB_intKey] ?? false
            
            // Determine if test can be ended
            if(hasBeenAscendingCorrect){
                // Twice correct in a row on the same freq
                // Update threshold
                dict_thresholdDB[String(currentFreq)] = _currentDB
                
                // End testing on this freq
                saveResult()
                return true
            }
            else {
                
                dict_hasBeenAscendingCorrect[currentDB_intKey] = true
            }
        }
        
        // Else, just update and play next db
        // Check if phase has changed
        if(_flag_initialPhase) {
            
            // If first correct / incorrect after previous incorrects / corrects
            // change phase
            if(_currentDB > SYSTEM_DEFAULT_DB && bool_sender) ||
                (_currentDB < SYSTEM_DEFAULT_DB && !bool_sender){
                
                _flag_initialPhase = false
            }
        }
        
        // Compute next dB
        var nextDB: Double!
        
        if(_flag_initialPhase) {
            nextDB = _currentDB + (bool_sender ? -20 : 20)
        }
        else {
            nextDB = _currentDB + (bool_sender ? -10 : 5)
        }
        
        // Bound next db between [0, 100] dbHL
        nextDB = (nextDB > 100) ? 100 : nextDB
        nextDB = (nextDB < 0) ? 0 : nextDB
        
        // Load new volume
        _currentDB = nextDB!
        
        playSignalCase()
        return false
    }
    
    func saveResult() {
        // Save threshold and track history if threshold found
        let patientName =  UserDefaults.standard.string(forKey: "patientName")
        var patientProfiles = UserDefaults.standard.array(forKey: "patientProfiles") as? [String]
        var array_freqSeq = UserDefaults.standard.array(forKey:  "freqSeq" + patientName!) as? [Int]
        
        if(patientProfiles == nil) {
            patientProfiles = [String]()
        }
        
        if(patientProfiles!.first != patientName!){
            patientProfiles!.insert(patientName!, at: 0)
        }
        
        if(array_freqSeq == nil) {
            array_freqSeq = [Int]()
        }
        
        array_freqSeq!.append(_currentFreqIndex)
        
        UserDefaults.standard.set(patientProfiles!, forKey: "patientProfiles")

        UserDefaults.standard.set(array_freqSeq, forKey: "freqSeq" + patientName!)
        UserDefaults.standard.set(dict_thresholdDB, forKey: "db" + patientName!)
        UserDefaults.standard.set(dict_freqTrackList, forKey: patientName!)
    }
}
