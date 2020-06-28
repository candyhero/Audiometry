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
    let disposeBag = DisposeBag()
    var navigationController: UINavigationController!
    
    init(navController: UINavigationController) {
        navigationController = navController
    }
    
    override func start() -> Observable<Void> {
        let viewController = TestProtocolViewController.instantiate(AppStoryboards.Main)
        
        viewController.viewModelBuilder = { [weak self, disposeBag] in
            let viewModel = TestProtocolViewModel(input: $0)
            viewModel.router.showTitle
                .emit(onNext: { _ = self?.showTitleView(on: viewController) })
                .disposed(by: disposeBag)
            
            return viewModel
        }
        
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
    
    private func showTitleView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show title view")
        navigationController.popToRootViewController(animated: true)
        return Observable.never()
    }
}
