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
    private let _disposeBag = DisposeBag()
    private var _navigationController: UINavigationController!
    
    init(navController: UINavigationController) {
        _navigationController = navController
    }
    
    override func start() -> Observable<Void> {
        let viewController = TitleViewController.instantiate(AppStoryboards.Main)
        
        viewController.viewModelBuilder = { [weak self, _disposeBag] in
            let viewModel = TitleViewModel(input: $0)
            
            viewModel.router.showCalibration
                .emit(onNext: { _ = self?.showCalibrationView(on: viewController) })
                .disposed(by: _disposeBag)
            
//            viewModel.router.showResult
//                .emit(onNext: { _ = self?.showResultView(on: viewController) })
//                .disposed(by: disposeBag)
            
            viewModel.router.showTest
                .emit(onNext: { _ = self?.showTestProtocolView(on: viewController) })
                .disposed(by: _disposeBag)
            
            return viewModel
        }
        
        _navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
    
    private func showCalibrationView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show calibration view")
        let calibrationCoordinator = CalibrationCoordinator(navController: _navigationController)
        return coordinate(to: calibrationCoordinator)
    }
    
    private func showTestProtocolView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show test protocol view")
        let testProtocolCoordinator = TestProtocolCoordinator(navController: _navigationController)
        return coordinate(to: testProtocolCoordinator)
    }
    
    private func showResultView(on rootViewController: UIViewController) -> Observable<Void> {
        print("Show result view")
        let resultCoordinator = ResultCoordinator(navController: _navigationController)
        return coordinate(to: resultCoordinator)
    }
}
