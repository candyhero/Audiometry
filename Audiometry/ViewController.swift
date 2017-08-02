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
    //**Added buttons and labels for other freqs and left/right
    @IBOutlet weak var pb500: UIButton!
    @IBOutlet weak var pb750: UIButton!
    @IBOutlet weak var pb1000: UIButton!
    @IBOutlet weak var pb1500: UIButton!
    @IBOutlet weak var pb2000: UIButton!
    @IBOutlet weak var pb3000: UIButton!
    @IBOutlet weak var pb4000: UIButton!
    @IBOutlet weak var pb6000: UIButton!
    @IBOutlet weak var pb8000: UIButton!
    @IBOutlet weak var lb500: UILabel!
    @IBOutlet weak var lb750: UILabel!
    @IBOutlet weak var lb1000: UILabel!
    @IBOutlet weak var lb1500: UILabel!
    @IBOutlet weak var lb2000: UILabel!
    @IBOutlet weak var lb3000: UILabel!
    @IBOutlet weak var lb4000: UILabel!
    @IBOutlet weak var lb6000: UILabel!
    @IBOutlet weak var lb8000: UILabel!
    @IBOutlet weak var pbSave: UIButton!
    @IBOutlet weak var lbR500: UILabel!
    @IBOutlet weak var lbR750: UILabel!
    @IBOutlet weak var lbR1000: UILabel!
    @IBOutlet weak var lbR1500: UILabel!
    @IBOutlet weak var lbR2000: UILabel!
    @IBOutlet weak var lbR3000: UILabel!
    @IBOutlet weak var lbR4000: UILabel!
    @IBOutlet weak var lbR6000: UILabel!
    @IBOutlet weak var lbR8000: UILabel!
    @IBOutlet weak var pbRSave: UIButton!
    @IBOutlet weak var lbVolume: UILabel!
    @IBOutlet weak var lbCurrentFreq: UILabel!
    @IBOutlet weak var boxVol: UITextField!
    @IBOutlet weak var setVol: UIButton!
    @IBOutlet weak var slider: UISlider!
    

    
    //MARK: Actions
    func setVolumeTo(volume: Float) {
        (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(volume, animated: false)
    }
    
    @IBAction func uponVolumeChanged(_ sender: UISlider) {
        oscillator.amplitude = Double(sender.value);
        setVolumeTo(volume: sender.value)
        
        lbVolume.text = String(sender.value);
    }
    
     //**sets volume as text box value
    @IBAction func doSetVol(_ sender: UIButton) {
        var vol = (boxVol.text! as NSString).floatValue;
        while(vol > 1) {vol/=10;} //**scales down value
        oscillator.amplitude = Double(vol);
        setVolumeTo(volume: vol)
        slider.setValue(vol, animated: false);
        
        lbVolume.text = String(vol);
    }
    
    @IBAction func saveVolume(_ sender: Any)
    {
        switch currentButton {
        case nil: //**currentButton is nil before any frequency is selected
            break;
        case pb500:
            lb500.text = lbVolume.text;
        case pb750:
            lb750.text = lbVolume.text;
        case pb1000:
            lb1000.text = lbVolume.text;
        case pb1500:
            lb1500.text = lbVolume.text;
        case pb2000:
            lb2000.text = lbVolume.text;
        case pb3000:
            lb3000.text = lbVolume.text;
        case pb4000:
            lb4000.text = lbVolume.text;
        case pb6000:
            lb6000.text = lbVolume.text;
        case pb8000:
            lb8000.text = lbVolume.text;
        default:
            break;
        }
    }
    @IBAction func saveRVolume(_ sender: Any)
    {
        switch currentButton {
        case nil: //**currentButton is nil before any frequency is selected
            break;
        case pb500:
            lbR500.text = lbVolume.text;
        case pb750:
            lbR750.text = lbVolume.text;
        case pb1000:
            lbR1000.text = lbVolume.text;
        case pb1500:
            lbR1500.text = lbVolume.text;
        case pb2000:
            lbR2000.text = lbVolume.text;
        case pb3000:
            lbR3000.text = lbVolume.text;
        case pb4000:
            lbR4000.text = lbVolume.text;
        case pb6000:
            lbR6000.text = lbVolume.text;
        case pb8000:
            lbR8000.text = lbVolume.text;
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
            
            switch sender { //**Added frequencies
            case pb500:
                oscillator.baseFrequency = 500.0;
            case pb750:
                oscillator.baseFrequency = 750.0;
            case pb1000:
                oscillator.baseFrequency = 1000.0;
            case pb1500:
                oscillator.baseFrequency = 1500.0;
            case pb2000:
                oscillator.baseFrequency = 2000.0;
            case pb3000:
                oscillator.baseFrequency = 3000.0;
            case pb4000:
                oscillator.baseFrequency = 4000.0;
            case pb6000:
                oscillator.baseFrequency = 6000.0;
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
        
        //hides keyboard on tap
        //*******************
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        //*******************
    }
    
    //Calls this function when the tap is recognized to clear keyboard
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

