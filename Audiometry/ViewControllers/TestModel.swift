
import Foundation
import UIKit
import CoreData

class TestModel {
//------------------------------------------------------------------------------
// Constants
//------------------------------------------------------------------------------
    private let _SYSTEM_DEFAULT_DB = 50
    private let _TEST_MAX_DB = 100
    private let _TEST_MIN_DB_ADULT = 20
    private let _TEST_MIN_DB_CHILD = 15
    
//------------------------------------------------------------------------------
// Local Variables
//------------------------------------------------------------------------------
    private let managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    private var globalSetting: GlobalSetting!
    private var dict_patientProfileValues: [Int:PatientProfileValues] = [:]
    private var dict_calibrationValues: [Int:CalibrationSettingValues] = [:]
    
    private var array_testFreqSeq: [Int] = []
    private var array_results: [Int] = []
    private var array_responses: [Int] = []
    private var array_cases: [Int] = []
    
    // Used to determine when test ends
    private var dict_hasBeenAscendingCorrect = [Int: Bool]()
    
    private var _isPractice: Bool!
    private var _isAdult: Bool!
    private var _flag_initialPhase: Bool!
    
    private var currentFreq: Int!
    private var _currentPlayCase: Int!
    private var _currentDB: Int!
    private var _maxDBTrials: Int = 0
    private var _noSoundCount: Int = 0
    private var _noSoundCorrect: Int = 0
    
    private var player: TestPlayer!
    
    func nextTestFreq() -> Int{
        return currentFreq
    }
    
    func currentPlayCase() -> Int! {
        return _currentPlayCase
    }
    
//------------------------------------------------------------------------------
// Initialize Settings
//------------------------------------------------------------------------------
    init() {
        // Init test player
        initSettings()
        
        _isPractice = globalSetting.patientProfile?.isPractice
        _isAdult = globalSetting.patientProfile?.isAdult
        
        if (_isAdult) {
            player = AdultTestPlayer()
        } else {
            player = ChildrenTestPlayer()
        }
        
        setupNextFreq()
    }
    
    func initSettings(){
        // fetch global setting
        let request:NSFetchRequest<GlobalSetting> =
            GlobalSetting.fetchRequest()
        request.fetchLimit = 1
        
        do {
            globalSetting = try managedContext.fetch(request).first
            array_testFreqSeq = globalSetting.testFrequencySequence ?? []
            
            for v in (globalSetting.calibrationSetting?.values)!{
                let values = v as! CalibrationSettingValues
                dict_calibrationValues[Int(values.frequency)] = values
            }
            
            for v in (globalSetting.patientProfile?.values)!{
                let values = v as! PatientProfileValues
                dict_patientProfileValues[Int(values.frequency)] = values
            }
            
        } catch let error as NSError{
            print("Could not fetch global setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
//------------------------------------------------------------------------------
// Setup for new test freq
//------------------------------------------------------------------------------
    private func setupNextFreq(){
        currentFreq = array_testFreqSeq.removeFirst()
        
        // Config Test Player
        let values = dict_calibrationValues[currentFreq]!
        
        // Config audio settings
        let correctionFactor_L: Double =
            values.expectedLv - values.measuredLv_L
        let correctionFactor_R: Double =
            values.expectedLv - values.measuredLv_R
        
        player.updateFreq(Int(values.frequency))
        player.updateCorrectionFactors(correctionFactor_L, correctionFactor_R)
        
        // Init buffs at current Freq to storing results
        array_results = []
        array_responses = []
        array_cases = []
        
        _flag_initialPhase = true
        _maxDBTrials = 0
        _noSoundCount = 0
        _noSoundCorrect = 0
        _currentDB = _SYSTEM_DEFAULT_DB
        dict_hasBeenAscendingCorrect.removeAll()
    }
    
//------------------------------------------------------------------------------
// Player Functions
//------------------------------------------------------------------------------
    
    // Play signal case
    func playSignalCase() {
        // Set init volume & random play case
        player.updateVolume(Double(_currentDB), globalSetting.isTestingLeft)
        
        _currentPlayCase = randomizePlayCase()
        
        // Second trial in practice needs to be no sound
        if(_isPractice && array_results.count == 1){
            _currentPlayCase = 0
        }
        else if(array_cases.count >= 2){
            let counts = array_cases.reduce(into: [:]) { $0[$1, default: 0] += 1 }
            
            if((counts[1] ?? 0) > (counts[2] ?? 0) && _currentPlayCase == 1){
                _currentPlayCase = randomizePlayCase()
            }
            else if((counts[2] ?? 0) > (counts[1] ?? 0) && _currentPlayCase == 2){
                _currentPlayCase = randomizePlayCase()
            }
            
            if(array_cases.last == _currentPlayCase &&
                array_cases.last == array_cases[array_responses.count-2])
            {
                //print("After redrawal: ",    _currentPlayCase)
                //print("Redraw Again")
                _currentPlayCase = randomizePlayCase()
            }
        }
        
        print("Playcase: ", _currentPlayCase)
        replaySignalCase()
    }
    
    func randomizePlayCase() -> Int {
        let randomInt = _isPractice ? Int.random(in:0 ..< 8) : Int.random(in:0 ..< 12)
        
        // First trial cannot be no sound
        if(randomInt < 2 && array_results.count > 0 &&
            _currentDB != _TEST_MAX_DB && array_cases.last != 0)
        {
            return 0
        }
        else {
            return randomInt%2+1
        }
    }
    
    func replaySignalCase(){
        print("Current dB Lv: ", _currentDB)
        
        switch _currentPlayCase {
            
        case 0: // Slient interval
            break
            
        case 1: // First interval
            self.player.playFirstInterval()
            break
            
        case 2: // Second interval
            // First interval time + Slience gap 0.5s
            self.player.playSecondInterval()
            break
            
        default: // Should never be this case
            print("Playcase ERROR!!!")
            break
        }
    }
    
    func pausePlaying() {
        player.stop()
    }
    
//------------------------------------------------------------------------------
// Checking Test progress
//------------------------------------------------------------------------------
    func checkNoSound(_ isCorrect: Bool!) -> Bool!{
        array_results.append(_currentDB)
        array_responses.append(0)
        array_cases.append(_currentPlayCase)
        
        _noSoundCount += 1
        if(isCorrect){
            _noSoundCorrect += 1
        }
        
        return false
    }
    
    func checkThreshold(_ isCorrect: Bool!) -> Bool!{
        let TEST_MAX_DB = _TEST_MAX_DB
        let TEST_MIN_DB = _isAdult ? _TEST_MIN_DB_ADULT : _TEST_MIN_DB_CHILD
        // Update current response to tracking list
        let lastDB = array_results.last
        let lastPlayCase = array_cases.last
        let wasLastCorrect = (_currentDB < (lastDB ?? _currentDB+1))
        
        array_results.append(_currentDB)
        array_responses.append(isCorrect ? 1 : -1)
        array_cases.append(_currentPlayCase)
        //print(_currentDB, lastDB)
        // check if 0 db
        if(_currentDB == TEST_MIN_DB){
            if (isCorrect && (lastDB == TEST_MIN_DB) && lastPlayCase != 0){
                endTest(TEST_MIN_DB)
                return true
            }
        }
        // Check if 3 max DB in a row
        else if (_currentDB == TEST_MAX_DB){
            if (!isCorrect){
                _maxDBTrials += 1
            } else {
                _maxDBTrials = 0
            }
            
            if(_maxDBTrials == 3){
                endTest(-1)
                return true
            }
        }
        
        // Determine if this is an ascending + response
        if (!wasLastCorrect && isCorrect) {
            let currentDB_key: Int = Int(_currentDB)
            let hasBeenAscendingCorrect: Bool! = dict_hasBeenAscendingCorrect[currentDB_key] ?? false
            
            // Determine if test can be ended
            // Twice correct in a row on the same freq
            if(hasBeenAscendingCorrect){
                endTest(_currentDB)
                return true
            }
            else {
                dict_hasBeenAscendingCorrect[currentDB_key] = true
            }
        }
        
        // Else, just update and play next db
        // Check if phase has changed
        if(_flag_initialPhase) {
            
            // If first correct / incorrect after previous incorrects / corrects
            // change phase
            if(_currentDB > _SYSTEM_DEFAULT_DB && isCorrect) ||
                (_currentDB < _SYSTEM_DEFAULT_DB && !isCorrect){
                
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
    func endTest(_ thresholdDB: Int!){
        // Setup patient profile values for CoreData
        let newValues = dict_patientProfileValues[currentFreq] ??
            NSEntityDescription.insertNewObject(
                forEntityName: "PatientProfileValues",
                into: managedContext) as! PatientProfileValues
        
        newValues.frequency = Int16(currentFreq)
        
        if globalSetting.isTestingLeft {
            newValues.threshold_L = Int16(thresholdDB)
            newValues.results_L = array_results
            newValues.responses_L = array_responses
            newValues.no_sound_count_L = Int16(_noSoundCount)
            newValues.no_sound_correct_L = Int16(_noSoundCorrect)
        } else {
            newValues.threshold_R = Int16(thresholdDB)
            newValues.results_R = array_results
            newValues.responses_R = array_responses
            newValues.no_sound_count_R = Int16(_noSoundCount)
            newValues.no_sound_correct_R = Int16(_noSoundCorrect)
        }
        
        globalSetting.patientProfile?.addToValues(newValues)
        
        if(array_testFreqSeq.count == 0){
            if(globalSetting.isTestingBoth){
                currentFreq = -1
                globalSetting.isTestingBoth = false
                globalSetting.isTestingLeft = !(globalSetting.isTestingLeft)
            } else {
                currentFreq = 0
            }
        } else {
            setupNextFreq()
        }
        
        do{
            try managedContext.save()
        } catch let error as NSError{
            print("Could not save test results.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    func terminatePlayer() {
        player.terminate()
    }
}
