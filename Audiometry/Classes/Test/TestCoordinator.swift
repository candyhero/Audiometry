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
    private var _isAdult: Bool!
    
    init(navController: UINavigationController, isAdult: Bool) {
        _navigationController = navController
        _isAdult = isAdult
    }
    
    override func start() -> Observable<Void> {
        let viewController = _isAdult
            ? startAdultTestView()
            : startChildrenTestView()
        
        _navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
    
    private func startAdultTestView() -> UIViewController{
        let viewController = AdultTestViewController.instantiate(AppStoryboards.AdultTest)
            
        viewController.viewModelBuilder = { [weak self, _disposeBag] in
            let viewModel = TestViewModel(input: $0)

            return viewModel
        }
        return viewController
    }
    
    private func startChildrenTestView() -> UIViewController{
        let viewController = ChildrenTestViewController.instantiate(AppStoryboards.ChildrenTest)
            
        viewController.viewModelBuilder = { [weak self, _disposeBag] in
            let viewModel = TestViewModel(input: $0)

            return viewModel
        }
        return viewController
    }
    
    private func showTitleView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show title view")
        _navigationController.popToRootViewController(animated: true)
        return Observable.never()
    }
    
    private func showResultView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show result view")
        let resultCoordinator = ResultCoordinator(navController: _navigationController)
        return coordinate(to: resultCoordinator)
    }
}
