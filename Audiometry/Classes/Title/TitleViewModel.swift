//
//  TitleViewModel.swift
//  Audiometry
//
//  Created by Xavier Chan on 12/4/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol TitleViewPresentable {
    // MARK: - Inputs
    typealias Input = (
        onClickTest: Signal<Void>,
        onClickPractice: Signal<Void>,
        onClickCalibration: Signal<Void>,
        onClickResult: Signal<Void>
    )
    
    // MARK: - Outputs
    typealias Output = (
//        alertMessage: Observable<String>
    )
    
    typealias ViewModelBuilder = (TitleViewPresentable.Input) -> TitleViewPresentable
      
    var input: TitleViewPresentable.Input { get }
    var output: TitleViewPresentable.Output { get }
}

class TitleViewModel: TitleViewPresentable {
    var input: TitleViewPresentable.Input
    var output: TitleViewPresentable.Output
    
    // MARK: - Routings used by coordinator
    typealias Routing = (
        showTest: Signal<Void>,
        showPractice: Signal<Void>,
        showCalibration: Signal<Void>,
        showResult: Signal<Void>
    )
    lazy var router: Routing = (
        showTest: input.onClickTest,
        showPractice: input.onClickPractice,
        showCalibration: input.onClickCalibration,
        showResult: input.onClickResult
    )
    
    init(input: TitleViewPresentable.Input) {
        self.input = input
        self.output = TitleViewModel.output(input: input)
    }
}

private extension TitleViewModel {
    // MARK: - Return output to view here, e.g. alert message
    static func output(input: TitleViewPresentable.Input) -> TitleViewPresentable.Output {
        return ()
    }
}
