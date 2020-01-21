//
//  TestCoordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 21/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit

class TestCoordinator: Coordinator {
    
    var _childCoordinators = [Coordinator]()
    var _navigationController: UINavigationController
    
    
    init(_ navigationController: UINavigationController) {
        self._navigationController = navigationController
    }
    
    func start() {
        return
    }
    
    func back() {
        self._navigationController.popViewController(animated: true)
    }
}
