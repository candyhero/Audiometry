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

struct PatientProfileModel {
    var patientName: String
    var patientGroup: String
    var patientRole: PatientRole
}

protocol TestProtocolViewPresentable {
    // MARK: - Inputs
    typealias Input = (
        onClickReturn: Signal<Void>,
        onClickLoadOther: Signal<Void>,
        onClickDeleteCurrent: Signal<Void>,
        
        onClearLastFrequency: Signal<Void>,
        onClearAllFrequency: Signal<Void>,
        
        onSelectFrequency: Signal<Int>,
        onSelectEarOrder: Signal<TestEarOrder>,
        
        onSaveNewProtocol: Signal<String>,
        onLoadSelectedProtocol: Signal<String>,
        
        onValidateState: Signal<PatientRole>,
        onStartTest: Signal<PatientProfileModel>
    )
    
    // MARK: - Outputs
    typealias Output = (
        currentFrequencySelection: Driver<[Int]>,
        currentEarOrderSelection: Driver<TestEarOrder>,
        allTestProtocolNames: Driver<[String]>,
        
        validateState: Driver<Bool>
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
        currentTestProtocol: BehaviorRelay<TestProtocol?>,
        allTestProtocols: BehaviorRelay<[TestProtocol]>,
        
        testMode: BehaviorRelay<TestMode>,
        validateState: BehaviorRelay<Bool>
    )
    private let _state: State = (
        currentFrequencySelection: BehaviorRelay<[Int]>(value: []),
        currentEarOrderSelection: BehaviorRelay<TestEarOrder>(value: .LeftRight),
        currentTestProtocol: BehaviorRelay<TestProtocol?>(value: nil),
        allTestProtocols: BehaviorRelay<[TestProtocol]>(value: []),
        
        testMode: BehaviorRelay<TestMode>(value: .Invalid),
        validateState: BehaviorRelay<Bool>(value: false)
    )
         
    typealias Routing = (
        showTitle: Signal<Void>,
        startTest: Signal<PatientRole>
    )
    lazy var router: Routing = (
        showTitle: input.onClickReturn,
        startTest: input.onStartTest.map { $0.patientRole }
    )
    
    init(input: TestProtocolViewPresentable.Input) {
        self.input = input
        self.output = TestProtocolViewModel.output(input: self.input, state: self._state)
        
        self.process()
    }
    
    func setTestMode(testMode: TestMode){
        _state.testMode.accept(testMode)
    }
}

private extension TestProtocolViewModel {
    // MARK: - Return output to view here, e.g. alert message
    static func output(input: TestProtocolViewPresentable.Input,
                       state: State) -> TestProtocolViewPresentable.Output {
        print("Set output...")
        
        return (
            validateState: state.validateState.asDriver(),
            currentFrequencySelection: state.currentFrequencySelection.asDriver(),
            currentEarOrderSelection: state.currentEarOrderSelection.asDriver(),
            allTestProtocolNames: state.allTestProtocols
                .map { $0.map { ($0.name ?? "Error") } }
                .asDriver(onErrorJustReturn: [])
        )
    }
    
    private func process() -> Void {
        // MARK: Bind
        bindTestFrequencySelection()
        bindTestEarOrderSelection()
        bindSaveNewProtocol()
        bindLoadOtherProtocol()
        bindDeleteCurrentProtocol()
        bindStartTest()
    }
    
    private func bindTestFrequencySelection() {
        _state.currentTestProtocol.asDriver().skip(1)
            .map { $0?.testFrequencyOrder ?? [] }
            .drive(_state.currentFrequencySelection)
            .disposed(by: _disposeBag)
        
        input.onSelectFrequency
            .filter { [_state] frequency in !_state.currentFrequencySelection.value.contains(frequency)
            }.map { [_state] frequency -> [Int] in
                return _state.currentFrequencySelection.value + [frequency]
            }.emit(to: _state.currentFrequencySelection)
            .disposed(by: _disposeBag)
        
        input.onClearLastFrequency
            .filter { [_state] _ in _state.currentFrequencySelection.value.isNotEmpty }
            .map { [_state] frequency -> [Int] in
                let list = _state.currentFrequencySelection.value
                return Array(list.prefix(list.count-1))
            }.emit(to: _state.currentFrequencySelection)
            .disposed(by: _disposeBag)
        
        input.onClearAllFrequency
            .map { [] }
            .emit(to: _state.currentFrequencySelection)
            .disposed(by: _disposeBag)
    }
    
    private func bindTestEarOrderSelection() {
        _state.currentTestProtocol.asDriver().skip(1)
            .map { TestEarOrder(rawValue: Int($0?.testEarOrder ?? -1)) ?? .LeftRight }
            .drive(_state.currentEarOrderSelection)
            .disposed(by: _disposeBag)
        
        input.onSelectEarOrder
            .emit(to: _state.currentEarOrderSelection)
            .disposed(by: _disposeBag)
    }
    
    private func bindSaveNewProtocol() {
        input.onSaveNewProtocol
            .map { [_state] name -> TestProtocol in
                return TestProtocolService.shared.createNewTestProtocol(
                    name: name,
                    frequencyOrder: _state.currentFrequencySelection.value,
                    earOrder: _state.currentEarOrderSelection.value
                )
            }.emit(to: _state.currentTestProtocol)
            .disposed(by: _disposeBag)
    }
    
    private func bindLoadOtherProtocol() {
        input.onClickLoadOther
            .map { _ in (try? TestProtocolService.shared.fetchAllSortedByTime()) ?? [] }
            .emit(to: _state.allTestProtocols)
            .disposed(by: _disposeBag)
        
        input.onLoadSelectedProtocol
            .map { [_state] protocolName in
                _state.allTestProtocols.value
                    .filter({ $0.name == protocolName })
                    .first
            }.emit(to: _state.currentTestProtocol)
            .disposed(by: _disposeBag)
    }
    
    private func bindDeleteCurrentProtocol() {
        input.onClickDeleteCurrent
            .map { [_state] _ -> TestProtocol? in
                if let setting = _state.currentTestProtocol.value{
                    try! TestProtocolService.shared.delete(setting)
                }
                return nil
            }.emit(to: _state.currentTestProtocol)
            .disposed(by: _disposeBag)
    }
    
    private func bindStartTest() {
        input.onValidateState
            .map{ _ in validateState() }
            .emit(to: _state.validateState)
            .disposed(by: _disposeBag)
        
        func validateState() -> Bool {
            // TO-DO: Split into two validations
            // non empty & practice mode
            let frequencySelection = _state.currentFrequencySelection.value
            let testMode = _state.testMode.value
            return (frequencySelection.isNotEmpty && testMode == TestMode.Test)
                || (frequencySelection.count == 1 && testMode == TestMode.Practice)
        }
        
        input.onStartTest
            .emit(onNext: {[_state] (model) in
                print(model)
//                let profile = PatientProfileService.shared.createNewPatientProfile(
//                    model: model,
//                    testMode: _state.testMode.value,
//                    testEarOrder: _state.currentEarOrderSelection.value,
//                    testFrequencyOrder: _state.currentFrequencySelection.value
//                )
//
//                GlobalSettingService.shared.updatePatientProfile(patientProfile: profile)
            })
            .disposed(by: _disposeBag)
    }
}
