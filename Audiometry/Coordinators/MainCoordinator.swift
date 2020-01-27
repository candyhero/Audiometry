//
//  MainCoordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 20/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    
    var _childCoordinators = [Coordinator]()
    var _navigationController: UINavigationController
    
    private let _calibrationCoordinator: CalibrationCoordinator
    
    // MARK:
    private let _globalSettingRepo = GlobalSettingRepo()
    
    init(_ navigationController: UINavigationController) {
        self._navigationController = navigationController
        self._calibrationCoordinator = CalibrationCoordinator(_navigationController)
    }
    
    func start() {
        showTitleView(sender: nil)
    }
    
    func back() {
        self._navigationController.popViewController(animated: true)
    }
    
    func getCurrentCalibrationSetting() -> CalibrationSetting! {
        return _calibrationCoordinator.getCurrentCalibrationSetting() ?? nil
    }
    
    func showTitleView(sender: Any?) {
        let vc = TitleViewController.instantiate()
        vc.coordinator = self
        self._navigationController.setNavigationBarHidden(true, animated: false)
        self._navigationController.show(vc, sender: nil)
    }
    
    func showCalibrationView(sender: Any?) {
        let vc = CalibrationViewController.instantiate()
        vc.coordinator = self._calibrationCoordinator
        self._navigationController.setNavigationBarHidden(true, animated: false)
        self._navigationController.show(vc, sender: nil)
    }
    
    func showTestProtoclView(sender: Any?) {
        let vc = TestProtocolViewController.instantiate()
        vc.coordinator = self
        self._navigationController.setNavigationBarHidden(true, animated: false)
        self._navigationController.show(vc, sender: nil)
    }
    
    func showResultView(sender: Any?) {
        let vc = ResultViewController.instantiate()
        vc.coordinator = self
        self._navigationController.setNavigationBarHidden(true, animated: false)
        self._navigationController.show(vc, sender: nil)
    }
}
