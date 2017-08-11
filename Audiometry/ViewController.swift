//
//  ViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 7/21/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import UIKit
import AudioKit
import MediaPlayer

class ViewController: UIViewController {
    
    //*******************
    // Constants
    //*******************
    let DB_THRESHOLD: Double! = 100.0 // Assuming 1.0 amp = 80 dB
    let DB_DEFAULT: Double! = 50.0
    
    let ARRAY_FREQUENCY = [500.0, 750.0, 1000.0, 1500.0, 2000.0, 3000.0, 4000.0, 6000.0, 8000.0]
    
    //*******************
    // Variables
    //*******************
    var currentIndex: Int! = -1
    
    var generator: AKOperationGenerator! = nil
    
    var array_pbPlay = [UIButton]()
    var array_tbPresentLv = [UITextField]()
    var array_tbCorrectLv = [UITextField]()
    
    let settings = UserDefaults.standard
    //*******************
    // Outlets
    //*******************
    @IBOutlet weak var setVol: UIButton!
    
    @IBOutlet weak var svLabels: UIStackView!
    @IBOutlet weak var svButtons: UIStackView!
    @IBOutlet weak var svPresentLv: UIStackView!
    @IBOutlet weak var svLeftCorrectLv: UIStackView!
    @IBOutlet weak var svRightCorrectLv: UIStackView!
    
    //*******************
    // IBActions
    //*******************
    @IBAction func updateVolume(_ sender: UIButton) {
        
        updateCurrentVolume()
    }
    
    @IBAction func playSignal(_ sender: UIButton) {
        // No tone playing at all, simply toggle on
        if(!generator.isStarted){
            
            currentIndex = array_pbPlay.index(of: sender)!
            array_pbPlay[currentIndex].setTitle("On", for: .normal)
            
            generator.start()
            
            // Update freq & vol
            generator.parameters[0] = ARRAY_FREQUENCY[currentIndex]
            updateCurrentVolume()
            
        }
        // Same tone, toggle it off
        else if(array_pbPlay[currentIndex] == sender){
            
            array_pbPlay[currentIndex].setTitle("Off", for: .normal)
            currentIndex = -1
            
            generator.stop()
        }
        // Else tone, switch frequency
        else {
            
            let senderIndex = array_pbPlay.index(of: sender)!
            
            array_pbPlay[currentIndex].setTitle("Off", for: .normal)
            currentIndex = senderIndex
            
            // Update freq & vol
            generator.parameters[0] = ARRAY_FREQUENCY[currentIndex]
            updateCurrentVolume()
            
            array_pbPlay[currentIndex].setTitle("On", for: .normal)
        }
    }
    
    
//    @IBAction func uponVolumeChanged(_ sender: UISlider) {
//        oscillator.amplitude = Double(sender.value);
//        setVolumeTo(volume: sender.value)
//
//        lbVolume.text = String(sender.value);
//    }
//    
//    //**sets volume as text box value
//    @IBAction func doSetVol(_ sender: UIButton) {
//        var vol = (boxVol.text! as NSString).floatValue;
//        while(vol > 1) {vol/=10;} //**scales down value
//        oscillator.amplitude = Double(vol);
//        setVolumeTo(volume: vol)
//        slider.setValue(vol, animated: false);
//        
//        lbVolume.text = String(vol);
//    }
    
    
    //*******************
    // Support functions
    //*******************
    
//    func setVolumeTo(volume: Float) {
//        (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(volume, animated: false)
//    }
    
    //Calls this function when the tap is recognized to clear keyboard
    
    func dismissKeyboard() {
        
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    func saveSettings(){
    
        for i in 0..<ARRAY_FREQUENCY.count {
        
            // Put the strings in to a string array
            var array_db = [String]()
            
            array_db.append(array_tbPresentLv[i].text!)
            array_db.append(array_tbCorrectLv[i * 2].text!)
            array_db.append(array_tbCorrectLv[i * 2 + 1].text!)
            
            // Map volume (dB) string array to their respective frequencies
            settings.set(array_db, forKey: String(ARRAY_FREQUENCY[i]))
        }
    }
    
    func loadSettings(){
        
        for i in 0..<ARRAY_FREQUENCY.count {
            
            // Retrieve saved volume strings by trying every key (freq)
            var array_db = settings.stringArray(forKey: String(ARRAY_FREQUENCY[i])) ?? nil
            
            // In case a new frequency is added, which has no default settings
            if(array_db != nil){
                
                array_tbPresentLv[i].text = array_db?[0]
                array_tbCorrectLv[i * 2].text = array_db?[1]
                array_tbCorrectLv[i * 2 + 1].text = array_db?[2]
            }
        }
    }
    
    // Covert dB to amplitude in double (0.0 to 1.0 range)
    func dbToAmp (_ db: Double!) -> Double{
        
        let dbAmp: Double = db - DB_THRESHOLD
        
        return pow(10.0, dbAmp / 20.0)
    }
    
    // Update volume to currently playing frequency tone
    func updateCurrentVolume()
    {
        // skip if not playing currently
        if(!generator.isStarted || (currentIndex == -1)){
            return
        }
        
        // retrieve vol
        let presentTxt: String = array_tbPresentLv[currentIndex].text!
        let leftCorrectTxt: String = array_tbCorrectLv[currentIndex * 2].text!
        let rightCorrectTxt: String = array_tbCorrectLv[currentIndex * 2 + 1].text!
        
        let presentDB: Double! = Double(presentTxt) ?? 0.0
        let leftCorrectDB: Double! = Double(leftCorrectTxt) ?? 0.0
        let rightCorrectDB: Double! = Double(rightCorrectTxt) ?? 0.0
        
        generator.parameters[1] = dbToAmp(presentDB! + leftCorrectDB!)
        generator.parameters[2] = dbToAmp(presentDB! + rightCorrectDB!)
    }
    
    func setupGenerator(){
        //*******************
        // Setup oscillator player which generates pure tones
        //*******************
        
        // generator to be configured by setting generator.parameter
        // param
        generator = AKOperationGenerator(numberOfChannels: 2) { parameters in
            
            let leftOutput = AKOperation.sineWave(frequency: parameters[0],
                                                  amplitude: parameters[1])
            let rightOutput = AKOperation.sineWave(frequency: parameters[0],
                                                   amplitude: parameters[2])
            
            return [leftOutput, rightOutput]
        }
        
        AudioKit.output = generator
        AudioKit.start()
    }
    
    func setupStackview(_ sv: UIStackView!){
        
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .center
        sv.spacing = 20
    }
    
    func setupMainStackview(){
        //*******************
        // Setup the main stackview that holds the main UI elements
        //*******************
        
        // Config stackviews
        setupStackview(svLabels)
        setupStackview(svButtons)
        setupStackview(svPresentLv)
        setupStackview(svLeftCorrectLv)
        setupStackview(svRightCorrectLv)
        
        //Creating play buttons for each respective freq
        for i in 0..<ARRAY_FREQUENCY.count {
            
            // Add frequency labels to svLabels
            let new_lbFreq = UILabel()
            new_lbFreq.text = String(ARRAY_FREQUENCY[i])
            new_lbFreq.textAlignment = .center
            
            svLabels.addArrangedSubview(new_lbFreq)
            
            // Add buttons to svButtons
            let new_pbPlay = UIButton(type:.system)

            new_pbPlay.bounds = CGRect(x:0, y:0, width:300, height:300)
            new_pbPlay.setTitle("Off", for: .normal)
            new_pbPlay.backgroundColor = UIColor.gray
            new_pbPlay.setTitleColor(UIColor.white, for: .normal)
            
            // Binding an action function to the new button
            // i.e. to play signal
            new_pbPlay.addTarget(self,
                                 action: #selector(playSignal(_:)),
                                 for: .touchUpInside)
            
            // Add the button to our current button array
            array_pbPlay += [new_pbPlay]
            svButtons.addArrangedSubview(new_pbPlay)
            
            // Add textboxes to svPresentLv for volume input in dB
            let new_tbPresentLv = UITextField()
            new_tbPresentLv.borderStyle = .roundedRect
            new_tbPresentLv.textAlignment = .center
            new_tbPresentLv.text = String(DB_DEFAULT)
            
            array_tbPresentLv += [new_tbPresentLv]
            svPresentLv.addArrangedSubview(new_tbPresentLv)
            
            // Add textboxes to svCorrectLV for volume input in dB
            let new_tbLeftCorrectLv = UITextField()
            new_tbLeftCorrectLv.borderStyle = .roundedRect
            new_tbLeftCorrectLv.textAlignment = .center
            
            array_tbCorrectLv += [new_tbLeftCorrectLv]
            svLeftCorrectLv.addArrangedSubview(new_tbLeftCorrectLv)
            
            let new_tbrightCorrectLv = UITextField()
            new_tbrightCorrectLv.borderStyle = .roundedRect
            new_tbrightCorrectLv.textAlignment = .center
            
            array_tbCorrectLv += [new_tbrightCorrectLv]
            svRightCorrectLv.addArrangedSubview(new_tbrightCorrectLv)
        }

    }
    
    // Init' function
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupGenerator()
        
        setupMainStackview()
        
        loadSettings()
        
        //*******************
        // Hides keyboard on tap
        //*******************
        
        let tap: UITapGestureRecognizer =
            UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveSettings),
                                               name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveSettings),
                                               name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

