//
//  Enum.swift
//  Audiometry
//
//  Created by Xavier Chan on 14/7/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

enum TestLanguage: Int {
    case Invalid = 0
    case English = 1
    case Portuguese = 2
    case Spanish = 3
    
    func toString() -> String {
        switch self {
        case .Invalid: return "Invalid"
        case .English: return "English"
        case .Portuguese: return "Portuguese"
        case .Spanish: return "Spanish"
        }
    }
}

enum TestMode: Int {
    case Invalid = 0
    case Test = 1
    case Practice = 2
}

enum TestEarOrder: Int {
    case Invalid = 0
    case LeftOnly = 1
    case RightOnly = 2
    case LeftRight = 3
    case RightLeft = 4
    case Completed = 5
    
    func next() -> TestEarOrder{
        switch self {
            case .LeftRight: return .RightOnly
            case .RightLeft: return .LeftOnly
            case .LeftOnly, .RightOnly: return .Completed
            default: return .Invalid
        }
    }
}

enum PatientRole: Int {
    case Invalid = 0
    case Adult = 1
    case Children = 2
}

enum TestStatus: Int {
    case Invalid = 0
    case InitialPhase = 1
    case SecondPhase = 2
    case NextFrequency = 3
    case NextEar = 4
    case Completed = 5
}

enum PatientResponse : Int {
    case NoSound = -1
    case Invalid = 0
    case First = 1
    case Second = 2
}

class TestState {
    var language: TestLanguage!
    var mode: TestMode!
    
    var earOrder: TestEarOrder!
    var status: TestState!
    
    var testFrequencyQueue: [Int]!
    var currentTestFrequency: Int {
        get {
            testFrequencyQueue.first ?? -1
        }
    }
    
    var expectedResponse: PatientResponse!
    var currentDb: Int!
    
    // MARK: Test settings for current roun
//    private var _currentPlayCase: PlayCase!
//    private var _startTime, _endTime: Date!

//    private var _results = [Int]()
//    private var _responses = [Int]()
//    private var _cases = [PlayCase]()
//    private var _hasBeenAscendingCorrect = [Int: Bool]()
//
//    private var _spamCounter: Int = 0
//    private var _maxDBTrials: Int = 0
//    private var _noSoundCount: Int = 0
//    private var _noSoundCorrect: Int = 0
//    
//    private var maxDb: Float!
//    private var minDb: Float!
//    
//    func proceed(isResponseCorrect: Bool) {
//        
//        // Is test ended for all?
//        // Is test ended for this ear?
//        // Is test ended for this frequency?
//        // If not all the next response
//    }
//    
//    func isResponseCorrect(response: PatientResponse) -> Bool {
//        return (response != .Invalid) && (response == expectedResponse)
//    }
//    
//    func populateNextResponse(){
//        
//    }
//    private func checkIfMinDb(isCorrect: Bool) -> Bool {
//        if(currentDb == MIN_DB) {
//            if (isCorrect && (lastDB == MIN_DB) && lastPlayCase != .NoSound) {
//                endTest(MIN_DB)
//                return true
//            }
//        }
//    }
//    private func checkIfAscendingCorrect(isCorrect: Bool) -> Bool {
//        // Determine if correct twice in a row on the same db level
//        let result = _hasBeenAscendingCorrect[currentDb] ?? false
//        _hasBeenAscendingCorrect[currentDb] = isCorrect
//        return !wasLastCorrect && isCorrect && result
//        
//    }
//    
//    private func checkIfMaxDbThrice(isCorrect: Bool) -> Bool {
//        if (currentDb != TEST_MAX_DB) {
//            return false
//        }
//        
//        _maxDBTrials = isCorrect ? 0 : _maxDBTrials + 1;
//        return (_maxDBTrials == 3)
//    }
//    
//    
//    private func checkThreshold(_ isCorrect: Bool!) -> Bool!{
//        // Update current response to tracking list
//        let lastDb = _results.last
////        let lastPlayCase = _cases.last
//        let wasLastCorrect = _results.isEmpty || currentDb < lastDb ?? 0
//
////        _results.append(_currentDB)
////        _responses.append(isCorrect ? 1 : -1)
////        _cases.append(_currentPlayCase)
//
//        if checkIfMinDb(isCorrect: isCorrect) {
//            return true
//        }
//        else if checkIfAscendingCorrect(isCorrect: isCorrect) {
//            return true
//        }
//        else if checkIfMaxDbThrice(isCorrect: isCorrect) {
//            return true
//        }
//
//        // Check if phase has changed
//        if(_isInitialPhase) {
//            // If first correct / incorrect after previous incorrects / corrects
//            // change phase
//            if(_currentDB > TEST_DEFAULT_DB && isCorrect)
//                      || (_currentDB < TEST_DEFAULT_DB && !isCorrect) {
//                _isInitialPhase = false
//            }
//        }
//
//        // Just update and play next db
//        // Compute next dB
//        var nextDB = _isInitialPhase
//                ? _currentDB + (isCorrect ? -20 : 20)
//                : _currentDB + (isCorrect ? -10 : 5)
//
//        // Bound next db
//        nextDB = min(nextDB, MAX_DB!)
//        nextDB = max(nextDB, MIN_DB!)
//        _currentDB = nextDB
//        _testPlayer.updateVolume(Double(_currentDB), _globalSetting.isTestingLeft)
//
//        testNextVolume()
//        return false
//    }

}


