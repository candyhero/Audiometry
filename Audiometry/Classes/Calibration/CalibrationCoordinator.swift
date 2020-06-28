//
//  CalibrationCoordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 21/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit
import RxSwift

class CalibrationCoordinator: BaseCoordinator<Void> {
    
    /// Utility `DisposeBag` used by the subclasses.
    let disposeBag = DisposeBag()
    var navigationController: UINavigationController!
    
    init(navController: UINavigationController) {
        navigationController = navController
    }
    
    override func start() -> Observable<Void> {
        let viewController = CalibrationViewController.instantiate(AppStoryboards.Main)
        
        viewController.viewModelBuilder = { [weak self, disposeBag] in
            let viewModel = CalibrationViewModel(input: $0)
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
