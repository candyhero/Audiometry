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
    
    override func start() -> Observable<Void> {
        let viewController = TitleViewController.instantiate(AppStoryboards.Main)
        let viewModel = TitleViewModel()
        viewController.viewModel = viewModel
        
        viewModel.showCalibration
            .subscribe(onNext: {
                [weak self] in self?.showCalibrationView(on: viewController)
            })
            .disposed(by: disposeBag)
        
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
    
    private func showCalibrationView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show calibration view")
        let calibrationCoordinator = CalibrationCoordinator(nav: navigationController)
        return coordinate(to: calibrationCoordinator)
    }
}
