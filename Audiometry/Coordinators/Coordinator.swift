//
//  Coordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 20/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit

protocol Coordinator {
    var _childCoordinators: [Coordinator] { get set }
    var _navigationController: UINavigationController { get set }
    
    func start()
    func back()
}
