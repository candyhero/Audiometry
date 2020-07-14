//
//  TestViewModel.swift
//  Audiometry
//
//  Created by Xavier Chan on 13/7/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol TestViewPresentable {
    // MARK: - Inputs
    typealias Input = (
        onClickReturn: Signal<Void>,
        ()
    )
    
    // MARK: - Outputs
    typealias Output = (
    )
    
    typealias ViewModelBuilder = (TestViewPresentable.Input) -> TestViewModel
    
    var input: TestViewPresentable.Input { get }
    var output: TestViewPresentable.Output { get }
}

class TestViewModel: TestViewPresentable {
    var input: TestViewPresentable.Input
    var output: TestViewPresentable.Output
    
    private let _disposeBag = DisposeBag()
    
    typealias State = (
    )
    
    private let _state: State = (
    )
          
    typealias Routing = (
        showTitle: Signal<Void>,
        ()
    )
    lazy var router: Routing = (
        showTitle: input.onClickReturn,
        ()
    )
    
    init(input: TestViewModel.Input) {
        self.input = input
        self.output = TestViewModel.output(input: self.input, state: self._state)
        
        self.process()
    }
}

extension TestViewModel {
    // MARK: - Return output to view here, e.g. alert message
    static func output(input: TestViewPresentable.Input,
                       state: State) -> TestViewPresentable.Output {
        
        print("Set output...")
        
        return (
        )
    }
    
    private func process() -> Void {
    }
}

