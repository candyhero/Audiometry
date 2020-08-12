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
        validateCalibrationSetting: Driver<Bool>,
        validatePatientProfile: Driver<Bool>
    )
    
    typealias ViewModelBuilder = (TitleViewPresentable.Input) -> TitleViewPresentable
      
    var input: TitleViewPresentable.Input { get }
    var output: TitleViewPresentable.Output { get }
}

class TitleViewModel: TitleViewPresentable {
    var input: TitleViewPresentable.Input
    var output: TitleViewPresentable.Output
    
    private let _disposeBag = DisposeBag()
    
    typealias State = (
        validateCalibrationSetting: BehaviorRelay<Bool>,
        validatePatientProfile: BehaviorRelay<Bool>
    )
    private let _state: State = (
        validateCalibrationSetting: BehaviorRelay<Bool>(value: false),
        validatePatientProfile: BehaviorRelay<Bool>(value: false)
    )
    
    // MARK: - Routings used by coordinator
    typealias Routing = (
        showTest: Signal<Void>,
        showPractice: Signal<Void>,
        showCalibration: Signal<Void>,
        showResult: Signal<Void>
    )
    lazy var router: Routing = (
        showTest: input.onClickTest.filter(validateCalibrationSetting),
        showPractice: input.onClickPractice.filter(validateCalibrationSetting),
        showCalibration: input.onClickCalibration,
        showResult: input.onClickResult.filter(validatePatientProfile)
    )
    
    init(input: TitleViewPresentable.Input) {
        self.input = input
        self.output = TitleViewModel.output(input: input, state: _state)
    }
}

private extension TitleViewModel {
    // MARK: - Return output to view here, e.g. alert message
    static func output(input: TitleViewPresentable.Input,
                       state: State) -> TitleViewPresentable.Output {
        return (
            validateCalibrationSetting: state.validateCalibrationSetting.asDriver(),
            validatePatientProfile: state.validatePatientProfile.asDriver()
        )
    }
    
    private func validateCalibrationSetting() -> Bool {
        let globalSetting = try? GlobalSettingService.shared.fetch()
        if let calibrationSetting = globalSetting?.calibrationSetting,
            let name = calibrationSetting.name {
            print("Calibration name: \(name)")
            _state.validateCalibrationSetting.accept(true)
        } else {
            _state.validateCalibrationSetting.accept(false)
        }
        return _state.validateCalibrationSetting.value
    }
    
    private func validatePatientProfile() -> Bool {
        let profiles = (try? PatientProfileService.shared.fetchValidProfiles()) ?? []
        if profiles.isNotEmpty {
            print("Profile count: \(profiles.count)")
            _state.validatePatientProfile.accept(true)
        } else {
            _state.validatePatientProfile.accept(false)
        }
        return _state.validatePatientProfile.value
    }
}
