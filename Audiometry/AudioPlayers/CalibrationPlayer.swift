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

class CalibrationPlayer {
    
    private var _generator: AKOperationGenerator! = nil
    
    init(){
        // _generator to be configured by setting _generator.parameters
        _generator = AKOperationGenerator(channelCount: 2) {
            parameters in
            
            let leftOutput = AKOperation.sineWave(frequency: parameters[0],
                                                  amplitude: parameters[1])
            let rightOutput = AKOperation.sineWave(frequency: parameters[0],
                                                   amplitude: parameters[2])
            
            return [leftOutput, rightOutput]
        }
        
        AudioKit.output = _generator
        do {
            try AudioKit.start()
        } catch let error as NSError {
            print("Cant Start AudioKit", error)
        }
    }
    
    func isStarted() -> Bool{
        return _generator.isStarted
    }
    
    func startPlaying(){
        _generator.start()
    }
    
    func stopPlaying(){
        _generator.stop()
    }
    
    func updateFreq(_ freq: Int){
        _generator.parameters[0] = Double(freq)
    }
    
    // Update volume to currently playing frequency tone
    func updateVolume(_ ui: SettingUI){
        // skip if not playing currently
        if(!_generator.isStarted){
            return
        }
        
        // retrieve vol
        let expectedLv = Double(ui.tfExpectedLv.text!) ?? 0.0
        let presentationLv = Double(ui.tfPresentationLv.text!) ?? 0.0
        
        let leftMeasuredLv = Double(ui.tfMeasuredLv_L.text!) ?? expectedLv
        let rightMeasuredLv = Double(ui.tfMeasuredLv_R.text!) ?? expectedLv
        
        let leftCorrectionFactor = expectedLv - leftMeasuredLv
        let rightCorrectionFactor = expectedLv - rightMeasuredLv
        
        for i in stride(from: 0.0, through: 1.0, by: _RAMP_TIMESTEP){
            DispatchQueue.main.asyncAfter(
                deadline: .now() + i * _RAMP_TIME, execute:
                {
                    self._generator.parameters[1] = self.dbToAmp(
                        (presentationLv + leftCorrectionFactor) * i)
                    self._generator.parameters[2] = self.dbToAmp(
                        (presentationLv + rightCorrectionFactor) * i)
            })
        }
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

