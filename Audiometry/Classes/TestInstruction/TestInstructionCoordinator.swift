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
    private var _viewController: UIViewController!
    private var _role: PatientRole!
    
    init(navController: UINavigationController, role: PatientRole) {
        _navigationController = navController
        _role = role
    }
    
    override func start() -> Observable<Void> {
        switch _role {
        case .Adult:
            let viewController = AdultTestInstructionViewController.instantiate(AppStoryboards.AdultTest)
            viewController.viewModelBuilder = startTestInstructionViewModel
            _viewController = viewController
            break
        case .Children:
            let viewController = ChildrenTestInstructionViewController.instantiate(AppStoryboards.ChildrenTest)
            viewController.viewModelBuilder = startTestInstructionViewModel
            _viewController = viewController
            break
        default:
            return Observable.never()
        }
        _navigationController.pushViewController(_viewController, animated: true)
        return Observable.never()
    }
    
    private func startTestInstructionViewModel(input: TestInstructionViewModel.Input) -> TestInstructionViewModel {
        let viewModel = TestInstructionViewModel(input: input)
        if let viewController = _viewController {
            viewModel.router.showTitle
                .emit(onNext: { [weak self] in
                    _ = self?.showPreviousView(on: viewController)
                })
                .disposed(by: _disposeBag)
            
            viewModel.router.startTest
                .emit(onNext: { [weak self] in
                    _ = self?.showTestView(on: viewController)
                })
                .disposed(by: _disposeBag)
        }
        return viewModel
    }
    
    private func showPreviousView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show previous view")
        _navigationController.popViewController(animated: true)
        return Observable.never()
    }
    
    private func showTestView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show adult test view")
        let testCoordinator = TestCoordinator(navController: _navigationController, role: _role)
        return coordinate(to: testCoordinator)
    }
}
