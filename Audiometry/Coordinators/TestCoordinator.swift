//
//  TestCoordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 21/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit

class TestCoordinator: Coordinator {
    // MARK:
    var _navController = AppDelegate.navController

    private let _globalSettingRepo = GlobalSettingRepo.repo
    private let _patientProfileRepo = PatientProfileRepo.repo

    // MARK: Read only
    private var _globalSetting: GlobalSetting!
    private var _patientProfileValues: [Int: PatientProfileValues]!
    private var _calibrationSettingValues: [Int: CalibrationSettingValues]!

    private var _isPractice: Bool!
    private var _isAdult: Bool!

    private var _MAX_DB, _MIN_DB: [Int: Int]!
    private var _testPlayer: TestPlayer!

    // MARK: will get updated
    private var _testFreqSequence: [Int]!

    // MARK: Test settings for current round
    private var _currentFreq: Int!
    private var _currentDB: Int!
    private var _currentPlayCase: PlayCase!
    private var _isInitialPhase: Bool!

    private var _startTime, _endTime: Date!

    private var _results: [Int]!
    private var _responses: [Int]!
    private var _cases: [PlayCase]!
    private var _hasBeenAscendingCorrect: [Int: Bool]!

    private var _spamCounter: Int = 0
    private var _maxDBTrials: Int = 0
    private var _noSoundCount: Int = 0
    private var _noSoundCorrect: Int = 0


    enum PlayCase : Int {
        case Error = -1
        case NoSound = 0
        case First = 1
        case Second = 2
    }

    func showTestView(sender: Any? = nil, isAdult: Bool) {
        let vc = isAdult
                ? AdultTestViewController.instantiate(AppStoryboards.AdultTest)
                : ChildrenTestViewController.instantiate(AppStoryboards.ChildrenTest)
        _navController.setNavigationBarHidden(true, animated: false)
        _navController.showDetailViewController(vc, sender: nil)

    }
    func showPauseView(sender: Any? = nil) {
    }
    func showResultView(sender: Any? = nil) {
    }

    func start() {
        loadTestSetting()
        setupPlayer()
        setupForNextFreq()
    }

    private func loadTestSetting() {
        do {
            _globalSetting = try _globalSettingRepo.fetchOrCreate()
            _isAdult = _globalSetting?.isAdult
            _isPractice = _globalSetting?.isPractice

            if let values = _globalSetting.calibrationSetting?.values as? [CalibrationSettingValues] {
                _calibrationSettingValues = Dictionary(uniqueKeysWithValues: values.map{(Int($0.frequency), $0)})
            }
            _patientProfileValues = [Int: PatientProfileValues]()

        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }

        _MAX_DB = Dictionary(uniqueKeysWithValues: DEFAULT_FREQ.map{ (freq) in
            let q = Double(TEST_MAX_DB) - (Z_FACTORS[freq] ?? 0.0)
            return (freq, _isAdult ? TEST_MAX_DB : Int((q/5).rounded(.down)) * 5)
        })
        _MIN_DB = Dictionary(uniqueKeysWithValues: DEFAULT_FREQ.map{ (freq) in
            return (freq, _isAdult ? TEST_MIN_DB_ADULT : TEST_MIN_DB_CHILDREN)}
        )
    }

    private func setupPlayer() {
        if (_isAdult) {
            _testPlayer = AdultTestPlayer()
        } else {
            _testPlayer = ChildrenTestPlayer()
        }
    }

    private func setupForNextFreq() {
        _currentFreq = _testFreqSequence.removeFirst()
        _currentDB = TEST_DEFAULT_DB
        _currentPlayCase = .Error
        _isInitialPhase = true

        _startTime = Date()

        _results = []
        _responses = []
        _cases = []
        _hasBeenAscendingCorrect.removeAll()

        _maxDBTrials = 0
        _spamCounter = 0
        _noSoundCount = 0
        _noSoundCorrect = 0

        // Config Test Player
        if let values = _calibrationSettingValues[_currentFreq] {
            let correctionFactor_L: Double = values.expectedLv - values.measuredLv_L
            let correctionFactor_R: Double = values.expectedLv - values.measuredLv_R
            _testPlayer.updateFreq(Int(values.frequency))
            _testPlayer.updateCorrectionFactors(correctionFactor_L, correctionFactor_R)
        }
    }

    func back() {
        AppDelegate.mainCoordinator.showTitleView()
    }

    // MARK: Getters
    func getTestLanguage() -> String{
        let testLanguage = TestLanguage(rawValue: Int(_globalSetting?.testLanguageCode ?? -1)) ?? TestLanguage.Invalid
        return testLanguage.toString()
    }

    func getTestFreq() -> Int{ return _currentFreq }

    func increaseSpamCount() {
        _spamCounter += 1
        print(_spamCounter)
    }

//    func terminatePlayer() {
//        _testPlayer.terminate()
//    }

    // MARK: Play logics
    func playSignalCase() {
        // Set init volume & random play case
        _testPlayer.updateVolume(Double(_currentDB), _globalSetting.isTestingLeft)

        _currentPlayCase = randomizePlayCase()

        // Second trial in practice needs to be no sound
        if(_isPractice && _results.count == 1) {
            _currentPlayCase = .NoSound
        }
        else {
            let counts = _cases.reduce(into: [:]) { $0[$1, default: 0] += 1 }
            if(counts[.First, default: 0] > counts[.Second, default: 0]
                    && _currentPlayCase == .First) {
                _currentPlayCase = randomizePlayCase()
            }
            else if(counts[.Second, default: 0] > counts[.First, default: 0]
                    && _currentPlayCase == .Second) {
                _currentPlayCase = randomizePlayCase()
            }

            if(_cases.last == _currentPlayCase && _cases.last == _cases[_responses.count-2])
            {
                //print("After redrawal: ",    _currentPlayCase)
                //print("Redraw Again")
                _currentPlayCase = randomizePlayCase()
            }
        }

        print("Playcase: ", _currentPlayCase)
        replaySignalCase()
    }

    private func randomizePlayCase() -> PlayCase {
        let preCheck = _results.isNotEmpty && _cases.last != .NoSound && _currentDB != _MAX_DB[_currentFreq]
        let randomInt = _isPractice ? Int.random(in:0 ..< 8) : Int.random(in:0 ..< 12)
        return (preCheck && randomInt < 2) ? .NoSound : (randomInt % 2 == 0 ? .First : .Second)
    }

    func replaySignalCase() {
        print("Current dB Lv: ", _currentDB)
        switch _currentPlayCase ?? .Error {
            case .NoSound:
                break
            case .First:
                self._testPlayer.playFirstInterval()
                break
            case .Second:
                // First interval time + Slience gap 0.5s
                self._testPlayer.playSecondInterval()
                break
            default: // Should never happen
                print("Playcase ERROR!!!")
                break
        }
    }

    func pausePlaying() { _testPlayer.stop() }

    // MARK: Checking Test progress
    func checkResponse(_ buttonTag: Int) -> Bool! {
        switch _currentPlayCase ?? .Error {
            case .NoSound:
                return checkNoSound(buttonTag == 0)
                break
            case .First:
                return checkThreshold(buttonTag == 1)
                break
            case .Second:
                return checkThreshold(buttonTag == 2)
                break
            default: // Should never be this case
                print("Playcase ERROR!!!")
                return false
                break
        }
    }
    private func checkNoSound(_ isCorrect: Bool!) -> Bool!{
        _results.append(_currentDB)
        _responses.append(0)
        _cases.append(_currentPlayCase)

        _noSoundCount += 1
        if(isCorrect) { _noSoundCorrect += 1 }
        return false
    }

    private func checkThreshold(_ isCorrect: Bool!) -> Bool!{
        // Update current response to tracking list
        let MAX_DB = _MAX_DB[_currentFreq]
        let MIN_DB = _MIN_DB[_currentFreq]

        let lastDB = _results.last
        let lastPlayCase = _cases.last
        let wasLastCorrect = (_currentDB < (lastDB ?? _currentDB+1))

        _results.append(_currentDB)
        _responses.append(isCorrect ? 1 : -1)
        _cases.append(_currentPlayCase)

        // check if 0 db
        if(_currentDB == MIN_DB) {
            if (isCorrect && (lastDB == MIN_DB) && lastPlayCase != .NoSound) {
                endTest(MIN_DB)
                return true
            }
        }
        // Check if 3 max DB in a row
        else if (_currentDB == TEST_MAX_DB) {
            _maxDBTrials = isCorrect ? 0 : _maxDBTrials + 1;
            if(_maxDBTrials == 3) {
                endTest(-1)
                return true
            }
        }

        // Determine if this is an ascending + response
        if (!wasLastCorrect && isCorrect) {
            // Determine if test can be ended
            // Twice correct in a row on the same freq
            if _hasBeenAscendingCorrect[_currentDB] ?? false {
                endTest(_currentDB)
                return true
            }
            else {
                _hasBeenAscendingCorrect[_currentDB] = true
            }
        }

        // Check if phase has changed
        if(_isInitialPhase) {
            // If first correct / incorrect after previous incorrects / corrects
            // change phase
            if(_currentDB > TEST_DEFAULT_DB && isCorrect)
                      || (_currentDB < TEST_DEFAULT_DB && !isCorrect) {
                _isInitialPhase = false
            }
        }

        // Just update and play next db
        // Compute next dB
        var nextDB = _isInitialPhase
                ? _currentDB + (isCorrect ? -20 : 20)
                : _currentDB + (isCorrect ? -10 : 5)

        // Bound next db
        nextDB = min(nextDB, MAX_DB!)
        nextDB = max(nextDB, MIN_DB!)
        _currentDB = nextDB
        return false
    }

    private func endTest(_ thresholdDB: Int!) {
        _endTime = Date()

        // Setup patient profile values for CoreData
        let newValues = _patientProfileValues[_currentFreq] ?? _patientProfileRepo.createValues()
        newValues.frequency = Int16(_currentFreq)

        if _globalSetting.isTestingLeft {
            newValues.threshold_L = Int16(thresholdDB)
            newValues.results_L = _results
            newValues.responses_L = _responses
            newValues.no_sound_count_L = Int16(_noSoundCount)
            newValues.no_sound_correct_L = Int16(_noSoundCorrect)
            newValues.spamCount_L = Int16(_spamCounter)

            newValues.startTime_L = _startTime
            newValues.endTime_L = _endTime
            newValues.durationSeconds_L = Int16(_endTime.timeIntervalSince(_startTime))
        } else {
            newValues.threshold_R = Int16(thresholdDB)
            newValues.results_R = _results
            newValues.responses_R = _responses
            newValues.no_sound_count_R = Int16(_noSoundCount)
            newValues.no_sound_correct_R = Int16(_noSoundCorrect)
            newValues.spamCount_R = Int16(_spamCounter)

            newValues.startTime_R = _startTime
            newValues.endTime_R = _endTime
            newValues.durationSeconds_R = Int16(_endTime.timeIntervalSince(_startTime))
        }
        _patientProfileValues[_currentFreq] = newValues

        do{
            _globalSetting.patientProfile?.addToValues(newValues)
            _globalSetting.patientProfile?.endTime = _endTime

            if let timestamp = _globalSetting.patientProfile?.timestamp {
                _globalSetting.patientProfile?.durationSeconds =
                        Int16(_endTime.timeIntervalSince(timestamp))
            }
            try _globalSettingRepo.update()
        } catch let error as NSError{
            print("Could not save test results.")
            print("\(error), \(error.userInfo)")
        }

        if(_testFreqSequence.count > 0) {
            setupForNextFreq()
        } else {
            if(_globalSetting.isTestingBoth) {
                _currentFreq = -1
                _globalSetting.isTestingBoth = false
                _globalSetting.isTestingLeft = !(_globalSetting.isTestingLeft)
                _globalSetting.patientProfile?.earOrder = _globalSetting.isTestingLeft ? "RL" : "LR"
//                print(_globalSetting.patientProfile?.earOrder)
            } else {
                _currentFreq = 0
            }
        }
//        print("Test Count: ", _globalSetting.patientProfile?.values?.count)
    }
}
