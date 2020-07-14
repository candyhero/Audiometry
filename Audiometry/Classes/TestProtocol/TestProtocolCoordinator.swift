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
    
    init(navController: UINavigationController) {
        _navigationController = navController
    }
    
    override func start() -> Observable<Void> {
        let viewController = TestProtocolViewController.instantiate(AppStoryboards.Main)
        
        viewController.viewModelBuilder = { [weak self, _disposeBag] in
            let viewModel = TestProtocolViewModel(input: $0)
            viewModel.router.showTitle
                .emit(onNext: { _ = self?.showTitleView(on: viewController) })
                .disposed(by: _disposeBag)
            
            return viewModel
        }
        
        _navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
    
    private func showAdultTestInstructionView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show adult test instruction view")
        let testInstructionCoordinator = TestInstructionCoordinator(
            navController: _navigationController,
            isAdult: true
        )
        return coordinate(to: testInstructionCoordinator)
    }
    
    private func showChildrenTestInstructionView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show children test instruction view")
        let testInstructionCoordinator = TestInstructionCoordinator(
            navController: _navigationController,
            isAdult: false
        )
        return coordinate(to: testInstructionCoordinator)
    }
    
    private func showTitleView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show title view")
        _navigationController.popToRootViewController(animated: true)
        return Observable.never()
    }
}
