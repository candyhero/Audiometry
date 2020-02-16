//
//  CalibrationCoordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 21/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit

class CalibrationCoordinator: Coordinator {
    // MARK:
    var _navController = AppDelegate.navController

    private let _globalSettingRepo = GlobalSettingRepo.repo
    private let _calibrationSettingRepo = CalibrationSettingRepo.repo

    // MARK:
    private var _player: CalibrationPlayer = CalibrationPlayer()

    private var _globalSetting: GlobalSetting!
    private var _settings: [CalibrationSetting]!

    // MARK:
    func start() {
        do {
            _globalSetting = try _globalSettingRepo.fetchOrCreate()
            _settings = []
        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    func back() {
        if(_player.isStarted()) {
            _player.stopPlaying()
        }
        _navController.popViewController(animated: true)

    }

    // MARK:
    func togglePlayer(_ currentFreq: Int, _ newFreq: Int, _ ui: CalibrationSettingUI) -> Int {
        if(!_player.isStarted()) {
            _player.startPlaying()
        }
        else if(currentFreq == newFreq) {
            _player.stopPlaying()
            return -1
        }

        _player.updateFreq(newFreq)
        _player.updateVolume(ui)
        return newFreq
    }
    
    // MARK:
    func getCalibrationSetting() -> CalibrationSetting! {
        return _globalSetting.calibrationSetting
    }

    func setCalibrationSettingByPicker(_ pickerIndex: Int) -> CalibrationSetting!{
        _globalSetting.calibrationSetting = _settings[pickerIndex]
        return _globalSetting.calibrationSetting
    }

    func getAllCalibrationSettings() -> [CalibrationSetting] {
        return _settings
    }

    func fetchAllCalibrationSettings() {
        do {
            _settings = try _calibrationSettingRepo.fetchAllSorted()
        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    func saveCalibrationSetting(_ settingName: String, ui: [Int: CalibrationSettingUI]) {
        _globalSetting.calibrationSetting = _calibrationSettingRepo.createNew(settingName, ui)
        do {
            try _globalSettingRepo.update()
        } catch let error as NSError {
            print("Could not create calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    func updateCalibrationSetting(ui: [Int: CalibrationSettingUI]) {
        let setting = _globalSetting.calibrationSetting!
        setting.timestamp = Date()
        let values = setting.getDictionary()

        for (freq, settingUI) in ui {
            settingUI.extractValuesInto(values[freq]!)
        }
        do{
            _globalSetting.calibrationSetting = setting
            try _globalSettingRepo.update()
        } catch let error as NSError{
            print("Could not update calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    func deleteCalibrationSetting() {
        do{
            try _calibrationSettingRepo.delete(_globalSetting.calibrationSetting!)
            try _globalSettingRepo.update()
            _globalSetting.calibrationSetting = nil
        } catch let error as NSError{
            print("Could not delete calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
}
