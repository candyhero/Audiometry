//
//  CalibrationCoordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 21/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit
import CoreData

class CalibrationCoordinator: Coordinator {
    
    var _childCoordinators = [Coordinator]()
    var _navigationController: UINavigationController
    
    private var _globalSetting: GlobalSetting!
    private let _globalSettingRepo: GlobalSettingRepo = GlobalSettingRepo()
    private let _calibrationSettingRepo: CalibrationSettingRepo = CalibrationSettingRepo()
    
    init(_ navigationController: UINavigationController) {
        _navigationController = navigationController
        do {
            _globalSetting = try _globalSettingRepo.fetchGlobalSetting()
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
        self._navigationController.popViewController(animated: true)
    }
    
    // MARK:
    func getCurrentCalibrationSetting() -> CalibrationSetting!{
        print("Loading Calibration Setting")
        return self._globalSetting.calibrationSetting
    }
    
    func fetchAllCalibrationSettings() -> [CalibrationSetting]{
        do {
            return try _calibrationSettingRepo.fetchAll()
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
            _globalSetting = try _globalSettingRepo.update(_globalSetting)
        } catch let error as NSError {
            print("Could not create calibration setting.")
            print("\(error), \(error.userInfo)")
        }
        return _globalSetting.calibrationSetting!
    }
    
    func updateCalibrationSetting(_ calibrationSetting: CalibrationSetting) {
        self._globalSetting.calibrationSetting = calibrationSetting
        do{
            _globalSetting = try _globalSettingRepo.update(_globalSetting)
        } catch let error as NSError{
            print("Could not update calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    func deleteCalibrationSetting(_ calibrationSetting: CalibrationSetting) {
        self._globalSetting.calibrationSetting = nil
        do{
            try _calibrationSettingRepo.delete(calibrationSetting)
            _globalSetting = try _globalSettingRepo.update(_globalSetting)
        } catch let error as NSError{
            print("Could not delete calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
}
