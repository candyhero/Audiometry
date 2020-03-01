//
//  MainCoordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 20/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    // MARK:
    var _navController = AppDelegate.navController

    func start() {
        showTitleView(sender: nil)
    }

    func back() {
        _navController.popViewController(animated: true)
    }
    
    func getCurrentCalibrationSetting() -> CalibrationSetting! {
        do {
            let globalSetting = try GlobalSettingRepo.repo.fetchOrCreate()
            return globalSetting.calibrationSetting
        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }
        return nil
    }
    
    func setIsPractice(_ isPractice: Bool) {
        do {
            let globalSetting = try GlobalSettingRepo.repo.fetchOrCreate()
            globalSetting.isPractice = isPractice
            try GlobalSettingRepo.repo.update()
        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    func showTitleView(sender: Any? = nil) {
        let vc = TitleViewController.instantiate(AppStoryboards.Main)
        _navController.setNavigationBarHidden(true, animated: false)
        _navController.show(vc, sender: nil)
    }

    func showCalibrationView(sender: Any? = nil) {
        let vc = CalibrationViewController.instantiate(AppStoryboards.Main)
        vc.coordinator.start()
        _navController.setNavigationBarHidden(true, animated: false)
        _navController.show(vc, sender: nil)
    }

    func showTestProtocolView(sender: Any? = nil, isPractice: Bool) {
        setIsPractice(isPractice)
        
        let vc = TestProtocolViewController.instantiate(AppStoryboards.Main)
        vc.coordinator.start()
        _navController.setNavigationBarHidden(true, animated: false)
        _navController.show(vc, sender: nil)
    }

    func showResultView(sender: Any? = nil) {
        let vc = ResultViewController.instantiate(AppStoryboards.Main)
        _navController.setNavigationBarHidden(true, animated: false)
        _navController.show(vc, sender: nil)
    }
}
