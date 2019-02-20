//
//  TestViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 7/27/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import UIKit

class AdultTestViewController: UIViewController {
    
//------------------------------------------------------------------------------
// Local Variables
//------------------------------------------------------------------------------
    private var testModel = TestModel()
    
    // Used by animator
    private var timer, firstTimer, secondTimer: Timer?
    private var pulseCounter: Int = 0
    
    @IBOutlet private weak var svIcons: UIStackView!
    
    @IBOutlet private weak var pbFirstInterval: UIButton!
    @IBOutlet private weak var pbSecondInterval: UIButton!
    @IBOutlet private weak var pbNoSound: UIButton!
    
    @IBOutlet private weak var pbRepeat: UIButton!
    @IBOutlet private weak var pbPause: UIButton!
    
//------------------------------------------------------------------------------
// Main Flow
//------------------------------------------------------------------------------
    private func testNewFreq(){
        let freq: Int = testModel.nextTestFreq()
        // Setup UI for next freq
        DispatchQueue.main.async { [unowned self] in
            let imgDir = "Shape_Icons/"+String(freq)+"Hz"
            let img = UIImage(named:imgDir)?.withRenderingMode(.alwaysOriginal)
            
            print(freq, imgDir)
            
            self.pbFirstInterval.imageView?.contentMode = .scaleAspectFit
            self.pbSecondInterval.imageView?.contentMode = .scaleAspectFit
            
            self.pbFirstInterval.setImage(img, for: .normal)
            self.pbSecondInterval.setImage(img, for: .normal)
            
            self.pbFirstInterval.adjustsImageWhenHighlighted = false
            self.pbSecondInterval.adjustsImageWhenHighlighted = false
        }
        
        // run test
        pulseToggle(isPlaying: true)
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(testNextDB),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    @objc func testNextDB() {
        DispatchQueue.main.async { [unowned self] in
            self.testModel.playSignalCase()
            self.pulseAnimation(0)
        }
    }
    
//------------------------------------------------------------------------------
// UI Functions
//------------------------------------------------------------------------------
    @IBAction private func repeatPlaying(_ sender: UIButton) {
        pulseToggle(isPlaying: true)
        pulseAnimation(0)
        testModel.replaySignalCase()
    }
    
    @IBAction private func pausePlaying(_ sender: UIButton) {
        toggleButtons(toggle: false)
        pulseToggle(isPlaying: false)
        
        firstTimer?.invalidate()
        secondTimer?.invalidate()
        timer?.invalidate()
        pulseCounter = 0
        testModel.pausePlaying()
    }

//------------------------------------------------------------------------------
// Test Functions
//------------------------------------------------------------------------------
    @IBAction private func checkResponse(_ sender: UIButton) {
        pausePlaying(sender)
        
        // DispatchQueue default **
        // Compare test blah
        let currentPlaycase: Int! = testModel.currentPlayCase()
        
        var isCorrect: Bool! = true
        
        // determine next volume level
        switch currentPlaycase {
        case 0: // Slient interval
            
            isCorrect = (sender == pbNoSound)
            break
        case 1: // First interval
            
            isCorrect = (sender == pbFirstInterval)
            break
        case 2: // Second interval
            
            isCorrect = (sender == pbSecondInterval)
            break
        default:
            break
        }
        
        let isThresholdFound: Bool! = testModel.checkThreshold(isCorrect, false)
        if(isThresholdFound){ // Done for this freq
            print(testModel.nextTestFreq())
            if(testModel.nextTestFreq() < 0) {
                print("Switching to the other ear")
                testModel.terminatePlayer()
                performSegue(withIdentifier: "segueSwitchEar", sender: nil)
            } else if(testModel.nextTestFreq() == 0){
                // Already tested both ears
                testModel.terminatePlayer()
                performSegue(withIdentifier: "segueResult", sender: nil)
            } else {
                testNewFreq()
            }
            return
        }
        
        // Still testing this frequency
        pulseToggle(isPlaying: true)
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(testNextDB),
                                     userInfo: nil,
                                     repeats: false)
    }
    
//------------------------------------------------------------------------------
// Animation Functions
//------------------------------------------------------------------------------
    private func toggleButtons(toggle: Bool!) {
        pbNoSound.isEnabled = toggle
        pbNoSound.isHighlighted = !toggle
        pbFirstInterval.isEnabled = toggle
        pbSecondInterval.isEnabled = toggle
    }
    
    private func pulseToggle(isPlaying: Bool!){
        pbPause.isHidden = !isPlaying
        pbRepeat.isHidden = isPlaying
    }
    
    @objc private func toggleNoSoundOn () {
        pbNoSound.isEnabled = true
        pulseToggle(isPlaying: false)
    }
    
    private func pulseAnimation(_ delay: Double) {
        // Play pulse Animation by number of times
        firstTimer = Timer.scheduledTimer(timeInterval: delay,
                                          target: self,
                                          selector: #selector(self.pulseFirstInterval),
                                          userInfo: nil,
                                          repeats: false)
        
        let firstDuration = PULSE_TIME_ADULT * Double(NUM_OF_PULSE_ADULT) + PLAY_GAP_TIME
        secondTimer = Timer.scheduledTimer(timeInterval: delay + firstDuration,
                                           target: self,
                                           selector: #selector(self.pulseSecondInterval),
                                           userInfo: nil,
                                           repeats: false)
        
        let totalDuration = PULSE_TIME_ADULT * Double(NUM_OF_PULSE_ADULT * 2) + PLAY_GAP_TIME
        timer = Timer.scheduledTimer(timeInterval: delay + totalDuration,
                                     target: self,
                                     selector: #selector(self.toggleNoSoundOn),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    @objc private func pulseFirstInterval() {
        pbFirstInterval.isEnabled = true
        pulseCounter = NUM_OF_PULSE_ADULT
        pulseInterval(pbFirstInterval)
    }
    
    @objc private func pulseSecondInterval() {
        pbSecondInterval.isEnabled = true
        pulseCounter = NUM_OF_PULSE_ADULT
        pulseInterval(pbSecondInterval)
    }
    
    @objc private func pulseInterval(_ pbInterval: UIButton) {
        if(pulseCounter == 0) {return}
        pulseCounter -= 1
        
        UIView.animate(withDuration: PULSE_TIME_ADULT / 2,
                       delay: 0,
                       options: .allowUserInteraction,
                       animations: {
                        pbInterval.transform = CGAffineTransform(
                            scaleX: ANIMATE_SCALE, y: ANIMATE_SCALE)},
                       completion: {_ in self.restoreInterval(pbInterval)}
        )
    }
    
    @objc private func restoreInterval(_ pbInterval: UIButton) {
        UIView.animate(withDuration: PULSE_TIME_ADULT / 2,
                       delay: 0,
                       options: .allowUserInteraction,
                       animations: {
                        pbInterval.transform = CGAffineTransform.identity},
                       completion: {_ in self.pulseInterval(pbInterval)}
        )
    }
    
//------------------------------------------------------------------------------
// Initialize View
//------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set UI
        let imgNoSound = UIImage(named: "Shape_Icons/no_sound")
        pbNoSound.setBackgroundImage(imgNoSound, for: .normal)
        pbNoSound.adjustsImageWhenHighlighted = false
        toggleButtons(toggle: false)
        
        testNewFreq()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}

