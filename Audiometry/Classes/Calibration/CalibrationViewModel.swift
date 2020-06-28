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
        
        onSaveNewSetting: Signal<(String, [CalibrationSettingValueUi])>,
        onSaveCurrentSetting: Signal<[CalibrationSettingValueUi]>,
        onLoadSelectedSetting: Signal<String>,

        onTogglePlayCalibration: Signal<(Bool, CalibrationSettingValueUi)>
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
    
    init(input: CalibrationViewPresentable.Input){
        self.input = input
        self.output = CalibrationViewModel.output(input: self.input,
                                                  _state: self._state)
        
        self.process()
    }
}

private extension CalibrationViewModel {
    // MARK: - Return output to view here, e.g. alert message
    static func output(input: CalibrationViewPresentable.Input,
                       _state: State) -> CalibrationViewPresentable.Output {
        
        print("Set output...")
        
        return (
            currentPlayerFrequency: _state.currentPlayerFrequency.asDriver(),
            currentCalibrationSetting: _state.currentCalibrationSetting.asDriver(),
            allCalibrationSettingNames: _state.allCalibrationSettings
                .map{ $0.map{($0.name ?? "Error")}}
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
        bindLoadOther()
        bindDeleteCurrentSetting()
    }
    
    private func fetchCalibrationSettingFromGlobalSetting(){
        if let globalSetting = try? GlobalSettingService.shared.fetch(){
            _state.currentCalibrationSetting.accept(globalSetting.calibrationSetting)
            print("Loaded from global setting: \(globalSetting.calibrationSetting?.name ?? "")")
        }
    }
    
    private func bindTogglePlayCalibration(){
        input.onClickReturn
            .emit(onNext: {[_calibrationPlayer] in
                _calibrationPlayer.stop()
            })
            .disposed(by: _disposeBag)
        
        input.onTogglePlayCalibration
            .map{[_state, _calibrationPlayer] (isToggle, ui) in
                if isToggle && ui.frequency == _state.currentPlayerFrequency.value{
                    _calibrationPlayer.stop()
                    return (isToggle, -1)
                }
                _calibrationPlayer.play(ui: ui)
                return (isToggle, ui.frequency)
            }.filter{(isToggle, frequency) in return isToggle }
            .map{(isToggle, frequency) in return frequency }
            .emit(to: _state.currentPlayerFrequency)
            .disposed(by: _disposeBag)
    }
    
    private func bindSaveGlobalSetting(){
        _state.currentCalibrationSetting.asDriver()
            .drive(onNext: GlobalSettingService.shared.updateCalibrationSetting)
            .disposed(by: _disposeBag)
    }
    
    private func bindSaveNewSetting(){
        input.onSaveNewSetting
            .map{ (settingName, settingUiList) in
                let service = CalibrationSettingService.shared
                let settingValuesList = settingUiList.map {
                    $0.extractValuesInto(
                        values: service.createNewSettingValues(frequency: $0.frequency)
                    )
                }
                return service.createNewSetting(
                    name: settingName,
                    values: settingValuesList
                )
            }
            .emit(to: _state.currentCalibrationSetting)
            .disposed(by: _disposeBag)
    }
    
    private func bindSaveCurrentSetting(){
        input.onSaveCurrentSetting
            .map{[_state] settingUis -> CalibrationSetting? in
                if let setting = _state.currentCalibrationSetting.value{
                    let lookup = setting.values?.reduce(
                        into: [Int: CalibrationSettingValues]()
                    ){ (dict, v) in
                        if let values = v as? CalibrationSettingValues{
                            dict[Int(values.frequency)] = values
                        }
                    }
                    _ = settingUis.map {
                        $0.extractValuesInto(values: (lookup?[$0.frequency])!)
                    }
                }
                return _state.currentCalibrationSetting.value
            }.emit(to: _state.currentCalibrationSetting)
            .disposed(by: _disposeBag)
    }
    
    private func bindLoadOther(){
        input.onClickLoadOther
            .map{ _ in (try? CalibrationSettingService.shared.fetchAllSortedByTime()) ?? []}
            .emit(to: _state.allCalibrationSettings)
            .disposed(by: _disposeBag)
        
        input.onLoadSelectedSetting
            .map{[_state] settingName in
                _state.allCalibrationSettings.value
                    .filter({ $0.name == settingName})
                    .first
            }.emit(to: _state.currentCalibrationSetting)
            .disposed(by: _disposeBag)
    }
    
    private func bindDeleteCurrentSetting(){
        input.onClickDeleteCurrent
            .map{[_state] _ -> CalibrationSetting? in
                if let setting = _state.currentCalibrationSetting.value{
                    try! CalibrationSettingService.shared.delete(setting)
                }
                return nil
            }.emit(to: _state.currentCalibrationSetting)
            .disposed(by: _disposeBag)
    }
}
