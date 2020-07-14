//
//  TestInstructionViewModel.swift
//  Audiometry
//
//  Created by Xavier Chan on 14/7/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol TestInstructionViewPresentable {
    // MARK: - Inputs
    typealias Input = (
        onClickReturn: Signal<Void>,
        ()
    )
    
    // MARK: - Outputs
    typealias Output = (
    )
    
    typealias ViewModelBuilder = (TestInstructionViewPresentable.Input) -> TestInstructionViewPresentable
    
    var input: TestInstructionViewPresentable.Input { get }
    var output: TestInstructionViewPresentable.Output { get }
}

class TestInstructionViewModel: TestInstructionViewPresentable {
    var input: TestInstructionViewPresentable.Input
    var output: TestInstructionViewPresentable.Output
    
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
    
    init(input: TestInstructionViewModel.Input) {
        self.input = input
        self.output = TestInstructionViewModel.output(input: self.input, state: self._state)
        
        self.process()
    }
}

extension TestInstructionViewModel {
    // MARK: - Return output to view here, e.g. alert message
    static func output(input: TestInstructionViewPresentable.Input,
                       state: State) -> TestInstructionViewPresentable.Output {
        
        print("Set output...")
        
        return (
        )
    }
    
    private func process() -> Void {
    }
}
