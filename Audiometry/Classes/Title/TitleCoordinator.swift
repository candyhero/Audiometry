//
//  TitleCoordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 12/4/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit
import RxSwift

class TitleCoordinator: BaseCoordinator<Void> {

    /// Utility `DisposeBag` used by the subclasses.
    let disposeBag = DisposeBag()
    var navigationController: UINavigationController!
    
    init(navController: UINavigationController) {
        navigationController = navController
    }
    
    override func start() -> Observable<Void> {
        let viewController = TitleViewController.instantiate(AppStoryboards.Main)
        
        viewController.viewModelBuilder = { [weak self, disposeBag] in
            let viewModel = TitleViewModel(input: $0)
            
            viewModel.router.showCalibration
                .emit(onNext: { _ = self?.showCalibrationView(on: viewController) })
                .disposed(by: disposeBag)
            
            viewModel.router.showResult
                .emit(onNext: { _ = self?.showResultView(on: viewController) })
                .disposed(by: disposeBag)
            
            return viewModel
        }
        
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
    
    private func showCalibrationView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show calibration view")
        let calibrationCoordinator = CalibrationCoordinator(navController: navigationController)
        return coordinate(to: calibrationCoordinator)
    }
    
    private func showResultView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show result view")
        let resultCoordinator = ResultCoordinator(navController: navigationController)
        return coordinate(to: resultCoordinator)
    }
}
