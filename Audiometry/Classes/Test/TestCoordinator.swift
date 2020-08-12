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
    private var _viewController: UIViewController!
    private var _role: PatientRole!
    
    init(navController: UINavigationController, role: PatientRole) {
        _navigationController = navController
        _role = role
    }
    
    override func start() -> Observable<Void> {
        switch _role {
        case .Adult:
            let viewController = AdultTestViewController.instantiate(AppStoryboards.AdultTest)
            viewController.viewModelBuilder = startTestViewModel
            _viewController = viewController
            break
        case .Children:
            let viewController = ChildrenTestViewController.instantiate(AppStoryboards.AdultTest)
            viewController.viewModelBuilder = startTestViewModel
            _viewController = viewController
            break
        default:
            return Observable.never()
        }
        _navigationController.pushViewController(_viewController, animated: true)
        return Observable.never()
    }
    
    private func startTestViewModel(input: TestViewModel.Input) -> TestViewModel {
        let viewModel = TestViewModel(input: input)
        
        if let viewController = _viewController {
            viewModel.router.showTitle
                .emit(onNext: { [weak self] in
                    _ = self?.showTitleView(on: viewController)
                })
                .disposed(by: _disposeBag)
        }
        return viewModel
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
