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

enum TestEarOrder: Int {
    case Finished = 0
    case LeftOnly = 1
    case RightOnly = 2
    case LeftRight = 3
    case RightLeft = 4
    
    func next() -> TestEarOrder{
        switch self {
            case .LeftRight: return .RightOnly
            case .RightLeft: return .LeftOnly
            default: return .Finished
        }
    }
}
protocol TestProtocolViewPresentable {
    // MARK: - Inputs
    typealias Input = (
        onClickReturn: Signal<Void>,
        onSelectFrequency: Signal<Int>,
        onClearLastFrequency: Signal<Void>,
        onClearAllFrequency: Signal<Void>,
        
        onSelectEarOrder: Signal<TestEarOrder>,
        onSaveNewProtocol: Signal<String>
    )
    
    // MARK: - Outputs
    typealias Output = (
        currentFrequencySelection: Driver<[Int]>,
        currentEarOrderSelection: Driver<TestEarOrder>
    )
    
    typealias ViewModelBuilder = (TestProtocolViewPresentable.Input) -> TestProtocolViewPresentable
    
    var input: TestProtocolViewPresentable.Input { get }
    var output: TestProtocolViewPresentable.Output { get }
}

class TestProtocolViewModel: TestProtocolViewPresentable {
    var input: TestProtocolViewPresentable.Input
    var output: TestProtocolViewPresentable.Output
    
    private let _disposeBag = DisposeBag()
    
    typealias State = (
        currentFrequencySelection: BehaviorRelay<[Int]>,
        currentEarOrderSelection: BehaviorRelay<TestEarOrder>,
        currentTestProtocol: BehaviorRelay<TestProtocol?>
    )
    
    private let _state: State = (
        currentFrequencySelection: BehaviorRelay<[Int]>(value: []),
        currentEarOrderSelection: BehaviorRelay<TestEarOrder>(value: .LeftOnly),
        currentTestProtocol: BehaviorRelay<TestProtocol?>(value: nil)
    )
    
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
        
        return (
            currentFrequencySelection: _state.currentFrequencySelection.asDriver(),
            currentEarOrderSelection: _state.currentEarOrderSelection.asDriver()
        )
    }
    
    private func process() -> Void {
        // MARK: Bind
        bindTestFrequencySelection()
        bindTestEarOrderSelection()
    }
    
    private func bindTestFrequencySelection(){
        input.onSelectFrequency
            .filter{[_state] frequency in !_state.currentFrequencySelection.value.contains(frequency)
            }.map{[_state] frequency -> [Int] in
                return _state.currentFrequencySelection.value + [frequency]
            }.emit(to: _state.currentFrequencySelection)
            .disposed(by: _disposeBag)
        
        input.onClearLastFrequency
            .filter{[_state] _ in _state.currentFrequencySelection.value.isNotEmpty }
            .map{[_state] frequency -> [Int] in
                let list = _state.currentFrequencySelection.value
                return Array(list.prefix(list.count-1))
            }.emit(to: _state.currentFrequencySelection)
            .disposed(by: _disposeBag)
        
        input.onClearAllFrequency
            .map{[]}
            .emit(to: _state.currentFrequencySelection)
            .disposed(by: _disposeBag)
    }
    
    private func bindTestEarOrderSelection(){
        input.onSelectEarOrder
            .emit(to: _state.currentEarOrderSelection)
            .disposed(by: _disposeBag)
    }
    
    private func bindSaveNewProtocol(){
        input.onSaveNewProtocol
            .map{[_state] name -> TestProtocol in
                return TestProtocolService.shared.createNewTestProtocol(
                    name: name,
                    frequencyOrder: _state.currentFrequencySelection.value,
                    earOrder: _state.currentEarOrderSelection.value
                )
            }.emit(to: _state.currentTestProtocol)
            .disposed(by: _disposeBag)
    }
}
