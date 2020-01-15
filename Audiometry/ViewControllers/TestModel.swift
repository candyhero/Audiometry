
import Foundation
import UIKit
import CoreData

class TestModel {
//------------------------------------------------------------------------------
// Constants
//------------------------------------------------------------------------------
    private let _SYSTEM_DEFAULT_DB = 50
    private let _TEST_MAX_DB = 100
    private let _TEST_MIN_DB_ADULT = 15
    private let _TEST_MIN_DB_CHILD = 15
    
//------------------------------------------------------------------------------
// Local Variables
//------------------------------------------------------------------------------
    private let _managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    // All test setup settings
    private var _globalSetting: GlobalSetting!
    
    private var _isPractice: Bool!
    private var _isAdult: Bool!
    
    private var _startTime: Date!
    private var _endTime: Date!
    
    private var _testPlayer: TestPlayer!
    
    // Buffers
    private var _dict_patientProfileValues: [Int:PatientProfileValues] = [:]
    private var _dict_calibrationValues: [Int:CalibrationSettingValues] = [:]
    
    private var _array_testFreqSeq: [Int] = []
    private var _array_results: [Int] = []
    private var _array_responses: [Int] = []
    private var _array_cases: [Int] = []
    
    // In-test settings
    private var _currentFreq: Int!
    private var _currentPlayCase: Int!
    private var _currentDB: Int!
    
    private var _flag_initialPhase: Bool!
    private var _dict_hasBeenAscendingCorrect = [Int: Bool]()
    
    private var _maxDBTrials: Int = 0
    private var _noSoundCount: Int = 0
    private var _noSoundCorrect: Int = 0
    
    private var _spamCounter: Int = 0
    
//------------------------------------------------------------------------------
// Getter functions
//------------------------------------------------------------------------------
    func getTestLauguage() -> String{
        return _globalSetting.testLanguage ?? "Invalid"
    }
    
    func getNewTestFreq() -> Int{
        return _currentFreq
    }
    
    func getCurrentPlayCase() -> Int! {
        return _currentPlayCase
    }
    
    func getCurrentProgress() -> Int!{
        let currentTestCount = Int(_globalSetting.currentTestCount)
        let totalTestCount = Int(_globalSetting.totalTestCount)
        
        if(totalTestCount > 0) {
            return 100 * currentTestCount / totalTestCount
        }
        return -1
    }
    
//------------------------------------------------------------------------------
// Initialize Settings
//------------------------------------------------------------------------------
    private func loadGlobalSetting() {
        // fetch global setting
        let request:NSFetchRequest<GlobalSetting> =
            GlobalSetting.fetchRequest()
        request.fetchLimit = 1
        
        do {
            _globalSetting = try _managedContext.fetch(request).first
            _array_testFreqSeq = _globalSetting.testFrequencySequence ?? []
            
            for v in (_globalSetting.calibrationSetting?.values)!{
                let values = v as! CalibrationSettingValues
                _dict_calibrationValues[Int(values.frequency)] = values
            }
            
            for v in (_globalSetting.patientProfile?.values)!{
                let values = v as! PatientProfileValues
                _dict_patientProfileValues[Int(values.frequency)] = values
            }
            
        } catch let error as NSError{
            print("Could not fetch global setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    init() {
        loadGlobalSetting()
        
        _isPractice = _globalSetting.patientProfile?.isPractice
        _isAdult = _globalSetting.patientProfile?.isAdult
        
        if (_isAdult) {
            _testPlayer = AdultTestPlayer()
        } else {
            _testPlayer = ChildrenTestPlayer()
        }
        
        // Proceed to setup next freq testing
        setupForNextFreq()
    }
    
//------------------------------------------------------------------------------
// Setup for new test freq
//------------------------------------------------------------------------------
    private func setupForNextFreq() {
        _currentFreq = _array_testFreqSeq.removeFirst()
        
        // Config Test Player
        let values = _dict_calibrationValues[_currentFreq]!
        
        // Config audio settings
        let correctionFactor_L: Double =
            values.expectedLv - values.measuredLv_L
        let correctionFactor_R: Double =
            values.expectedLv - values.measuredLv_R
        
        _testPlayer.updateFreq(Int(values.frequency))
        _testPlayer.updateCorrectionFactors(correctionFactor_L, correctionFactor_R)
        
        // Init buffs at current Freq to storing results
        _array_results = []
        _array_responses = []
        _array_cases = []
        
        _startTime = Date()
        
        _flag_initialPhase = true
        
        _spamCounter = 0
        
        _maxDBTrials = 0
        _noSoundCount = 0
        _noSoundCorrect = 0
        _currentDB = _SYSTEM_DEFAULT_DB
        _dict_hasBeenAscendingCorrect.removeAll()
    }
    
//------------------------------------------------------------------------------
// Player Functions
//------------------------------------------------------------------------------
    
    // Play signal case
    func playSignalCase() {
        // Set init volume & random play case
        _testPlayer.updateVolume(Double(_currentDB), _globalSetting.isTestingLeft)
        
        _currentPlayCase = randomizePlayCase()
        
        // Second trial in practice needs to be no sound
        if(_isPractice && _array_results.count == 1) {
            _currentPlayCase = 0
        }
        else if(_array_cases.count >= 2) {
            let counts = _array_cases.reduce(into: [:]) { $0[$1, default: 0] += 1 }
            
            if((counts[1] ?? 0) > (counts[2] ?? 0) && _currentPlayCase == 1) {
                _currentPlayCase = randomizePlayCase()
            }
            else if((counts[2] ?? 0) > (counts[1] ?? 0) && _currentPlayCase == 2) {
                _currentPlayCase = randomizePlayCase()
            }
            
            if(_array_cases.last == _currentPlayCase &&
                _array_cases.last == _array_cases[_array_responses.count-2])
            {
                //print("After redrawal: ",    _currentPlayCase)
                //print("Redraw Again")
                _currentPlayCase = randomizePlayCase()
            }
        }
        
        print("Playcase: ", _currentPlayCase)
        replaySignalCase()
    }
    
    private func randomizePlayCase() -> Int {
        let randomInt = _isPractice ? Int.random(in:0 ..< 8) : Int.random(in:0 ..< 12)
        
        var TEST_MAX_DB = _TEST_MAX_DB
        if(!_isAdult) {
            let q = Double(_TEST_MAX_DB) - (Z_FACTORS[_currentFreq] ?? 0.0)
            TEST_MAX_DB = Int((q/5).rounded(.down)) * 5
        }
        
        // First trial cannot be no sound
        if(randomInt < 2 && _array_results.count > 0 &&
            _currentDB != TEST_MAX_DB && _array_cases.last != 0)
        {
            return 0
        }
        else {
            return randomInt%2+1
        }
    }
    
    func replaySignalCase() {
        print("Current dB Lv: ", _currentDB)
        
        switch _currentPlayCase {
            
        case 0: // Slient interval
            break
            
        case 1: // First interval
            self._testPlayer.playFirstInterval()
            break
            
        case 2: // Second interval
            // First interval time + Slience gap 0.5s
            self._testPlayer.playSecondInterval()
            break
            
        default: // Should never be this case
            print("Playcase ERROR!!!")
            break
        }
    }
    
    func pausePlaying() {
        _testPlayer.stop()
    }
    
//------------------------------------------------------------------------------
// Checking Test progress
//------------------------------------------------------------------------------
    func checkNoSound(_ isCorrect: Bool!) -> Bool!{
        _array_results.append(_currentDB)
        _array_responses.append(0)
        _array_cases.append(_currentPlayCase)
        
        _noSoundCount += 1
        if(isCorrect) {
            _noSoundCorrect += 1
        }
        
        return false
    }
    
    func checkThreshold(_ isCorrect: Bool!) -> Bool!{
        
        let TEST_MIN_DB = _isAdult ? _TEST_MIN_DB_ADULT : _TEST_MIN_DB_CHILD
        var TEST_MAX_DB = _TEST_MAX_DB
        if(!_isAdult) {
            let q = Double(_TEST_MAX_DB) - (Z_FACTORS[_currentFreq] ?? 0.0)
            TEST_MAX_DB = Int((q/5).rounded(.down)) * 5
        }
        
        // Update current response to tracking list
        let lastDB = _array_results.last
        let lastPlayCase = _array_cases.last
        let wasLastCorrect = (_currentDB < (lastDB ?? _currentDB+1))
        
        _array_results.append(_currentDB)
        _array_responses.append(isCorrect ? 1 : -1)
        _array_cases.append(_currentPlayCase)
        //print(_currentDB, lastDB)
        // check if 0 db
        if(_currentDB == TEST_MIN_DB) {
            if (isCorrect && (lastDB == TEST_MIN_DB) && lastPlayCase != 0) {
                endTest(TEST_MIN_DB)
                return true
            }
        }
        // Check if 3 max DB in a row
        else if (_currentDB == TEST_MAX_DB) {
            if (!isCorrect) {
                _maxDBTrials += 1
            } else {
                _maxDBTrials = 0
            }
            
            if(_maxDBTrials == 3) {
                endTest(-1)
                return true
            }
        }
        
        // Determine if this is an ascending + response
        if (!wasLastCorrect && isCorrect) {
            let currentDB_key: Int = Int(_currentDB)
            let hasBeenAscendingCorrect: Bool! = _dict_hasBeenAscendingCorrect[currentDB_key] ?? false
            
            // Determine if test can be ended
            // Twice correct in a row on the same freq
            if(hasBeenAscendingCorrect) {
                endTest(_currentDB)
                return true
            }
            else {
                _dict_hasBeenAscendingCorrect[currentDB_key] = true
            }
        }
        
        // Else, just update and play next db
        // Check if phase has changed
        if(_flag_initialPhase) {
            
            // If first correct / incorrect after previous incorrects / corrects
            // change phase
            if(_currentDB > _SYSTEM_DEFAULT_DB && isCorrect) ||
                (_currentDB < _SYSTEM_DEFAULT_DB && !isCorrect) {
                
                _flag_initialPhase = false
            }
        }
        
        // Compute next dB
        var nextDB: Int!
        
        if(_flag_initialPhase) {
            nextDB = _currentDB + (isCorrect ? -20 : 20)
        }
        else {
            nextDB = _currentDB + (isCorrect ? -10 : 5)
        }
        
        // Bound next db
        nextDB = min(nextDB, TEST_MAX_DB)
        nextDB = max(nextDB, TEST_MIN_DB)
        
        // Load new volume
        _currentDB = nextDB!
        return false
    }
    
    // Wrap up test results on this frequency round
    private func endTest(_ thresholdDB: Int!) {
        _endTime = Date()
        
        // Setup patient profile values for CoreData
        let newValues = _dict_patientProfileValues[_currentFreq] ??
            NSEntityDescription.insertNewObject(
                forEntityName: "PatientProfileValues",
                into: _managedContext) as! PatientProfileValues
        
        newValues.frequency = Int16(_currentFreq)
        
        if _globalSetting.isTestingLeft {
            newValues.threshold_L = Int16(thresholdDB)
            newValues.results_L = _array_results
            newValues.responses_L = _array_responses
            newValues.no_sound_count_L = Int16(_noSoundCount)
            newValues.no_sound_correct_L = Int16(_noSoundCorrect)
            newValues.spamCount_L = Int16(_spamCounter)
            
            newValues.startTime_L = _startTime
            newValues.endTime_L = _endTime
            newValues.durationSeconds_L =
                Int16(_endTime.timeIntervalSince(_startTime))
        } else {
            newValues.threshold_R = Int16(thresholdDB)
            newValues.results_R = _array_results
            newValues.responses_R = _array_responses
            newValues.no_sound_count_R = Int16(_noSoundCount)
            newValues.no_sound_correct_R = Int16(_noSoundCorrect)
            newValues.spamCount_R = Int16(_spamCounter)
            
            newValues.startTime_R = _startTime
            newValues.endTime_R = _endTime
            newValues.durationSeconds_R =
                Int16(_endTime.timeIntervalSince(_startTime))
        }
        
        _globalSetting.currentTestCount += 1
        _globalSetting.patientProfile?.addToValues(newValues)
        _globalSetting.patientProfile?.endTime = _endTime
        
        let profileDuration = _endTime.timeIntervalSince((_globalSetting.patientProfile?.timestamp)!)
        _globalSetting.patientProfile?.durationSeconds = Int16(profileDuration)
        
        if(_array_testFreqSeq.count == 0) {
            if(_globalSetting.isTestingBoth) {
                _currentFreq = -1
                _globalSetting.isTestingBoth = false
                _globalSetting.isTestingLeft = !(_globalSetting.isTestingLeft)
                _globalSetting.patientProfile?.earOrder = _globalSetting.isTestingLeft ? "RL" : "LR"
//                print(_globalSetting.patientProfile?.earOrder)
            } else {
                _currentFreq = 0
            }
        } else {
            setupForNextFreq()
        }
        
        do{
            try _managedContext.save()
        } catch let error as NSError{
            print("Could not save test results.")
            print("\(error), \(error.userInfo)")
        }
        
//        print("Test Count: ", _globalSetting.patientProfile?.values?.count)
    }
    
    func increaseSpamCount() {
        _spamCounter += 1
        print(_spamCounter)
    }
    
    func terminatePlayer() {
        _testPlayer.terminate()
    }
}
