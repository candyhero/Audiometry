//
//  CalibrationModel.swift
//  Audiometry
//
//  Created by Xavier Chan on 2/20/18.
//  Copyright © 2018 Xavier Chan. All rights reserved.
//

import Foundation
import UIKit
import AudioKit
import RealmSwift

class CalibrationModel {
    
    private let realm = try! Realm()
    private var mainSetting: MainSetting? = nil
    
    private var _generator: AKOperationGenerator! = nil
    private var _currentPlayIndex: Int = -1
    
    init(){
        mainSetting = realm.objects(MainSetting.self).first
        setupAudioPlayer()
    }
    
    func getMainSetting() -> MainSetting{
        
        return mainSetting!
    }
    
    func isSettingExisted(_ settingName: String) -> Bool{
        let count: Int = (mainSetting?.array_calibrationSettings.filter("name = %@", settingName).count)!
        return count > 0
    }
    
    func updateSetting(_ newSettingName: String){
        
        let newSetting = CalibrationSetting()
        newSetting.name = newSettingName
        
        for i in 0..<ARRAY_DEFAULT_FREQ.count {
            newSetting.array_freq.append(ARRAY_DEFAULT_FREQ[i])
            
            newSetting.array_presentDBHL.append(
                Double(CalibrationViewController.array_tbPresentDBHL[i].text!) ?? 0)
            newSetting.array_expectedDBSPL.append(
                Double(CalibrationViewController.array_tbExpectedDBSPL[i].text!) ?? 0)
            
            newSetting.array_measuredDBSPL_L.append(
                Double(CalibrationViewController.array_tbMeasuredDBSPL_L[i].text!) ?? 0)
            newSetting.array_measuredDBSPL_R.append(
                Double(CalibrationViewController.array_tbMeasuredDBSPL_R[i].text!) ?? 0)
        }
        
        try! realm.write {
            if(newSettingName == CalibrationViewController.currentSettingName){
                realm.add(newSetting, update: true)
            }
            else {
                
                mainSetting?.calibrationSettingIndex =
                    (self.mainSetting?.array_calibrationSettings.count)!
                mainSetting?.array_calibrationSettings.append(newSetting)
                CalibrationViewController.currentSettingName = newSettingName
            }
        }
    }
    
    func deleteCurrentSetting(){
        
        let currentSetting = mainSetting?.array_calibrationSettings[
            (mainSetting?.calibrationSettingIndex)!]
        
        try! realm.write {
            mainSetting?.array_calibrationSettings.remove(
                at: (mainSetting?.calibrationSettingIndex)!)
            
            mainSetting?.calibrationSettingIndex = -1
            realm.delete(currentSetting!)
        }
        
        CalibrationViewController.currentSettingName = ""
    }
    
    func loadSetting(_ settingIndex: Int!){
        let newSetting = mainSetting?.array_calibrationSettings[settingIndex]
        CalibrationViewController.currentSettingName = (newSetting?.name)!
        
        for i in 0..<(newSetting?.array_freq.count)! {
            
            CalibrationViewController.array_tbExpectedDBSPL[i].text =
                String(describing: (newSetting?.array_expectedDBSPL[i])!)
            CalibrationViewController.array_tbPresentDBHL[i].text =
                String(describing: (newSetting?.array_presentDBHL[i])!)
            
            CalibrationViewController.array_tbMeasuredDBSPL_L[i].text =
                String(describing: (newSetting?.array_measuredDBSPL_L[i])!)
            CalibrationViewController.array_tbMeasuredDBSPL_R[i].text =
                String(describing: (newSetting?.array_measuredDBSPL_R[i])!)
        }
        
        try! realm.write {
            mainSetting?.calibrationSettingIndex = settingIndex
        }
    }
    
    func playSingal(_ newPlayIndex: Int){
        // No tone playing at all, simply toggle on
        if(!_generator.isStarted){
            
            _currentPlayIndex = newPlayIndex
            CalibrationViewController.array_pbPlay[_currentPlayIndex].setTitle("On", for: .normal)
            
            _generator.start()
            
            // Update freq & vol
            _generator.parameters[0] = Double(ARRAY_DEFAULT_FREQ[_currentPlayIndex])
            updatePlayerVolume()
        }
            // Same tone, toggle it off
        else if(_currentPlayIndex == newPlayIndex){
            CalibrationViewController.array_pbPlay[_currentPlayIndex].setTitle("Off", for: .normal)
            _currentPlayIndex = -1
            
            _generator.stop()
        }
            // Else tone, switch frequency
        else {
            CalibrationViewController.array_pbPlay[_currentPlayIndex].setTitle("Off", for: .normal)
            CalibrationViewController.array_pbPlay[newPlayIndex].setTitle("On", for: .normal)
            
            _currentPlayIndex = newPlayIndex
            
            // Update freq & vol
            _generator.parameters[0] = Double(ARRAY_DEFAULT_FREQ[_currentPlayIndex])
            updatePlayerVolume()
        }
    }
    
    // Update volume to currently playing frequency tone
    func updatePlayerVolume()
    {
        // skip if not playing currently
        if(!_generator.isStarted || (_currentPlayIndex == -1)){
            return
        }
        
        // retrieve vol
        let expectedTxt: String = CalibrationViewController.array_tbExpectedDBSPL[_currentPlayIndex].text!
        let presentTxt: String = CalibrationViewController.array_tbPresentDBHL[_currentPlayIndex].text!
        
        let leftMeasuredTxt: String =
            CalibrationViewController.array_tbMeasuredDBSPL_L[_currentPlayIndex].text!
        let rightMeasuredTxt: String =
            CalibrationViewController.array_tbMeasuredDBSPL_R[_currentPlayIndex].text!
        
        let expectedDBSPL: Double! = Double(expectedTxt) ?? 0.0
        let presentDBHL: Double! = Double(presentTxt) ?? 0.0
        
        let leftMeasuredDBSPL: Double! =
            Double(leftMeasuredTxt) ?? expectedDBSPL
        let rightMeasuredDBSPL: Double! =
            Double(rightMeasuredTxt) ?? expectedDBSPL
        
        let leftCorrectionFactor: Double! = expectedDBSPL - leftMeasuredDBSPL
        let rightCorrectionFactor: Double! = expectedDBSPL - rightMeasuredDBSPL
        
        for i in stride(from: 0.0, through: 1.0, by: _RAMP_TIMESTEP){
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + i * _RAMP_TIME, execute:
                {
                    self._generator.parameters[1] = self.dbToAmp(
                        (presentDBHL! + leftCorrectionFactor!) * i)
                    self._generator.parameters[2] = self.dbToAmp(
                        (presentDBHL! + rightCorrectionFactor!) * i)
            })
        }
    }
    
    func setupAudioPlayer(){
        
        // _generator to be configured by setting _generator.parameters
        _generator = AKOperationGenerator(numberOfChannels: 2) {
            
            parameters in
            
            let leftOutput = AKOperation.sineWave(frequency: parameters[0],
                                                  amplitude: parameters[1])
            let rightOutput = AKOperation.sineWave(frequency: parameters[0],
                                                   amplitude: parameters[2])
            
            return [leftOutput, rightOutput]
        }
        
        AudioKit.output = _generator
        AudioKit.start()
    }
    
    // Covert dB to amplitude in double (0.0 to 1.0 range)
    func dbToAmp (_ dB: Double!) -> Double{
        
        // volume in absolute dB to be converted to amplitude
        // 1.0 amplitude <-> 0 absoulte dB
        let ampDB: Double = dB - _DB_SYSTEM_MAX
        
        let amp: Double = pow(10.0, ampDB / 20.0)
        
        //        print(amp)
        return ((amp > 1) ? 1 : amp)
    }

}

