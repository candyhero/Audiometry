//
//  TestFlow.swift
//  Audiometry
//
//  Created by Xavier Chan on 10/27/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import Foundation
import RealmSwift

class TestFlow {
    
    private let SYSTEM_DEFAULT_DB = 50.0
    
    private let realm = try! Realm()
    private var mainSetting: MainSetting? = nil
    private var patientProfile: PatientProfile? = nil
    private var currentTestResult: TestResult? = nil
    private var calibrationSetting: CalibrationSetting? = nil
    
    // Used to determine when test ends
    private var dict_hasBeenAscendingCorrect = [Int: Bool]()
    
    private var _flag_initialPhase: Bool!
    
    private var _currentPlayCase: Int!
    private var _currentDB: Double!
    
//    private var thresholdDB: Double! = nil
    private var player: TestPlayer! = nil
    
    init() {
        mainSetting = realm.objects(MainSetting.self).first
        
        player = TestPlayer()
        // retrieve calibration setting for current freq
        let calibrationSettingID = mainSetting?.calibrationSettingIndex
        calibrationSetting = mainSetting?.array_calibrationSettings[calibrationSettingID!]
        
        patientProfile = mainSetting?.array_patientProfiles.first
    }
    
    func currentPlayCase() -> Int! {
        return _currentPlayCase
    }
    
    func currentDB() -> Double! {
        return _currentDB
    }
    
    // functions
    private func loadSettingAtFreq(_ currentFreqID: Int!){
        
        let presentDBHL = calibrationSetting?.array_presentDBHL[currentFreqID]
        let expectedDBSPL = calibrationSetting?.array_expectedDBSPL[currentFreqID]
        let measuredDBSPL_L = calibrationSetting?.array_measuredDBSPL_L[currentFreqID]
        let measuredDBSPL_R = calibrationSetting?.array_measuredDBSPL_R[currentFreqID]
        
        // Create test result profile for current freq
        currentTestResult = TestResult()
        
        currentTestResult?.freq = ARRAY_DEFAULT_FREQ[currentFreqID]
        currentTestResult?.presentDBHL = presentDBHL!
        currentTestResult?.expectedDBSPL = expectedDBSPL!
        
        currentTestResult?.measuredDBSPL_L = measuredDBSPL_L!
        currentTestResult?.measuredDBSPL_R = measuredDBSPL_R!
    }
    
    func findThresholdAtFreq(_ currentFreqID: Int!){
        // Init' player and settings if first time (L or R)
        let currentFreqSeqID: Int! = (mainSetting?.frequencyTestIndex)!
        
        if((patientProfile?.array_testResults.count)! == currentFreqSeqID) {
            // First Left/ Right ear test
            loadSettingAtFreq(currentFreqID)
        }
        else {
            currentTestResult = patientProfile?.array_testResults[currentFreqSeqID]
        }
        
        // Config audio settings
        let correctionFactor_L: Double = (currentTestResult?.expectedDBSPL)! - (currentTestResult?.measuredDBSPL_L)!
        let correctionFactor_R: Double = (currentTestResult?.expectedDBSPL)! - (currentTestResult?.measuredDBSPL_R)!
        
        player.updateFreq(Double((currentTestResult?.freq)!) )
        player.updateCorrectionFactors(correctionFactor_L, correctionFactor_R)
        player.initPlayerVolume()
        
        _currentDB = SYSTEM_DEFAULT_DB
        
        // Init buffs at current Freq to storing results
        _flag_initialPhase = true
        dict_hasBeenAscendingCorrect.removeAll()
        
        // Start playing
        playSignalCase()
    }
    
    func playSignalCase() {
        
        // Set init volume & random play case
        player.updatePlayerVolume(_currentDB, mainSetting?.frequencyProtocol?.isLeft)
        
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
        var lastDB: Double?
        
        try! realm.write {
            
            if(mainSetting?.frequencyProtocol?.isLeft)!{
                lastDB = currentTestResult?.array_trackingDB_L.last
                currentTestResult?.array_trackingDB_L.append(_currentDB)
            } else {
                lastDB = currentTestResult?.array_trackingDB_R.last
                currentTestResult?.array_trackingDB_R.append(_currentDB)
            }
        }
        
        let wasLastCorrect = (_currentDB < lastDB ?? _currentDB + 1)
        
        // Determine if this is an ascending + response
        if(!wasLastCorrect && bool_sender) {
            
            let currentDB_intKey: Int = Int(_currentDB)
            let hasBeenAscendingCorrect: Bool! = dict_hasBeenAscendingCorrect[currentDB_intKey] ?? false
            
            // Determine if test can be ended
            if(hasBeenAscendingCorrect){
                // Twice correct in a row on the same freq
                try! realm.write {
                    // Update threshold & Increment freq test index
                    if(mainSetting?.frequencyProtocol?.isLeft)!{
                        currentTestResult?.thresholdDB_L = _currentDB
                    }
                    else {
                        currentTestResult?.thresholdDB_R = _currentDB
                    }
                    
                    if(patientProfile?.array_testResults.count == 0){
                        patientProfile?.array_testResults.append(currentTestResult!)
                    }
                    
                    mainSetting?.frequencyTestIndex += 1
                    
                }
                
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
        nextDB = (nextDB > _DB_SYSTEM_MAX) ? _DB_SYSTEM_MAX : nextDB
        nextDB = (nextDB < _DB_SYSTEM_MIN) ? _DB_SYSTEM_MIN : nextDB
        
        // Load new volume
        _currentDB = nextDB!
        
        return false
    }
}
