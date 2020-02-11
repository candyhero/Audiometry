//
//  CalibrationCoordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 21/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit

class CalibrationCoordinator: Coordinator {
    
    var _navController: UINavigationController = AppDelegate.navController
    
    // MARK:
    private let _globalSettingRepo = GlobalSettingRepo.repo
    private let _calibrationSettingRepo = CalibrationSettingRepo.repo
    
    private var _globalSetting: GlobalSetting!
    
    // MARK:
    init() {
        do {
            _globalSetting = try _globalSettingRepo.fetchOrCreate()
        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    // MARK:
    func start() {
        return
    }
    
    func back() {
        self._navController.popViewController(animated: true)
    }
    
    // MARK:
    func getCurrentCalibrationSetting() -> CalibrationSetting!{
        print("Loading Calibration Setting")
        return self._globalSetting.calibrationSetting
    }
    
    func fetchAllCalibrationSettings() -> [CalibrationSetting]{
        do {
            return try _calibrationSettingRepo.fetchAllSorted()
        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }
        return [CalibrationSetting]()
    }
    
    func saveCalibrationSetting(_ settingName: String,
                                ui: [Int: CalibrationSettingUI]) -> CalibrationSetting {
        _globalSetting.calibrationSetting = _calibrationSettingRepo.createNew(settingName, ui)
        do {
            try _globalSettingRepo.update()
        } catch let error as NSError {
            print("Could not create calibration setting.")
            print("\(error), \(error.userInfo)")
        }
        return _globalSetting.calibrationSetting!
    }
    
    func updateCalibrationSetting(_ calibrationSetting: CalibrationSetting) {
        self._globalSetting.calibrationSetting = calibrationSetting
        do{
            try _globalSettingRepo.update()
        } catch let error as NSError{
            print("Could not update calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    func deleteCalibrationSetting(_ calibrationSetting: CalibrationSetting) {
        self._globalSetting.calibrationSetting = nil
        do{
            try _calibrationSettingRepo.delete(calibrationSetting)
            try _globalSettingRepo.update()
        } catch let error as NSError{
            print("Could not delete calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
}
