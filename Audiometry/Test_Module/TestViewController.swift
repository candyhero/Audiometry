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
    
    private var timer, firstTimer, secondTimer: Timer?
    
    var pulseCounter: Int = 0
    
    // a map to record trials and results
    //
    
    @IBOutlet private weak var svIcons: UIStackView!
    
    @IBOutlet private weak var pbFirstInterval: UIButton!
    @IBOutlet private weak var pbSecondInterval: UIButton!
    @IBOutlet private weak var pbNoSound: UIButton!
    
    @IBOutlet private weak var pbRepeat: UIButton!
    @IBOutlet private weak var pbPause: UIButton!
    
    // UI Refresh functions
    @IBAction private func repeatPlaying(_ sender: UIButton) {
        pulseToggle(isPlaying: true)
        pulseAnimation(0)
        _currentTestFlow.repeatPlaying()
    }
    
    @IBAction private func pausePlaying(_ sender: UIButton) {
        toggleButtons(toggle: false)
        pulseToggle(isPlaying: false)
        
        firstTimer?.invalidate()
        secondTimer?.invalidate()
        timer?.invalidate()
        pulseCounter = 0
        _currentTestFlow.pausePlaying()
    }
    
    @IBAction private func checkResponse(_ sender: UIButton) {
        pausePlaying(sender)
        
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
                // Already tested both ears
                if(!(mainSetting?.frequencyProtocol?.isTestBoth)!) {
                    performSegue(withIdentifier: "segueResult", sender: nil)
                    return
                }
                else {
                    // Rewind back the first freq in the Q
                    // and test the other ear
                    try! realm.write{
                        mainSetting?.frequencyProtocol?.isTestBoth = false
                        mainSetting?.frequencyProtocol?.isLeft =
                            !(mainSetting?.frequencyProtocol?.isLeft)!
                        mainSetting?.frequencyTestIndex = 0
                    }
                    
                    print("Switching to the other ear")
                    performSegue(withIdentifier: "segueSwitchEar", sender: nil)
                }
            }
            else {
                testNewFreq()
            }
        }
        else { // Still testing this frequency
            
            // run test
            pulseToggle(isPlaying: true)
            timer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(textNextDB),
                                         userInfo: nil,
                                         repeats: false)
        }
    }
    
    @objc func textNextDB() {
        DispatchQueue.main.async { [unowned self] in
            self._currentTestFlow.playSignalCase()
            self.pulseAnimation(0)
        }
    }
    
    
    private func testNewFreq(){
        
        let nextFreqSeqID = mainSetting?.frequencyTestIndex
        let nextFreqID = array_freqSeq![nextFreqSeqID!]
        
        DispatchQueue.main.async { [unowned self] in
            let pbImgDir = "Shapes/" + ARRAY_DEFAULT_FREQ_DIR[nextFreqID]
            let pbImg = UIImage(named: pbImgDir)?.withRenderingMode(.alwaysOriginal)
            
            print(nextFreqID, pbImgDir)
            
            self.pbFirstInterval.imageView?.contentMode = .scaleAspectFit
            self.pbSecondInterval.imageView?.contentMode = .scaleAspectFit
            
            self.pbFirstInterval.setImage(pbImg, for: .normal)
            self.pbSecondInterval.setImage(pbImg, for: .normal)
            
            self.pbFirstInterval.adjustsImageWhenHighlighted = false
            self.pbSecondInterval.adjustsImageWhenHighlighted = false
        }
        // run test
        pulseToggle(isPlaying: true)
        timer = Timer.scheduledTimer(timeInterval: 1.0,
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
            self.pulseAnimation(0)
        }
    }
    
    private func toggleButtons(toggle: Bool!) {
        pbNoSound.isEnabled = toggle
        pbNoSound.isHighlighted = !toggle
        pbFirstInterval.isEnabled = toggle
        pbSecondInterval.isEnabled = toggle
    }
    
    //------------
    // Animation Functions
    //------------
    private func pulseAnimation(_ delay: Double) {
        
        // Play pulse Animation by number of times
        firstTimer = Timer.scheduledTimer(timeInterval: delay,
                                          target: self,
                                          selector: #selector(self.pulseFirstInterval),
                                          userInfo: nil,
                                          repeats: false)
        
        let firstDuration = PULSE_TIME * Double(NUM_OF_PULSE) + PLAY_GAP_TIME
        secondTimer = Timer.scheduledTimer(timeInterval: delay + firstDuration,
                                           target: self,
                                           selector: #selector(self.pulseSecondInterval),
                                           userInfo: nil,
                                           repeats: false)
        
        let totalDuration = PULSE_TIME * Double(NUM_OF_PULSE * 2) + PLAY_GAP_TIME
        timer = Timer.scheduledTimer(timeInterval: delay + totalDuration,
                                     target: self,
                                     selector: #selector(self.toggleNoSoundOn),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    private func pulseToggle(isPlaying: Bool!){
        pbPause.isHidden = !isPlaying
        pbRepeat.isHidden = isPlaying
    }
    
    @objc private func toggleNoSoundOn () {
        pbNoSound.isEnabled = true
        pulseToggle(isPlaying: false)
    }
    
    @objc private func pulseFirstInterval() {
        pbFirstInterval.isEnabled = true
        pulseCounter = NUM_OF_PULSE
        pulseInterval(pbFirstInterval)
    }
    
    
    @objc private func pulseSecondInterval() {
        pbSecondInterval.isEnabled = true
        pulseCounter = NUM_OF_PULSE
        pulseInterval(pbSecondInterval)
    }
    
    @objc private func pulseInterval(_ pbInterval: UIButton) {
        if(pulseCounter == 0) {return}
        pulseCounter -= 1
        
        UIView.animate(withDuration: PULSE_TIME / 2,
                       delay: 0,
                       options: .allowUserInteraction,
                       animations: {
                        pbInterval.transform = CGAffineTransform(
                            scaleX: ANIMATE_SCALE, y: ANIMATE_SCALE)},
                       completion: {_ in self.restoreInterval(pbInterval)}
        )
    }
    
    @objc private func restoreInterval(_ pbInterval: UIButton) {
        UIView.animate(withDuration: PULSE_TIME / 2,
                       delay: 0,
                       options: .allowUserInteraction,
                       animations: {
                        pbInterval.transform = CGAffineTransform.identity},
                       completion: {_ in self.pulseInterval(pbInterval)}
        )
    }
    
    //------------
    // Init'
    //------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainSetting = realm.objects(MainSetting.self).first
        array_freqSeq = mainSetting?.frequencyProtocol?.array_freqSeq
        
        pbNoSound.setBackgroundImage(UIImage(named: "Shapes/no_sound"), for: .normal)
        pbNoSound.adjustsImageWhenHighlighted = false
        
        toggleButtons(toggle: false)
        testNewFreq()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}

