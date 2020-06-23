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
        
        onSaveNewSetting: Signal<(String, [CalibrationSettingValueUI])>,
        onSaveCurrentSetting: Signal<[CalibrationSettingValueUI]>,
        onLoadSelectedSetting: Signal<String>,

        onTogglePlayCalibration: Signal<Int>
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
    
    typealias State = (
        currentPlayerFrequency: BehaviorRelay<Int>,
        currentCalibrationSetting: BehaviorRelay<CalibrationSetting?>,
        allCalibrationSettings: BehaviorRelay<[CalibrationSetting]>
    )
    let state: State = (
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
    
    private let disposeBag = DisposeBag()
    
    init(input: CalibrationViewPresentable.Input){
        self.input = input
        self.output = CalibrationViewModel.output(input: self.input,
                                                  state: self.state)
        
        self.process()
    }
}

private extension CalibrationViewModel {
    // MARK: - Return output to view here, e.g. alert message
    static func output(input: CalibrationViewPresentable.Input,
                       state: State) -> CalibrationViewPresentable.Output {
        
        print("Set output...")
        
        return (
            currentPlayerFrequency: state.currentPlayerFrequency.asDriver(),
            currentCalibrationSetting: state.currentCalibrationSetting.asDriver(),
            allCalibrationSettingNames: state.allCalibrationSettings
                .map{ $0.map{($0.name ?? "Error")}}
                .asDriver(onErrorJustReturn: [])
        )
    }
    
    func process() -> Void {
        // MARK: Bind
        bindDebug()
        
        bindTogglePlayCalibration()
        
        bindSaveNewSetting()
        bindSaveCurrentSetting()
        bindLoadOther()
        bindDeleteCurrentSetting()
    }
    
    private func bindDebug(){
        if let allSettings = try? CalibrationService.shared.fetchAllSortedByTime(){
            print("Setting Count (Init): ", allSettings.count)
            
            for setting in allSettings{
                try! CalibrationService.shared.delete(setting)
            }
        }
        if let allSettings = try? CalibrationService.shared.fetchAllSortedByTime(){
            print("Setting Count (AfterInit): ", allSettings.count)
        }
        
        func debugCurrentSetting(calibrationSetting: CalibrationSetting?){
            if let setting = calibrationSetting {
                print("State: \(String(describing: setting.name))")
            } else {
                print("State: nil")
            }
        }
        _ = state.currentCalibrationSetting
            .bind(onNext: debugCurrentSetting)
            .disposed(by: disposeBag)
    }
    
    private func bindTogglePlayCalibration(){
        _ = input.onTogglePlayCalibration
            .map{ [weak self] frequency in
                return frequency != self?.state.currentPlayerFrequency.value ? frequency : -1
            }.emit(to: state.currentPlayerFrequency)
            .disposed(by: disposeBag)
        
        _ = state.currentPlayerFrequency.asDriver()
            .drive(onNext: { _ in // toggle player
                return
            }).disposed(by: disposeBag)
    }
    
    private func bindSaveNewSetting(){
        _ = input.onSaveNewSetting
            .map{ (settingName, settingUIs) in
                let service = CalibrationService.shared
                let settingValues = settingUIs.map {
                    $0.extractValuesInto(
                        values: service.createNewSettingValues(frequency: $0.frequency)
                    )
                }
                return service.createNewSetting(
                    name: settingName,
                    values: settingValues
                )
            }
            .emit(to: state.currentCalibrationSetting)
            .disposed(by: disposeBag)
    }
    
    private func bindSaveCurrentSetting(){
        func saveCurrentSetting(settingUis: [CalibrationSettingValueUI]){
            if let setting = state.currentCalibrationSetting.value{
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
        }
        _ = input.onSaveCurrentSetting
            .emit(onNext: saveCurrentSetting)
            .disposed(by: disposeBag)
    }
    
    private func bindLoadOther(){
        _ = input.onClickLoadOther
            .map{ (try? CalibrationService.shared.fetchAllSortedByTime()) ?? []}
            .emit(to: state.allCalibrationSettings)
            .disposed(by: disposeBag)
        
        _ = input.onLoadSelectedSetting
            .map{ getSettingByName(settingName: $0) }
            .emit(to: state.currentCalibrationSetting)
            .disposed(by: disposeBag)
        
        func getSettingByName(settingName: String) -> CalibrationSetting? {
            return state.allCalibrationSettings.value.filter({ $0.name == settingName}).first
        }
    }
    
    private func bindDeleteCurrentSetting(){
        _ = input.onClickDeleteCurrent
            .map{[weak self] _ -> CalibrationSetting? in
                if let setting = self?.state.currentCalibrationSetting.value{
                    try! CalibrationService.shared.delete(setting)
                }
                return nil
            }.emit(to: state.currentCalibrationSetting)
            .disposed(by: disposeBag)
    }
}
