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
        onLoadSelectedSetting: Signal<String>
    )
    
    // MARK: - Outputs
    typealias Output = (
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
        currentCalibrationSetting: BehaviorRelay<CalibrationSetting?>,
        allCalibrationSettings: BehaviorRelay<[CalibrationSetting]>
    )
    let state: State = (
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
            currentCalibrationSetting: state.currentCalibrationSetting.asDriver(),
            allCalibrationSettingNames:
                state.allCalibrationSettings
                    .map{ $0.map{($0.name ?? "Error")}}
                    .asDriver(onErrorJustReturn: [])
        )
    }
    
    func process() -> Void {
        clearAllSettings()
        // MARK: Bind
        bindSaveNewSetting()
        bindSaveCurrentSetting()
        bindLoadOther()
        bind()
    }
    
    private func clearAllSettings(){
        if let allSettings = try? CalibrationService.shared.fetchAllSortedByTime(){
            print("Setting Count (Init): ", allSettings.count)
            
            for setting in allSettings{
                try! CalibrationService.shared.delete(setting)
            }
        }
        if let allSettings = try? CalibrationService.shared.fetchAllSortedByTime(){
            print("Setting Count (AfterInit): ", allSettings.count)
        }
    }
    
    private func bindSaveNewSetting(){
        _ = input.onSaveNewSetting.emit(onNext: {[weak self] (settingName, settingUI) in
//            print("ViewModel:", settingName, settingUI.count)
            let service = CalibrationService.shared
            
            let settingValues = settingUI.map {
                $0.extractValuesInto(values: service.createNewSettingValues(frequency: $0.frequency))
            }
            
            let setting = service.createNewSetting(name: settingName, values: settingValues)
            self?.state.currentCalibrationSetting.accept(setting)
        }).disposed(by: disposeBag)
    }
    
    private func bindSaveCurrentSetting(){
        _ = input.onSaveCurrentSetting.emit(onNext: {[weak self] settingUIs in
        
            if let setting = self?.state.currentCalibrationSetting.value
            {
                let lookup = setting.values?.reduce(
                    into: [Int: CalibrationSettingValues]()
                ){ (dict, v) in
                    if let values = v as? CalibrationSettingValues{
                        dict[Int(values.frequency)] = values
                    }
                }
                print(lookup![2000] as Any)
                
                _ = settingUIs.map {
                    $0.extractValuesInto(values: (lookup?[$0.frequency])!)
                }
                print(lookup![2000] as Any)
            }
        }).disposed(by: disposeBag)
    }
    
    private func bindLoadOther(){
        _ = input.onClickLoadOther.emit(onNext: {[weak self] _ in
            if let allSettings = try? CalibrationService.shared.fetchAllSortedByTime(){
                print("Load all:", self?.state.allCalibrationSettings.value.count, allSettings.count)
                self?.state.allCalibrationSettings.accept(allSettings)
            } else {
                print("Error when load all others")
            }
        }).disposed(by: disposeBag)
        
        _ = input.onLoadSelectedSetting.emit(onNext: { [weak self] selectedSettingName in
            if let allSettings = self?.state.allCalibrationSettings.value,
               let selectedSetting = allSettings.filter({ $0.name == selectedSettingName }).first {
                self?.state.currentCalibrationSetting.accept(selectedSetting)
            }
        }).disposed(by: disposeBag)
    }
    
    private func bind(){
        _ = input.onClickDeleteCurrent.emit(onNext: {[weak self] _ in
            if let setting = self?.state.currentCalibrationSetting.value{
                self?.state.currentCalibrationSetting.accept(nil)
                try! CalibrationService.shared.delete(setting)
            }
        }).disposed(by: disposeBag)
        
        _ = state.currentCalibrationSetting.bind{(calibrationSetting) in
            if let setting = calibrationSetting {
                print("State: \(String(describing: setting.name))")
            } else {
                print("State: nil")
            }
        }.disposed(by: disposeBag)
    }
}
