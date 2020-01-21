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
    private let calibrationSettingRepo: CalibrationSettingRepo = CalibrationSettingRepo()
    
    init(_ navigationController: UINavigationController) {
        self._navigationController = navigationController
    }
    
    // MARK:
    func start() {
        return
    }
    
    func back() {
        self._navigationController.popViewController(animated: true)
    }
    
    // MARK:
    func getCalibrationSetting(){
        
    }
    
    func saveCalibrationSetting(
        settingName: String,
        values: [CalibrationSettingValues]
    ){
        do {
            _globalSetting.calibrationSetting =
                try calibrationSettingRepo.saveNewCalibrationSetting(settingName, values)
        } catch let error as NSError {
            print("\(error), \(error.userInfo)")
        }
    }
    
    func fetchAllCalibrationSettings() -> [CalibrationSetting]{
        do {
            return try calibrationSettingRepo.fetchAll()
        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }
        return [CalibrationSetting]()
    }
    
    func updateGlobalSetting(_ calibrationSetting: CalibrationSetting) {
        self._globalSetting.calibrationSetting = calibrationSetting
        // save in managed context
    }
}
