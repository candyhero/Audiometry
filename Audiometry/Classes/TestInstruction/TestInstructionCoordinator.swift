//
//  TestInstructionCoordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 14/7/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import UIKit
import RxSwift

class TestInstructionCoordinator: BaseCoordinator<Void> {
    
    /// Utility `DisposeBag` used by the subclasses.
    private let _disposeBag = DisposeBag()
    private var _navigationController: UINavigationController!
    private var _isAdult: Bool!
    
    init(navController: UINavigationController, isAdult: Bool) {
        _navigationController = navController
    }
    
    override func start() -> Observable<Void> {
        let viewController = _isAdult
            ? startAdultTestInstructionView()
            : startAdultTestInstructionView()

        _navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
    
    private func startAdultTestInstructionView() -> UIViewController{
        let viewController = AdultTestInstructionViewController.instantiate(AppStoryboards.AdultTest)
            
        viewController.viewModelBuilder = { [weak self, _disposeBag] in
            let viewModel = TestInstructionViewModel(input: $0)

            return viewModel
        }
        return viewController
    }
    
    func showAdultTest(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show adult test view")
        return Observable.never()
    }
}
