//
//  TestCoordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 13/7/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import UIKit
import RxSwift

class TestCoordinator: BaseCoordinator<Void> {
    
    /// Utility `DisposeBag` used by the subclasses.
    private let _disposeBag = DisposeBag()
    private var _navigationController: UINavigationController!
    
    init(navController: UINavigationController) {
        _navigationController = navController
    }
    
    override func start() -> Observable<Void> {
        return Observable.never()
    }
    
    func showAdultTest(on rootViewController: UIViewController) -> Observable<Void> {
        
        print("Show adult test view")
        let calibrationCoordinator = CalibrationCoordinator(navController: _navigationController)
        return Observable.never()
    }
}
