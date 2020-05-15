//
//  CalibrationViewModel.swift
//  Audiometry
//
//  Created by Xavier Chan on 12/4/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol CalibrationViewPresentable {
    // MARK: - Inputs
    typealias Input = (
        onClickReturn: Signal<Void>,
//        onClickSetVolume: Signal<>
        ()
    )
    
    // MARK: - Outputs
    typealias Output = (
        
    )
    
    typealias ViewModelBuilder = (CalibrationViewPresentable.Input) -> CalibrationViewPresentable
    
    var input: CalibrationViewPresentable.Input { get }
    var output: CalibrationViewPresentable.Output { get }
}

class CalibrationViewModel: CalibrationViewPresentable {
    var input: CalibrationViewPresentable.Input
    var output: CalibrationViewPresentable.Output
    
    typealias Routing = (
        showTitle: Signal<Void>,
        ()
    )
    
    lazy var router: Routing = (
        showTitle: input.onClickReturn,
        ()
    )
    
    init(input: CalibrationViewPresentable.Input){
        self.input = input
        self.output = CalibrationViewModel.output(input: input)
    }
}

private extension CalibrationViewModel {
    // MARK: - Return output to view here, e.g. alert message
    static func output(input: CalibrationViewPresentable.Input) ->
        CalibrationViewPresentable.Output {
        return ()
    }
}
