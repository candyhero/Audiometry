//
//  TitleViewModel.swift
//  Audiometry
//
//  Created by Xavier Chan on 12/4/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import Foundation
import RxSwift

class TitleViewModel {
    
    // MARK: - Inputs
//    let onClickTest: AnyObserver<Void>
//    let onClickPractice: AnyObserver<Void>
    let onClickCalibration: AnyObserver<Void>
    let onClickResult: AnyObserver<Void>
    
    // MARK: - Outputs
    let showCalibrationView: Observable<Void>
    let showResultView: Observable<Void>
    
    let showAlertMessage: Observable<String>
    
    init(){
        let _onClickCalibration = PublishSubject<Void>()
        self.onClickCalibration = _onClickCalibration.asObserver()
        self.showCalibrationView = _onClickCalibration.asObservable()
        
        let _onClickResult = PublishSubject<Void>()
        self.onClickResult = _onClickResult.asObserver()
        self.showResultView = _onClickResult.asObservable()
        
        let _showAlertMessage = PublishSubject<String>()
        self.showAlertMessage = _showAlertMessage.asObservable()
    }
}
