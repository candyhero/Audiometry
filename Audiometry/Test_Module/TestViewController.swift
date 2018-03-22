//
//  TestViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 7/27/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import UIKit
import RealmSwift

// Global Static Constants shared by player and test flow

class TestViewController: UIViewController {
    
    private let realm = try! Realm()
    private var mainSetting: MainSetting? = nil
    private var array_freqSeq: List<Int>? = nil
    
    private var _currentTestFlow = TestFlow()
    
    private var timer: Timer?
    
    var flag_practiceMode: Bool!
    
    // a map to record trials and results
    //
    
    @IBOutlet private weak var svIcons: UIStackView!
    
    @IBOutlet private weak var pbFirstInterval: UIButton!
    @IBOutlet private weak var pbSecondInterval: UIButton!
    @IBOutlet private weak var pbNoSound: UIButton!
    
    // UI Refresh functions
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
        
        let isThresholdFound: Bool! =
            _currentTestFlow.checkThreshold(bool_sender)
        
        if(isThresholdFound){ // Done for this freq
            
            let isLastFreq = (mainSetting?.frequencyTestIndex == array_freqSeq?.count)
            
            // Pop the next freqSeq
            if(isLastFreq) {
                let isBothTested = !(mainSetting?.frequencyProtocol?.isTestBoth)!
                
                if(isBothTested) {
                    performSegue(withIdentifier: "segueResult", sender: nil)
                    return
                }
                else {
                    try! realm.write{
                        mainSetting?.frequencyProtocol?.isTestBoth = false
                        mainSetting?.frequencyProtocol?.isLeft =
                            !(mainSetting?.frequencyProtocol?.isLeft)!
                        mainSetting?.frequencyTestIndex = 0
                    }
                }
            }
            prepareToTestNextFreq()
        }
        else { // Still testing this frequency
            
            self.toggleButtons(toggle: false)
            
            // run test
            timer = Timer.scheduledTimer(timeInterval: 0.5,
                                         target: self,
                                         selector: #selector(textNextDB),
                                         userInfo: nil,
                                         repeats: false)
        }
    }
    
    @objc func textNextDB() {
        DispatchQueue.main.async { [unowned self] in
            self._currentTestFlow.playSignalCase()
            self.pulseAnimation()
        }
    }
    
    private func prepareToTestNextFreq(){
        
        let nextFreqSeqID = mainSetting?.frequencyTestIndex
        let nextFreqID = array_freqSeq![nextFreqSeqID!]
        
        DispatchQueue.main.async { [unowned self] in
            let pbImgDir = "Animal_Icons/" + ARRAY_DEFAULT_FREQ_DIR[nextFreqID]
            let pbImg = UIImage(named: pbImgDir)?.withRenderingMode(.alwaysOriginal)
            
            print(nextFreqID, pbImgDir)
            
            self.pbFirstInterval.imageView?.contentMode = .scaleAspectFit
            self.pbSecondInterval.imageView?.contentMode = .scaleAspectFit
            
            self.pbFirstInterval.setImage(pbImg, for: .normal)
            self.pbSecondInterval.setImage(pbImg, for: .normal)
            
            self.pbFirstInterval.adjustsImageWhenHighlighted = false
            self.pbSecondInterval.adjustsImageWhenHighlighted = false
        }
        
        
        self.toggleButtons(toggle: false)
        // run test
        timer = Timer.scheduledTimer(timeInterval: 0.5,
                                     target: self,
                                     selector: #selector(testNextFreq),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    @objc func testNextFreq(){
        DispatchQueue.main.async { [unowned self] in
            
            let nextFreqSeqID = self.mainSetting?.frequencyTestIndex
            let nextFreqID = self.array_freqSeq![nextFreqSeqID!]
            
            self._currentTestFlow.findThresholdAtFreq(nextFreqID)
            self.pulseAnimation()
        }
    }
    
    private func toggleButtons(toggle: Bool!) {
        pbNoSound.isEnabled = toggle
        pbFirstInterval.isEnabled = toggle
        pbSecondInterval.isEnabled = toggle
    }
    
    //------------
    // Animation Functions
    //------------
    private func pulseAnimation() {
        
        // Disable the buttons first
//        self.toggleButtons(toggle: false)
        
        let delayTime = PULSE_TIME * NUM_OF_PULSE * 2 + PLAY_GAP_TIME
        
        // Play pulse Animation by number of times
        for pulse in stride(from: 0, to: NUM_OF_PULSE, by: 1) {
            let delayTime = PULSE_TIME * pulse
            self.timer = Timer.scheduledTimer(timeInterval: delayTime,
                                              target: self,
                                              selector: #selector(self.pulseAnimationFirst),
                                              userInfo: nil,
                                              repeats: false)
        }
        
        
        for pulse in stride(from: 0, to: NUM_OF_PULSE, by: 1) {
            let delayTime = PULSE_TIME * (pulse + NUM_OF_PULSE) + PLAY_GAP_TIME
            self.timer = Timer.scheduledTimer(timeInterval: delayTime,
                                              target: self,
                                              selector: #selector(self.pulseAnimationSecond),
                                              userInfo: nil,
                                              repeats: false)
        }
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + delayTime,
            execute:{self.toggleButtons(toggle: true)}
        )
    }
    
    @objc private func pulseAnimationFirst() {
        UIView.animate(withDuration: PULSE_TIME / 2,
                       animations: {
                        self.pbFirstInterval.transform = CGAffineTransform(
                            scaleX: ANIMATE_SCALE, y: ANIMATE_SCALE)
        },
                       completion: { _ in
                        UIView.animate(withDuration: PULSE_TIME / 2) {
                            self.pbFirstInterval.transform = CGAffineTransform.identity
                        }})
    }
    
    @objc private func pulseAnimationSecond() {
        UIView.animate(withDuration: PULSE_TIME / 2,
                       animations: {
                        self.pbSecondInterval.transform = CGAffineTransform(
                            scaleX: ANIMATE_SCALE, y: ANIMATE_SCALE)
        },
                       completion: { _ in
                        UIView.animate(withDuration: PULSE_TIME / 2) {
                            self.pbSecondInterval.transform = CGAffineTransform.identity
                        }})
    }
    
    //------------
    // Init'
    //------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainSetting = realm.objects(MainSetting.self).first
        array_freqSeq = mainSetting?.frequencyProtocol?.array_freqSeq
        
        prepareToTestNextFreq()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}

