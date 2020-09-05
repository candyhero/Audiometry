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
        onClickLoadOther: Signal<Void>,
        onClickDeleteCurrent: Signal<Void>,
        
        onSaveNewSetting: Signal<(String, [CalibrationSettingValuesRequest])>,
        onSaveCurrentSetting: Signal<[CalibrationSettingValuesRequest]>,
        onLoadSelectedSetting: Signal<String>,

        onTogglePlayCalibration: Signal<CalibrationSettingValuesRequest?>,
        onUpdatePlayCalibration: Signal<CalibrationSettingValuesRequest?>
    )
    
    // MARK: - Outputs
    typealias Output = (
        currentPlayerFrequency: Driver<Int>,
        currentCalibrationSetting: Driver<CalibrationSetting?>,
        allCalibrationSettingNames: Driver<[String]>
    )
    
    typealias ViewModelBuilder = (CalibrationViewPresentable.Input) -> CalibrationViewPresentable
    
    var input: CalibrationViewPresentable.Input { get }
    var output: CalibrationViewPresentable.Output { get }
}

class CalibrationViewModel: CalibrationViewPresentable {
    var input: CalibrationViewPresentable.Input
    var output: CalibrationViewPresentable.Output
    
    private let _calibrationPlayer = CalibrationPlayer()
    private let _disposeBag = DisposeBag()
    
    typealias State = (
        currentPlayerFrequency: BehaviorRelay<Int>,
        currentCalibrationSetting: BehaviorRelay<CalibrationSetting?>,
        allCalibrationSettings: BehaviorRelay<[CalibrationSetting]>
    )
    private let _state: State = (
        currentPlayerFrequency: BehaviorRelay<Int>(value: -1),
        currentCalibrationSetting: BehaviorRelay<CalibrationSetting?>(value: nil),
        allCalibrationSettings: BehaviorRelay<[CalibrationSetting]>(value: [])
    )
    
    typealias Routing = (
        showTitle: Signal<Void>,
        ()
    )
    lazy var router: Routing = (
        showTitle: input.onClickReturn,
        ()
    )
    
    init(input: CalibrationViewPresentable.Input) {
        self.input = input
        self.output = CalibrationViewModel.output(input: input, state: _state)
        
        self.process()
    }
}

private extension CalibrationViewModel {
    // MARK: - Return output to view here, e.g. alert message
    static func output(input: CalibrationViewPresentable.Input,
                       state: State) -> CalibrationViewPresentable.Output {
        return (
            currentPlayerFrequency: state.currentPlayerFrequency.asDriver(),
            currentCalibrationSetting: state.currentCalibrationSetting.asDriver(),
            allCalibrationSettingNames: state.allCalibrationSettings
                .map { $0.map { ($0.name ?? "Error") } }
                .asDriver(onErrorJustReturn: [])
        )
    }
    
    private func process() -> Void {
        // MARK: Bind
        fetchCalibrationSettingFromGlobalSetting()
        bindTogglePlayCalibration()
        bindSaveGlobalSetting()
        bindSaveNewSetting()
        bindSaveCurrentSetting()
        bindLoadOtherSetting()
        bindDeleteCurrentSetting()
    }
    
    private func fetchCalibrationSettingFromGlobalSetting() {
        if let globalSetting = try? GlobalSettingService.shared.fetch() {
            _state.currentCalibrationSetting.accept(globalSetting.calibrationSetting)
            print("Loaded from global setting: \(globalSetting.calibrationSetting?.name ?? "")")
        }
    }
    
    private func bindTogglePlayCalibration() {
        input.onClickReturn
            .emit(onNext: { [_calibrationPlayer] in
                _calibrationPlayer.stop()
            })
            .disposed(by: _disposeBag)
        
        input.onTogglePlayCalibration
            .map { [_state, _calibrationPlayer] request -> Int in
                if let r = request, r.frequency != _state.currentPlayerFrequency.value {
                    _calibrationPlayer.play(with: r)
                    return r.frequency
                } else {
                    _calibrationPlayer.stop()
                    return -1
                }
            }
            .emit(to: _state.currentPlayerFrequency)
            .disposed(by: _disposeBag)
        
        input.onUpdatePlayCalibration
            .map { [_state, _calibrationPlayer] request -> Int in
                if let r = request, r.frequency == _state.currentPlayerFrequency.value {
                    _calibrationPlayer.play(with: r)
                    return r.frequency
                } else {
                   _calibrationPlayer.stop()
                   return -1
               }
            }
            .emit(to: _state.currentPlayerFrequency)
            .disposed(by: _disposeBag)
    }
    
    private func bindSaveGlobalSetting() {
        _state.currentCalibrationSetting.asDriver()
            .drive(onNext: GlobalSettingService.shared.updateCalibrationSetting)
            .disposed(by: _disposeBag)
    }
    
    private func bindSaveNewSetting() {
        input.onSaveNewSetting
            .map { (settingName, requests) in
                let service = CalibrationSettingService.shared
                return service.createNewSetting(name: settingName, from: requests)
            }
            .emit(to: _state.currentCalibrationSetting)
            .disposed(by: _disposeBag)
    }
    
    private func bindSaveCurrentSetting() {
        input.onSaveCurrentSetting
            .map { [_state] requests -> CalibrationSetting? in
                if let setting = _state.currentCalibrationSetting.value {
                    let service = CalibrationSettingService.shared
                    return service.updateSettingValues(setting: setting, from: requests)
                }
                return _state.currentCalibrationSetting.value
            }.emit(to: _state.currentCalibrationSetting)
            .disposed(by: _disposeBag)
    }
    
    private func bindLoadOtherSetting() {
        input.onClickLoadOther
            .map { _ in (try? CalibrationSettingService.shared.fetchAllSortedByTime()) ?? [] }
            .emit(to: _state.allCalibrationSettings)
            .disposed(by: _disposeBag)
        
        input.onLoadSelectedSetting
            .map { [_state] settingName in
                _state.allCalibrationSettings.value
                    .first{ $0.name == settingName}
            }.emit(to: _state.currentCalibrationSetting)
            .disposed(by: _disposeBag)
    }
    
    private func bindDeleteCurrentSetting() {
        input.onClickDeleteCurrent
            .map { [_state] _ -> CalibrationSetting? in
                if let setting = _state.currentCalibrationSetting.value{
                    try! CalibrationSettingService.shared.delete(setting)
                }
                return nil
            }.emit(to: _state.currentCalibrationSetting)
            .disposed(by: _disposeBag)
    }
}
