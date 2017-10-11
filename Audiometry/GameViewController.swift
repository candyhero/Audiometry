//
//  GameViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 7/27/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AudioKit

class GameViewController: UIViewController {
    
    let DB_SYSTEM_MAX: Double! = 105.0
    let ATTACK_TIME: Double! = 0.06
    let HOLD_TIME: Double! = 0.2
    let RELEASE_TIME: Double! = 0.06
    let PULSE_TIME: Double! = 0.38
    let PLAY_INTERVAL_TIME: Double! = 1.5
    let PLAY_GAP_TIME: Double! = 0.5
    
    
    var dict_freq: [Double: [Double]]!
    var dict_rightCount: [Double: Int]!
    var dict_wrongCount: [Double: Int]!
    
    var array_freq: [Double]!
    var array_correctionFactors: [Double]! // correction factors in dB
    
    var hw: Double! = nil
    var thresholdDB: Double! = nil
    var currentSetting: [String: [String]]!
    
    var currentIndex = 3
    var currentPlaycase: Int!
    var currentDB: Double! = 70.0
    var flag_initialPhase: Bool! = false
    
    var generator: AKOperationGenerator! = nil
    
    // a map to record trials and results
    //
    @IBOutlet weak var lbIsPlaying: UILabel!
    @IBOutlet weak var lbPhaseState: UILabel!
    @IBOutlet weak var lbCurrentSetting: UILabel!
    @IBOutlet weak var lbDebug: UILabel!
    
    @IBOutlet weak var pbFirstInterval: UIButton!
    @IBOutlet weak var pbSecondInterval: UIButton!
    @IBOutlet weak var pbNoSound: UIButton!
    
    @IBAction func returnToTitle(_ sender: UIButton) {
        
//        let titleVC = self.storyboard.instantiateViewControllerWithIdentifier("Title View Controller") as TitleViewController
//        navigationController?.pushViewController(titleVC, animated: false)
        
    }
    
    @IBAction func checkResponse(_ sender: UIButton) {
        // stop current player
        generator.stop()
        
        // Record choice/result for this round
        var deltaDB: Double!
        
        if(!flag_initialPhase) {
            
            deltaDB = runInitialPhase(sender)
        }
        else {
            
            deltaDB = runThresholdSearchingPhase(sender)
        }
        
        // Add current dB value to track list
        dict_freq[array_freq[currentIndex]]?.append(currentDB)
        
        let flag_currentDB = (deltaDB < 0)
        
        // Compute next dB
        let nextDB: Double! = currentDB + deltaDB
        
        if(flag_currentDB){
            dict_rightCount[currentDB] = (dict_rightCount[currentDB] ?? 0) + 1
        }
        else {
            
            dict_wrongCount[currentDB] = (dict_wrongCount[currentDB] ?? 0) + 1
        }
        
        if(!flag_initialPhase){
            
            if((dict_rightCount[currentDB] ?? 0) > 0 &&
                (dict_wrongCount[nextDB] ?? 0) > 0){
                
//                hw = nextDB
                
                flag_initialPhase = true
                lbPhaseState.text = "Threshold Finding"
            }
        }
        else {
            
            if(flag_currentDB){
                
                let rightCurrent: Int! = dict_rightCount[currentDB] ?? 0
                let wrongCurrent: Int! = dict_wrongCount[currentDB] ?? 1
                let wrongNext: Int! = dict_wrongCount[nextDB] ?? 0
                let rightNext: Int! = dict_rightCount[nextDB] ?? 1
                
                if(rightCurrent > wrongCurrent && wrongNext > rightNext){
                    
                    thresholdDB = currentDB
                }
            }
            else {
                
                let rightUpper: Int! = dict_rightCount[currentDB + 5] ?? 0
                let wrongUpper: Int! = dict_wrongCount[currentDB + 5] ?? 1
                let wrongCurrent: Int! = dict_wrongCount[currentDB] ?? 0
                let rightCurrent: Int! = dict_rightCount[currentDB] ?? 1
                
                if(rightUpper > wrongUpper && wrongCurrent > rightCurrent){
                    
                    thresholdDB = currentDB + 5
                }
            }
        }
        
        // Load new volume
        updatePlayerVolume(nextDB)
        currentDB = nextDB!
        
        // Draw new case
        //currentPlaycase = Int(arc4random_uniform(3))
        currentPlaycase = Int(arc4random_uniform(2) + 1)
        
        // Play new case
        if(thresholdDB == nil) {
            
            playSignalCase()
        }
        else {
            
            thresholdFound()
        }
    }
    
    func thresholdFound() {
        
        UserDefaults.standard.set(thresholdDB, forKey: "thresholdValue")
        UserDefaults.standard.set(dict_freq[array_freq[currentIndex]], forKey: "result")
        
        performSegue(withIdentifier: "segueResult", sender: nil)
    }
    
    func runInitialPhase (_ sender: UIButton!) -> Double {
        
        var deltaDB: Double!
        
        // determine next volume level
        switch currentPlaycase {
        case 0: // Slient interval
            
            deltaDB = (sender == pbNoSound) ? -10 : 20
            break
        case 1: // First interval
            
            deltaDB = (sender == pbFirstInterval) ? -10 : 20
            break
        case 2: // Second interval
            
            deltaDB = (sender == pbSecondInterval) ? -10 : 20
            break
        default:
            break
        }
        
        return deltaDB
    }
    
    func runThresholdSearchingPhase(_ sender: UIButton!) -> Double
    {
        var deltaDB: Double!
        
        // determine next volume level
        switch currentPlaycase {
        case 0: // Slient interval
            
            deltaDB = (sender == pbNoSound) ? -5 : 10
            break
        case 1: // First interval
            
            deltaDB = (sender == pbFirstInterval) ? -5 : 10
            break
        case 2: // Second interval
            
            deltaDB = (sender == pbSecondInterval) ? -5 : 10
            break
        default:
            break
        }
        
        return deltaDB
    }
    
    func playSignalCase() {
        
        // Blinks interval pbs
        //        UIView.animate(
        //            withDuration: 0.2,
        //            delay:0.0,
        //            options:[.allowUserInteraction],
        //            animations: {self.pbFirstInterval.alpha = 0.0},
        //            completion: {finish in self.pbFirstInterval.alpha = 1.0})
        
        lbDebug.text = String(currentDB)
        lbIsPlaying.text = String("Playing")
        
        pbNoSound.isEnabled = false
        pbFirstInterval.isEnabled = false
        pbSecondInterval.isEnabled = false
        
        switch currentPlaycase {
        case 0: // Slient interval
            break
        case 1: // First interval
            generator.start()
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + PLAY_INTERVAL_TIME ,
                execute:{self.generator.stop()}
            )
            break
        case 2: // Second interval
            // First interval silence 2s
            // + Slience gap 0.5s
            DispatchQueue.main.asyncAfter(
                deadline: .now() + Double(PLAY_INTERVAL_TIME + PLAY_GAP_TIME),
                execute:{self.generator.start()}
            )
            
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + PLAY_INTERVAL_TIME * 2 + PLAY_GAP_TIME,
                execute:{self.generator.stop()}
            )
            
            break
        default:
            break
        }
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + PLAY_INTERVAL_TIME * 2 + PLAY_GAP_TIME,
            execute:{self.enableButtons()}
        )
    }
    
    func enableButtons() {
        
        lbIsPlaying.text = String("Stopped")
        
        pbNoSound.isEnabled = true
        pbFirstInterval.isEnabled = true
        pbSecondInterval.isEnabled = true
    }
    
    //
    // Init Functions
    //
    func loadCalibrationSetting() {
        
        let currentSettingKey = UserDefaults.standard.string(
            forKey: "currentSetting") ?? nil
        
        lbCurrentSetting.text = currentSettingKey
        
        currentSetting = UserDefaults.standard.dictionary(
            forKey: currentSettingKey!) as! [String : [String]]
        
        array_freq = UserDefaults.standard.array(
            forKey: "freqArray") as! [Double]
        
        array_correctionFactors = [Double]()
        
        dict_freq = [Double: [Double]]()
        
        flag_initialPhase = false
        
        for i in 0..<array_freq.count {
            
            // Retrieve saved volume strings by trying every key (freq)
            let freqKey: String = String(array_freq[i])
            var array_db = currentSetting[freqKey] as [String]! ?? nil
            
            // In case a new frequency is added, 
            // which has no default UserDefaults.standard
            if(array_db != nil){
                
                let expectedTxt: String! = array_db?[0] ?? nil
                let leftMeasuredTxt: String! = array_db?[2] ?? nil
                let rightMeasuredTxt: String! = array_db?[3] ?? nil
                
                let expectedDBSPL: Double! = Double(expectedTxt) ?? 0.0
                
                let leftMeasuredDBSPL: Double! =
                    Double(leftMeasuredTxt) ?? expectedDBSPL
                let rightMeasuredDBSPL: Double! =
                    Double(rightMeasuredTxt) ?? expectedDBSPL
                
                // Extract the correction factors in dB
                array_correctionFactors.append(
                    expectedDBSPL - leftMeasuredDBSPL)
                array_correctionFactors.append(
                    expectedDBSPL - rightMeasuredDBSPL)
            }
        }
    }
    
    func setupAudioPlayer() {
        
        //*******************
        // Setup oscillator player which generates pure tones
        //*******************
        
        // To load settings
        // Determine current freq
        // !!!!! Move save setting to title VC
        array_freq = UserDefaults.standard.array(forKey: "freqArray")! as! [Double]
        
        
        // generator to be configured by setting generator.parameter
        // param
        
        generator = AKOperationGenerator(numberOfChannels: 2) {
            
            parameters in
            
            let leftSine = AKOperation.sineWave(frequency: parameters[0],
                                                amplitude: parameters[1])
            
            let rightSine = AKOperation.sineWave(frequency: parameters[0],
                                                    amplitude: parameters[2])
            
            
            //            let leftSine = AKOperation.sineWave(frequency: parameters[0],
            //                                                amplitude: 1.0)
            //
            //            let rightSine = AKOperation.sineWave(frequency: parameters[0],
            //                                                 amplitude: 1.0)
            
            let clock = AKOperation.periodicTrigger(period: PULSE_TIME)
            
            let leftOutput = leftSine.triggeredWithEnvelope(
                trigger: clock,
                attack: ATTACK_TIME,
                hold: HOLD_TIME,
                release: RELEASE_TIME)
            
            let rightOutput = rightSine.triggeredWithEnvelope(
                trigger: clock,
                attack: ATTACK_TIME,
                hold: HOLD_TIME,
                release: RELEASE_TIME)
            
            return [leftOutput, rightOutput]
        }
        
        AudioKit.output = generator
        AudioKit.start()
    }
    
    // Update audio player volume
    func updatePlayerVolume(_ newExpectedVol: Double) {
        
        //        print(leftCorrectionFactor)
        //        print(rightCorrectionFactor)
        
        // Set left & right volume
        self.generator.parameters[1] = self.dbToAmp(
            newExpectedVol + array_correctionFactors[currentIndex * 2])
        self.generator.parameters[2] = self.dbToAmp(
            newExpectedVol + array_correctionFactors[currentIndex * 2 + 1])
        
        print(newExpectedVol)
    }
    
    
    // Covert dB to amplitude in double (0.0 to 1.0 range)
    func dbToAmp (_ dB: Double!) -> Double{
        
        // volume in absolute dB to be converted to amplitude
        // 1.0 amplitude <-> 0 absoulte dB
        let ampDB: Double = dB - DB_SYSTEM_MAX
        
        let amp: Double = pow(10.0, ampDB / 20.0)
        
        return ((amp > 1) ? 1 : amp)
    }
    
    func findThresholdAtFreq(_ freq: Double!){
        
        
        generator.parameters[0] = freq
        
        dict_freq[freq] = [Double]()
        dict_rightCount = [Double:Int]()
        dict_wrongCount = [Double:Int]()
        
        //
        lbPhaseState.text = "Initial Phase"
        
        // Set init volume & random play case
        updatePlayerVolume(currentDB)
        
        //currentPlaycase = Int(arc4random_uniform(3))
        currentPlaycase = Int(arc4random_uniform(2) + 1)
        playSignalCase()
    }

    
    //
    // UI
    //
    func loadSKView() {
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func setupUI() {
        
    }
    
    // 
    // Overload
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCalibrationSetting()
        
        setupAudioPlayer()
        
        findThresholdAtFreq(array_freq[currentIndex])
        
//        loadSKView()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}

