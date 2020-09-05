//
//  CalibrationPlayer.swift
//  Audiometry
//
//  Created by Xavier Chan on 2/20/18.
//  Copyright © 2018 Xavier Chan. All rights reserved.
//

import UIKit
import AudioKit

class CalibrationPlayer {
    
    private var _generator: AKOperationGenerator! = nil
    
    init() {
        do {
            try AudioKit.stop()
        } catch {
            print(error)
        }

        // _generator to be configured by setting _generator.parameters
        _generator = AKOperationGenerator(channelCount: 2) { parameters in
            let leftOutput = AKOperation.sineWave(frequency: parameters[0], amplitude: parameters[1])
            let rightOutput = AKOperation.sineWave(frequency: parameters[0], amplitude: parameters[2])
            return [leftOutput, rightOutput]
        }
        
        AudioKit.output = _generator
        do {
            try AudioKit.start()
        } catch let error as NSError {
            print("Cant Start AudioKit", error)
        }
    }
}

extension CalibrationPlayer {
    func stop() {
        _generator.stop()
    }
    
    func play(with request: CalibrationSettingValuesRequest) {
        _generator.parameters[0] = Double(request.frequency)
        for i in stride(from: 0.0, through: 1.0, by: RAMP_TIMESTEP) {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + i * RAMP_TIME, execute: { [weak self] in
                    self?.adjustPresentationLevel(by: request, scale: i)
            })
        }
        _generator.start()
    }
    
    private func adjustPresentationLevel(by request: CalibrationSettingValuesRequest, scale: Double!) {
        _generator.parameters[1] = dbToAmp(request.leftFinalPresentationLevel * scale)
        _generator.parameters[2] = dbToAmp(request.rightFinalPresentationLevel * scale)
    }

    // Covert dB to amplitude in double (0.0 to 1.0 range)
    private func dbToAmp (_ dB: Double!) -> Double{
        // volume in absolute dB to be converted to amplitude
        // 1.0 amplitude <-> 0 absoulte dB
        let amplitude: Double = pow(10.0, (dB - SYSTEM_MAX_DB) / 20.0)
        return (amplitude > 1) ? 1 : amplitude
    }
    
}
