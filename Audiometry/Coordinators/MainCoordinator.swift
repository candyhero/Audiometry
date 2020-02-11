//
//  MainCoordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 20/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    
    var _navController: UINavigationController = AppDelegate.navController
    
    func start() {
        showTitleView(sender: nil)
    }
    
    func back() {
        self._navController.popViewController(animated: true)
    }
    
    func getCurrentCalibrationSetting() -> CalibrationSetting! {
        return AppDelegate.calibrationCoordinator.getCurrentCalibrationSetting() ?? nil
    }
    
    func showTitleView(sender: Any? = nil) {
        let vc = TitleViewController.instantiate()
        self._navController.setNavigationBarHidden(true, animated: false)
        self._navController.show(vc, sender: nil)
    }
    
    func showCalibrationView(sender: Any? = nil) {
        let vc = CalibrationViewController.instantiate()
        self._navController.setNavigationBarHidden(true, animated: false)
        self._navController.show(vc, sender: nil)
    }
    
    func showTestProtoclView(sender: Any? = nil, isPractice: Bool) {
        let vc = TestProtocolViewController.instantiate()
        self._navController.setNavigationBarHidden(true, animated: false)
        self._navController.show(vc, sender: nil)
    }
    
    func showResultView(sender: Any? = nil) {
        let vc = ResultViewController.instantiate()
        self._navController.setNavigationBarHidden(true, animated: false)
        self._navController.show(vc, sender: nil)
    }
}
