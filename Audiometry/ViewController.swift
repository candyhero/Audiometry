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
    
    var oscillator = AKFMOscillator()
    var currentButton: UIButton!
    
    //MARK: Properties
    @IBOutlet weak var pb500: UIButton!
    @IBOutlet weak var pb1000: UIButton!
    @IBOutlet weak var pb2000: UIButton!
    @IBOutlet weak var pb4000: UIButton!
    @IBOutlet weak var pb8000: UIButton!
    @IBOutlet weak var lb500: UILabel!
    @IBOutlet weak var lb1000: UILabel!
    @IBOutlet weak var lb2000: UILabel!
    @IBOutlet weak var lb4000: UILabel!
    @IBOutlet weak var lb8000: UILabel!
    @IBOutlet weak var pbSave: UIButton!
    @IBOutlet weak var lbVolume: UILabel!
    @IBOutlet weak var lbCurrentFreq: UILabel!
    
    //MARK: Actions
    func setVolumeTo(volume: Float) {
        (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(volume, animated: false)
    }
    
    @IBAction func uponVolumeChanged(_ sender: UISlider) {
        oscillator.amplitude = Double(sender.value);
        setVolumeTo(volume: sender.value)
        
        lbVolume.text = String(sender.value);
    }
    
    @IBAction func saveVolume(_ sender: Any)
    {
        switch currentButton {
        case pb500:
            lb500.text = lbVolume.text;
            
        case pb1000:
            lb1000.text = lbVolume.text;
            
        case pb2000:
            lb2000.text = lbVolume.text;
            
        case pb4000:
            lb4000.text = lbVolume.text;
            
        case pb8000:
            lb8000.text = lbVolume.text;
        default:
            break;
        }
    }
    
    @IBAction func playSignal(_ sender: UIButton) {
        
        if(oscillator.isPlaying && sender == currentButton)
        {
            oscillator.stop()
            let currentTitle = String(Int(oscillator.baseFrequency)) + " Hz"
            currentButton.setTitle(currentTitle, for: .normal)
            lbCurrentFreq.text = " "
        }
        else
        {
            if(oscillator.isPlaying && sender != currentButton)
            {
                let currentTitle = String(Int(oscillator.baseFrequency)) + " Hz"
                currentButton.setTitle(currentTitle, for: .normal)
            }
            else
            {
                oscillator.start()
            }
            
            switch sender {
            case pb500:
                oscillator.baseFrequency = 500.0;
            case pb1000:
                oscillator.baseFrequency = 1000.0;
            case pb2000:
                oscillator.baseFrequency = 2000.0;
            case pb4000:
                oscillator.baseFrequency = 4000.0;
            case pb8000:
                oscillator.baseFrequency = 8000.0;
            default:
                oscillator.baseFrequency = 8000.0;
            }
            
            currentButton = sender
            lbCurrentFreq.text = sender.currentTitle
            sender.setTitle("Stop", for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        oscillator.amplitude = 0.2
        oscillator.rampTime = 0
        AudioKit.output = oscillator
        AudioKit.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

