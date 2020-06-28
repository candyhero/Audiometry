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
    private let disposeBag = DisposeBag()
    private var navigationController: UINavigationController!
    
    init(navController: UINavigationController) {
        navigationController = navController
    }
    
    override func start() -> Observable<Void> {
        let viewController = TitleViewController.instantiate(AppStoryboards.Main)
        
        viewController.viewModelBuilder = {[weak self, disposeBag] in
            let viewModel = TitleViewModel(input: $0)
            
            viewModel.router.showCalibration
                .emit(onNext: { _ = self?.showCalibrationView(on: viewController) })
                .disposed(by: disposeBag)
            
//            viewModel.router.showResult
//                .emit(onNext: { _ = self?.showResultView(on: viewController) })
//                .disposed(by: disposeBag)
            
            viewModel.router.showTest
                .emit(onNext: { _ = self?.showTestProtocolView(on: viewController) })
                .disposed(by: disposeBag)
            
            return viewModel
        }
        
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
    
    func showCalibrationView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show calibration view")
        let calibrationCoordinator = CalibrationCoordinator(navController: navigationController)
        return coordinate(to: calibrationCoordinator)
    }
    
    func showResultView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show result view")
        let resultCoordinator = ResultCoordinator(navController: navigationController)
        return coordinate(to: resultCoordinator)
    }
    
    func showTestProtocolView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show test protocol view")
        let testProtocolCoordinator = TestProtocolCoordinator(navController: navigationController)
        return coordinate(to: testProtocolCoordinator)
    }
}
