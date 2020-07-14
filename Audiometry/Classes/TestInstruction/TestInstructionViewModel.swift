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
    // MARK: - Inp uts
    typealias Input = (
    )
    
    // MARK: - Outputs
    typealias Output = (
    )
    
    typealias ViewModelBuilder = (TestInstructionViewPresentable.Input) -> TestInstructionViewPresentable
    
    var input: TestInstructionViewPresentable.Input { get }
    var output: TestInstructionViewPresentable.Output { get }
}

class TestInstructionViewModel: TestInstructionViewPresentable {
    var input: TestInstructionViewModel.Input
    var output: TestInstructionViewModel.Output
    
    private let _disposeBag = DisposeBag()
    
    typealias State = (
    )
    
    private let _state: State = (
    )
         
    typealias Routing = (
    )
    lazy var router: Routing = (
    )
    
    init(input: TestInstructionViewModel.Input) {
        self.input = input
        self.output = TestInstructionViewModel.output(input: self.input,
                                                  _state: self._state)
        
        self.process()
    }
}

extension TestInstructionViewModel {
    // MARK: - Return output to view here, e.g. alert message
    static func output(input: TestInstructionViewPresentable.Input,
                       _state: State) -> TestInstructionViewPresentable.Output {
        
        print("Set output...")
        
        return (
        )
    }
    
    private func process() -> Void {
    }
}
