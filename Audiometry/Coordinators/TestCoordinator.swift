//
//  TestCoordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 21/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit

class TestCoordinator: Coordinator {
    
    var _navController: UINavigationController = AppDelegate.navController
    
    func getTestLanguage() -> String! {
        return ""
    }
    
    func start() {
        return
    }
    
    func back() {
        self._navController.popViewController(animated: true)
    }
    
    func showTestView(sender: Any? = nil, isAdult: Bool) {
        let vc = isAdult ? AdultTestViewController.instantiate()
                         : ChildrenTestViewController.instantiate()
//        vc.coordinator = self
        self._navController.setNavigationBarHidden(true, animated: false)
        self._navController.show(vc, sender: nil)
    }
}
