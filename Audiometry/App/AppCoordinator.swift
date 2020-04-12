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

    init(window: UIWindow) {
        self.window = window
        super.init(nav: UINavigationController())
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        navigationController.setNavigationBarHidden(true, animated: false)
    }

    override func start() -> Observable<Void> {
        let titleCoordinator = TitleCoordinator(nav: navigationController)
        return coordinate(to: titleCoordinator)
    }
}
