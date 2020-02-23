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

    // MARK:
    private var _globalSetting: GlobalSetting!
    private var _patientProfileValues: [Int:PatientProfileValues]!
    private var _calibrationSettingValues: [Int:CalibrationSettingValues]!

    private var _isPractice: Bool!
    private var _isAdult: Bool!

    private var _MAX_DB, _MIN_DB: [Int: Int]!
    private var _startTime, _endTime: Date!
    private var _testPlayer: TestPlayer!

    // MARK:
    private var _array_testFreqSeq: [Int] = []
    private var _results: [Int] = []
    private var _array_responses: [Int] = []
    private var _cases: [PlayCase] = []

    // In-test settings
    private var _currentFreq: Int!
    private var _currentDB: Int!
    private var _currentPlayCase: PlayCase

    private var _isInitialPhase: Bool!
    private var _hasBeenAscendingCorrect = [Int: Bool]()

    private var _maxDBTrials: Int = 0
    private var _noSoundCount: Int = 0
    private var _noSoundCorrect: Int = 0

    private var _spamCounter: Int = 0

    enum PlayCase : Int {
        case NoSound = 0
        case First = 1
        case Second = 2
    }
    func start() {
        loadTestSetting()
        setupForNextFreq()
    }

    private func loadTestSetting() {
        do {
            _globalSetting = try _globalSettingRepo.fetchOrCreate()
            if let values = _globalSetting.calibrationSetting?.values as? [CalibrationSettingValues] {
                _calibrationSettingValues = Dictionary(uniqueKeysWithValues: values.map{(Int($0.frequency), $0)})
            }
            _isAdult = _globalSetting?.isAdult
            _isPractice = _globalSetting?.isPractice

        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }

        _MAX_DB = Dictionary(uniqueKeysWithValues: DEFAULT_FREQ.map{ (freq) in
            let q = Double(TEST_MAX_DB) - (Z_FACTORS[freq] ?? 0.0)
            return (freq, _isAdult ? TEST_MAX_DB : Int((q/5).rounded(.down)) * 5)
        })
        _MIN_DB = Dictionary(
                uniqueKeysWithValues: DEFAULT_FREQ.map{ ($0, _isAdult ? TEST_MIN_DB_ADULT : TEST_MIN_DB_CHILDREN)}
        )
        if (_isAdult) {
            _testPlayer = AdultTestPlayer()
        } else {
            _testPlayer = ChildrenTestPlayer()
        }
    }

    private func setupForNextFreq() {
        _currentFreq = _array_testFreqSeq.removeFirst()

        // Config Test Player
        if let values = _calibrationSettingValues[_currentFreq] {
            let correctionFactor_L: Double = values.expectedLv - values.measuredLv_L
            let correctionFactor_R: Double = values.expectedLv - values.measuredLv_R
            _testPlayer.updateFreq(Int(values.frequency))
            _testPlayer.updateCorrectionFactors(correctionFactor_L, correctionFactor_R)
        }

        // Init buffs at current Freq to storing results
        _results = []
        _array_responses = []
        _cases = []

        _startTime = Date()

        _isInitialPhase = true

        _spamCounter = 0

        _maxDBTrials = 0
        _noSoundCount = 0
        _noSoundCorrect = 0
        _currentDB = TEST_DEFAULT_DB
        _hasBeenAscendingCorrect.removeAll()
    }


    func back() {
        AppDelegate.mainCoordinator.showTitleView()
    }
    
    func showTestView(sender: Any? = nil, isAdult: Bool) {
        let vc = isAdult
                ? AdultTestViewController.instantiate(AppStoryboards.AdultTest)
                : ChildrenTestViewController.instantiate(AppStoryboards.ChildrenTest)
        _navController.setNavigationBarHidden(true, animated: false)
        _navController.showDetailViewController(vc, sender: nil)

    }

    // MARK: Getters
    func getTestLanguage() -> String{
        let testLanguage = TestLanguage(rawValue: Int(_globalSetting?.testLanguageCode ?? -1)) ?? TestLanguage.Invalid
        return testLanguage.toString()
    }

    func playSignalCase() {
        // Set init volume & random play case
        _testPlayer.updateVolume(Double(_currentDB), _globalSetting.isTestingLeft)

        _currentPlayCase = randomizePlayCase()

        // Second trial in practice needs to be no sound
        if(_isPractice && _results.count == 1) {
            _currentPlayCase = .NoSound
        }
        else if(_cases.count >= 2) {
            let counts = _cases.reduce(into: [:]) { $0[$1, default: 0] += 1 }
            if(counts[.First, default: 0] > counts[.Second, default: 0]
                    && _currentPlayCase == .First) {
                _currentPlayCase = randomizePlayCase()
            }
            else if(counts[.Second, default: 0] > counts[.First, default: 0]
                    && _currentPlayCase == .Second) {
                _currentPlayCase = randomizePlayCase()
            }

            if(_cases.last == _currentPlayCase && _cases.last == _cases[_array_responses.count-2])
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
        switch _currentPlayCase {
            case .NoSound: // Slient interval
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

    func pausePlaying() { _testPlayer.stop() }
}
