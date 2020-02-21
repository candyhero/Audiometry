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
    private var _player: CalibrationPlayer!
    private var _globalSetting: GlobalSetting!
    
    func start() {
        do {
            _globalSetting = try _globalSettingRepo.fetchOrCreate()
        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }
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

    // MARK:
    func getTestLanguage() -> String{
        let testLanguage = TestLanguage(rawValue: Int(_globalSetting?.testLanguageCode ?? -1)) ?? TestLanguage.Invalid
        return testLanguage.toString()
    }
}
