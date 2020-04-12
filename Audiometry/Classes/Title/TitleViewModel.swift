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
    let clickCalibration: AnyObserver<Void>
    
    // MARK: - Outputs
    let showCalibration: Observable<Void>
    
    init(){
        let _clickCalibration = PublishSubject<Void>()
        self.clickCalibration = _clickCalibration.asObserver()
        self.showCalibration = _clickCalibration.asObservable()
    }
}
