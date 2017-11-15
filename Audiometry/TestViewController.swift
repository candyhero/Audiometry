//
//  TestViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 7/27/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import UIKit

// Global Static Constants shared by player and test flow
let PLAY_GAP_TIME: Double! = 0.3

let ATTACK_TIME: Double! = 0.06
let HOLD_TIME: Double! = 0.2
let RELEASE_TIME: Double! = 0.06

let PULSE_TIME: Double! = 0.38
let NUM_OF_PULSE: Double! = 3
let ANIMATE_SCALE: CGFloat! = 0.85

class TestViewController: UIViewController {
    
    
    private var _currentTestFlow = TestFlow()
    
    private var array_freqSeq: [Int]!
    
    private var timer: Timer?
    
    // a map to record trials and results
    //
    @IBOutlet private weak var lbIsPlaying: UILabel!
    @IBOutlet private weak var lbPhaseState: UILabel!
    @IBOutlet private weak var lbCurrentSetting: UILabel!
    @IBOutlet private weak var lbDebug: UILabel!
    
    @IBOutlet private weak var ivFirstInterval: UIImageView!
    @IBOutlet private weak var ivSecondInterval: UIImageView!
    
    @IBOutlet private weak var svIcons: UIStackView!
    
    @IBOutlet private weak var pbFirstInterval: UIButton!
    @IBOutlet private weak var pbSecondInterval: UIButton!
    @IBOutlet private weak var pbNoSound: UIButton!
    
    @IBAction private func checkResponse(_ sender: UIButton) {
        
        // DispatchQueue default **
        // Compare test blah
        let currentPlaycase: Int! = _currentTestFlow.currentPlayCase()
        
        var bool_sender: Bool! = true
        
        // determine next volume level
        switch currentPlaycase {
        case 0: // Slient interval
            
            bool_sender = (sender == pbNoSound)
            break
        case 1: // First interval
            
            bool_sender = (sender == pbFirstInterval)
            break
        case 2: // Second interval
            
            bool_sender = (sender == pbSecondInterval)
            break
        default:
            break
        }
        
        print(bool_sender)
        
        let flag_thresholdFound =
            _currentTestFlow.checkThreshold(bool_sender)
        
        if(flag_thresholdFound!){
            print(array_freqSeq)
            // Pop the next freqSeq
            if(array_freqSeq.count > 0) {
                testNextFrequency()
            }
            else {
                _currentTestFlow.saveResult()
                performSegue(withIdentifier: "segueResult", sender: nil)
            }
        }
        else { // Still testing this frequency
            DispatchQueue.main.async { [unowned self] in
                // UI
                self.pulseAnimation()
            }
        }
    }
    
    private func pulseAnimation() {
        self.lbDebug.text = String(self._currentTestFlow.currentDB())
        self.lbIsPlaying.text = String("Playing")
        
        self.toggleButtons(toggle: false)
        
        let delayTime = PULSE_TIME * NUM_OF_PULSE * 2 + PLAY_GAP_TIME
        
        // Play Animation
        for pulse in stride(from: 0, to: NUM_OF_PULSE, by: 1) {
            let delayTime = PULSE_TIME * pulse
            self.timer = Timer.scheduledTimer(timeInterval: delayTime,
                                              target: self,
                                              selector: #selector(self.pulseFirst),
                                              userInfo: nil,
                                              repeats: false)
        }
        
        
        for pulse in stride(from: 0, to: NUM_OF_PULSE, by: 1) {
            let delayTime = PULSE_TIME * (pulse + NUM_OF_PULSE) + PLAY_GAP_TIME
            self.timer = Timer.scheduledTimer(timeInterval: delayTime,
                                              target: self,
                                              selector: #selector(self.pulseSecond),
                                              userInfo: nil,
                                              repeats: false)
        }
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + delayTime,
            execute:{self.toggleButtons(toggle: true)}
        )
    }
    
    @objc private func pulseFirst() {
        UIView.animate(withDuration: PULSE_TIME / 2,
                       animations: {
                        self.ivFirstInterval.transform = CGAffineTransform(
                            scaleX: ANIMATE_SCALE, y: ANIMATE_SCALE)
        },
                       completion: { _ in
                        UIView.animate(withDuration: PULSE_TIME / 2) {
                            self.ivFirstInterval.transform = CGAffineTransform.identity
                        }})
    }
    @objc private func pulseSecond() {
        UIView.animate(withDuration: PULSE_TIME / 2,
                       animations: {
                        self.ivSecondInterval.transform = CGAffineTransform(
                            scaleX: ANIMATE_SCALE, y: ANIMATE_SCALE)
        },
                       completion: { _ in
                        UIView.animate(withDuration: PULSE_TIME / 2) {
                            self.ivSecondInterval.transform = CGAffineTransform.identity
                        }})
    }
    
    private func toggleButtons(toggle: Bool!) {
        
        lbIsPlaying.text = toggle ? "Stopped" : "Playing"
        
        pbNoSound.isEnabled = toggle
        pbFirstInterval.isEnabled = toggle
        pbSecondInterval.isEnabled = toggle
    }
    
    private func testNextFrequency(){
        let nextFreq = array_freqSeq.removeFirst()
        
        
        DispatchQueue.main.async { [unowned self] in
            let pbImgDir = "Animal_Icons/" + ARRAY_FREQ_DIR[nextFreq]
            let pbImg = UIImage(named: pbImgDir) as UIImage?
            
            self.ivFirstInterval.contentMode = .scaleAspectFit
            self.ivSecondInterval.contentMode = .scaleAspectFit
            
            self.ivFirstInterval.image = pbImg
            self.ivSecondInterval.image = pbImg
        }
        
        // run test
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            self._currentTestFlow.findThresholdAtFreq(nextFreq)
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.pulseAnimation()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        array_freqSeq = UserDefaults.standard.array(forKey: "array_freqSeq") as! [Int]
        
        testNextFrequency()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}

