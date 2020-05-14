//
//  AppCoordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 12/4/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit
import RxSwift

class AppCoordinator: BaseCoordinator<Void> {

    private let window: UIWindow
    
    /// Utility `DisposeBag` used by the subclasses.
    let disposeBag = DisposeBag()
    var navigationController = UINavigationController()
    
    init(window: UIWindow) {
        self.window = window
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        navigationController.setNavigationBarHidden(true, animated: false)
    }

    override func start() -> Observable<Void> {
        let titleCoordinator = TitleCoordinator(navController: navigationController)
        return coordinate(to: titleCoordinator)
    }
}
