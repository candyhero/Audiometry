//
//  TestProtocolCoordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 28/6/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import UIKit
import RxSwift

class TestProtocolCoordinator: BaseCoordinator<Void> {
    
    /// Utility `DisposeBag` used by the subclasses.
    private let _disposeBag = DisposeBag()
    private var _navigationController: UINavigationController!
    private var _testMode: TestMode!
    
    init(navController: UINavigationController, testMode: TestMode) {
        _navigationController = navController
        _testMode = testMode
    }
    
    override func start() -> Observable<Void> {
        let viewController = TestProtocolViewController.instantiate(AppStoryboards.Main)
        
        viewController.viewModelBuilder = { [weak self, _disposeBag] in
            let viewModel = TestProtocolViewModel(input: $0)
            viewModel.setTestMode(testMode: self?._testMode ?? TestMode.Invalid)
            
            viewModel.router.showTitle
                .emit(onNext: { _ = self?.showTitleView(on: viewController) })
                .disposed(by: _disposeBag)
            
            viewModel.router.startTest
                .emit(onNext: {
                    _ = self?.showTestInstructionView(on: viewController, role: $0)
                })
                .disposed(by: _disposeBag)
            
            return viewModel
        }
        
        _navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
    
    private func showTestInstructionView(on rootViewController: UIViewController,
                                         role: PatientRole) -> Observable<Void> {
        print("Show adult test instruction view")
        let testInstructionCoordinator = TestInstructionCoordinator(
            navController: _navigationController,
            role: role
        )
        return coordinate(to: testInstructionCoordinator)
    }
    
    private func showTitleView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show title view")
        _navigationController.popToRootViewController(animated: true)
        return Observable.never()
    }
}
