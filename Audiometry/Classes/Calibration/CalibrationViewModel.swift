//
//  CalibrationViewModel.swift
//  Audiometry
//
//  Created by Xavier Chan on 12/4/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit
import RxSwift

class CalibrationViewModel {
    
    // MARK: - Inputs
    let onClickToggle: AnyObserver<CalibrationSettingValues>
    
    let togglePlayer: Observable<Void>
    
    // MARK: - Outputs
    
    init(){
        let _onClickToggle = PublishSubject<CalibrationSettingValues>()
        self.onClickToggle = _onClickToggle.asObserver()
        
        // Can just toggle player here, dont put into coordinator
        self.togglePlayer = _onClickToggle.asObservable()
            .map{ $0 }
    }
}
