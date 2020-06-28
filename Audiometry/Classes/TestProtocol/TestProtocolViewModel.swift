//
//  TestProtocolViewModel.swift
//  Audiometry
//
//  Created by Xavier Chan on 28/6/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol TestProtocolViewPresentable {
    // MARK: - Inputs
    typealias Input = (
        onClickReturn: Signal<Void>,
        ()
    )
    
    // MARK: - Outputs
    typealias Output = ()
    
    typealias ViewModelBuilder = (TestProtocolViewPresentable.Input) -> TestProtocolViewPresentable
    
    var input: TestProtocolViewPresentable.Input { get }
    var output: TestProtocolViewPresentable.Output { get }
}

class TestProtocolViewModel: TestProtocolViewPresentable {
    var input: TestProtocolViewPresentable.Input
    var output: TestProtocolViewPresentable.Output
    
    private let _disposeBag = DisposeBag()
    
    typealias State = ()
    private let _state: State = ()
    
    typealias Routing = (
        showTitle: Signal<Void>,
        ()
    )
    lazy var router: Routing = (
        showTitle: input.onClickReturn,
        ()
    )
    
    init(input: TestProtocolViewPresentable.Input){
        self.input = input
        self.output = TestProtocolViewModel.output(input: self.input,
                                                  _state: self._state)
        
        self.process()
    }
}

private extension TestProtocolViewModel {
    // MARK: - Return output to view here, e.g. alert message
    static func output(input: TestProtocolViewPresentable.Input,
                       _state: State) -> TestProtocolViewPresentable.Output {
        
        print("Set output...")
        
        return ()
    }
    
    private func process() -> Void {
        // MARK: Bind
    }
}
