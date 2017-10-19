//
//  CalibrationViewController
//  Audiometry
//
//  Created by Xavier Chan on 7/21/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import UIKit
import AudioKit

class CalibrationViewController: UIViewController {
    
    //*******************
    // Constants
    //*******************
    let DB_SYSTEM_MAX: Double! = 105.0 // At volume amplitude = 1.0
    let DB_DEFAULT: Double! = 70.0
    let RAMP_TIME: Double! = 1.5
    let RAMP_TIMESTEP: Double! = 0.01
    
//    let ARRAY_FREQUENCY: [Double]! = [250.0, 500.0, 750.0, 1000.0, 1500.0,
//                           2000.0, 3000.0, 4000.0, 6000.0, 8000.0]
    
    //*******************
    // Variables
    //*******************
    var currentIndex: Int! = -1
    
    var generator: AKOperationGenerator! = nil
    
    var array_freq: [Double]!
    var array_picker: [String]!
    
    var array_pbPlay = [UIButton]()
    var array_tbExpectedDBSPL = [UITextField]()
    var array_tbPresentDBHL = [UITextField]()
    var array_tbMeasuredDBSPL = [UITextField]()
    
    var currentSetting: String!
    var currentSelection: String!
    
    //*******************
    // Outlets
    //*******************
    @IBOutlet weak var pbSetCurrentVol: UIButton!
    @IBOutlet weak var pbLoadDefaultPresentLv: UIButton!
    @IBOutlet weak var pbClearMesauredLv: UIButton!
    
    @IBOutlet weak var pbSaveAs: UIButton!
    @IBOutlet weak var pbSaveToCurrent: UIButton!
    @IBOutlet weak var pbLoadOther: UIButton!
    @IBOutlet weak var pbDeleteCurrent: UIButton!
    
    @IBOutlet weak var lbCurrentSetting: UILabel!
    
    @IBOutlet weak var svLabels: UIStackView!
    @IBOutlet weak var svButtons: UIStackView!
    @IBOutlet weak var svExpectedDBSPL: UIStackView!
    @IBOutlet weak var svPresentDBHL: UIStackView!
    @IBOutlet weak var svLeftMeasuredDBSPL: UIStackView!
    @IBOutlet weak var svRightMeasuredDBSPL: UIStackView!
    
    @IBOutlet weak var tbPicker: UITextField!
    //*******************
    // IBActions & their sub-functions
    //*******************
    @IBAction func saveAs(_ sender: UIButton) {
    
        // Prompt for user to input setting name
        let alertController = UIAlertController(
            title: "Save Setting",
            message: "Please Enter Setting Name:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) {
            (_) in
        
            if let field = alertController.textFields?[0] {
                // store setting
                self.saveSetting(field.text!)
                
                // make sure load setting is enabled
                self.checkCurrentPB()
                self.checkLoadList()
            }
            else {
                // user did not fill field
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "i.e. iPad1-EP1"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func saveToCurrent(_ sender: UIButton) {
        
        self.saveSetting(currentSetting)
    }
    
    
    // Save and Load
    //
    func saveSetting(_ settingKey: String){
        
        // Create a dictionary to map all settings
        // with their corresponding freqs
        var newSetting = [String: [String]]()
        
        for i in 0..<array_freq.count {
            
            // Put the strings in to a string array
            var array_db = [String]()
            
            array_db.append(array_tbExpectedDBSPL[i].text!)
            array_db.append(array_tbPresentDBHL[i].text!)
            array_db.append(array_tbMeasuredDBSPL[i * 2].text!)
            array_db.append(array_tbMeasuredDBSPL[i * 2 + 1].text!)
            
            // Map volume (dB) string array to their respective frequencies
            let freqKey: String = String(array_freq[i])
            newSetting[freqKey] = array_db
        }
        
        // Store the setting dictionary into user defaults
        UserDefaults.standard.set(newSetting, forKey: settingKey)
        
        // Update setting list if this is a new setting
        if(!array_picker.contains(settingKey)){
            array_picker.append(settingKey)
            UserDefaults.standard.set(array_picker, forKey: "settingList")
        }
        
        // Update current setting string
        currentSetting = settingKey
        backupCurrentSetting()
        lbCurrentSetting.text = currentSetting
    }
    
    @IBAction func deleteCurrent(_ sender: UIButton) {
        
        // Find the setting from the setting list
        if let index = array_picker.index(where: {$0 == currentSetting}) {
            
            // If found
            // Remove the setting name from the setting list
            array_picker.remove(at: index)
            UserDefaults.standard.set(array_picker, forKey: "settingList")
            
            // Remove the setting object from UserDefaults.standard
            UserDefaults.standard.removeObject(forKey: currentSetting)
            
            currentSetting = nil
            backupCurrentSetting() 
            lbCurrentSetting.text = "None"
            
            checkCurrentPB()
            checkLoadList()
        }
    }
    
    func loadSetting(_ settingKey: String){
        
        var setting = UserDefaults.standard.dictionary(forKey: settingKey)!
        
        for i in 0..<array_freq.count {
            
            // Retrieve saved volume strings by trying every key (freq)
            let freqKey: String = String(array_freq[i])
            var array_db = setting[freqKey] as! [String]! ?? nil
            
            // In case a new frequency is added, which has no default UserDefaults.standard
            if(array_db != nil){
                
                array_tbExpectedDBSPL[i].text = array_db?[0] ?? nil
                array_tbPresentDBHL[i].text = array_db?[1] ?? nil
                array_tbMeasuredDBSPL[i * 2].text = array_db?[2] ?? nil
                array_tbMeasuredDBSPL[i * 2 + 1].text = array_db?[3] ?? nil
            }
        }
        
        currentSetting = settingKey
        backupCurrentSetting()
        lbCurrentSetting.text = currentSetting
    }
    
    @objc func backupCurrentSetting() {
        UserDefaults.standard.set(currentSetting, forKey: "currentSetting")
    }
    
    
    
    @IBAction func loadOther(_ sender: UIButton) {
        
        let temp = UserDefaults.standard.array(forKey: "settingList")
            as! [String]! ?? nil
        let alertController: UIAlertController!
        
        if temp != nil && temp!.count > 0 {
            
//            array_picker = temp!
            
            currentSelection = array_picker[0]
            
            alertController = UIAlertController(
                title: "Select a different setting",
                message: "\n\n\n\n\n\n\n\n\n",
                preferredStyle: .alert)
            
            let picker = UIPickerView(frame:
                CGRect(x: 0, y: 50, width: 260, height: 160))
            
            picker.delegate = self
            picker.dataSource = self
            
            alertController.view.addSubview(picker)
            
            let confirmAction = UIAlertAction(
                title: "Confirm", style: .default) {(_) in
                
                self.loadSetting(self.currentSelection)
                    
                self.checkCurrentPB()
            }
            
            alertController.addAction(confirmAction)
        }
        else {
        
            alertController = UIAlertController(
                title: "Error",
                message: "There is no saved setting!",
                preferredStyle: .alert)
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel", style: .cancel) {(_) in }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func returnToTitle(_ sender: UIButton) {
        backupCurrentSetting()
    }
    
    
    
    func checkLoadList() {
        
        if(array_picker.count == 0) {
            pbLoadOther.isEnabled = false;
            pbLoadOther.setTitleColor(.lightGray, for: .normal)
        }
        else {
            pbLoadOther.isEnabled = true;
            pbLoadOther.setTitleColor(.white, for: .normal)
        }
        
    }
    
    func checkCurrentPB()
    {
        if(currentSetting == nil){
            pbSaveToCurrent.isEnabled = false;
            pbDeleteCurrent.isEnabled = false;
            
            pbSaveToCurrent.setTitleColor(.lightGray, for: .normal)
            pbDeleteCurrent.setTitleColor(.lightGray, for: .normal)
        }
        else{
            pbSaveToCurrent.isEnabled = true;
            pbDeleteCurrent.isEnabled = true;
            
            pbSaveToCurrent.setTitleColor(.white, for: .normal)
            pbDeleteCurrent.setTitleColor(.white, for: .normal)
        }
    }
    
    
    
    @IBAction func updateVolume(_ sender: UIButton) {
        
        updatePlayerVolume()
    }
    
    @IBAction func loadDefaultPrLv(_ sender: UIButton) {
        
        for i in 0..<array_freq.count {
            
            array_tbPresentDBHL[i].text = String(DB_DEFAULT)
        }
    }
    
    @IBAction func clearMeasuredLv(_ sender: UIButton) {
        
        for i in 0..<array_freq.count {
            
            array_tbMeasuredDBSPL[i * 2].text = ""
            array_tbMeasuredDBSPL[i * 2 + 1].text = ""
        }
    }
    
    
    
    
    @IBAction func playSignal(_ sender: UIButton) {
        // No tone playing at all, simply toggle on
        if(!generator.isStarted){
            
            currentIndex = array_pbPlay.index(of: sender)!
            array_pbPlay[currentIndex].setTitle("On", for: .normal)
            
            generator.start()
            
            // Update freq & vol
            generator.parameters[0] = array_freq[currentIndex]
            updatePlayerVolume()
            
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
            generator.parameters[0] = array_freq[currentIndex]
            updatePlayerVolume()
            
            array_pbPlay[currentIndex].setTitle("On", for: .normal)
        }
    }
    
    //*******************
    // Support functions
    //*******************
    
    //Calls this function when the tap is recognized to clear keyboard
    @objc func dismissKeyboard() {
        
        //Causes the view (or one of its embedded text fields)
        //to resign the first responder status.
        view.endEditing(true)
    }
    
    // Volume & Player
    //
    // Covert dB to amplitude in double (0.0 to 1.0 range)
    func dbToAmp (_ dB: Double!) -> Double{
        
        // volume in absolute dB to be converted to amplitude
        // 1.0 amplitude <-> 0 absoulte dB
        let ampDB: Double = dB - DB_SYSTEM_MAX
        
        let amp: Double = pow(10.0, ampDB / 20.0)
        
        print(amp)
        return ((amp > 1) ? 1 : amp)
    }
    
    // Update volume to currently playing frequency tone
    func updatePlayerVolume()
    {
        // skip if not playing currently
        if(!generator.isStarted || (currentIndex == -1)){
            return
        }
        
        // retrieve vol
        let expectedTxt: String = array_tbExpectedDBSPL[currentIndex].text!
        let presentTxt: String = array_tbPresentDBHL[currentIndex].text!
        
        let leftMeasuredTxt: String =
            array_tbMeasuredDBSPL[currentIndex * 2].text!
        let rightMeasuredTxt: String =
            array_tbMeasuredDBSPL[currentIndex * 2 + 1].text!
        
        let expectedDBSPL: Double! = Double(expectedTxt) ?? 0.0
        let presentDBHL: Double! = Double(presentTxt) ?? 0.0
        
        let leftMeasuredDBSPL: Double! =
            Double(leftMeasuredTxt) ?? expectedDBSPL
        let rightMeasuredDBSPL: Double! =
            Double(rightMeasuredTxt) ?? expectedDBSPL
        
        let leftCorrectionFactor: Double! = expectedDBSPL - leftMeasuredDBSPL
        let rightCorrectionFactor: Double! = expectedDBSPL - rightMeasuredDBSPL
        
        for i in stride(from: 0.0, through: 1.0, by: RAMP_TIMESTEP){
//            print(String(i))
            DispatchQueue.main.asyncAfter(
                deadline: .now() + i * RAMP_TIME, execute:
            {
                self.generator.parameters[1] = self.dbToAmp(
                    (presentDBHL! + leftCorrectionFactor!) * i)
                self.generator.parameters[2] = self.dbToAmp(
                    (presentDBHL! + rightCorrectionFactor!) * i)
            })
        }
    }
    
    func setupAudioPlayer(){
        //*******************
        // Setup oscillator player which generates pure tones
        //*******************
        
        // generator to be configured by setting generator.parameters
        generator = AKOperationGenerator(numberOfChannels: 2) {
            
            parameters in
            
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
        setupStackview(svExpectedDBSPL)
        setupStackview(svPresentDBHL)
        setupStackview(svLeftMeasuredDBSPL)
        setupStackview(svRightMeasuredDBSPL)
        
        //Creating play buttons for each respective freq
        for i in 0..<array_freq.count {
            
            // Add frequency labels to svLabels
            let new_lbFreq = UILabel()
            new_lbFreq.text = String(array_freq[i])
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
            new_pbPlay.addTarget(self, action: #selector(playSignal(_:)),
                                 for: .touchUpInside)
            new_pbPlay.titleEdgeInsets = UIEdgeInsets(
                top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
            
            // Add the button to our current button array
            array_pbPlay += [new_pbPlay]
            svButtons.addArrangedSubview(new_pbPlay)
            
            // Add textboxes to sv70dBHL
            let new_tbExpectedSPL = UITextField()
            new_tbExpectedSPL.borderStyle = .roundedRect
            new_tbExpectedSPL.textAlignment = .center
            new_tbExpectedSPL.keyboardType = UIKeyboardType.decimalPad
            
            array_tbExpectedDBSPL += [new_tbExpectedSPL]
            svExpectedDBSPL.addArrangedSubview(new_tbExpectedSPL)
            
            // Add textboxes to svPresentLv for volume input in dB
            let new_tbPresentDBHL = UITextField()
            new_tbPresentDBHL.borderStyle = .roundedRect
            new_tbPresentDBHL.textAlignment = .center
            new_tbPresentDBHL.keyboardType = UIKeyboardType.decimalPad
            new_tbPresentDBHL.text = String(DB_DEFAULT)
            
            array_tbPresentDBHL += [new_tbPresentDBHL]
            svPresentDBHL.addArrangedSubview(new_tbPresentDBHL)
            
            // Add textboxes to svMeasuredLV for volume input in dB
            let new_tbLeftMeasureDBSPL = UITextField()
            new_tbLeftMeasureDBSPL.borderStyle = .roundedRect
            new_tbLeftMeasureDBSPL.textAlignment = .center
            new_tbLeftMeasureDBSPL.keyboardType = UIKeyboardType.decimalPad
            
            array_tbMeasuredDBSPL += [new_tbLeftMeasureDBSPL]
            svLeftMeasuredDBSPL.addArrangedSubview(new_tbLeftMeasureDBSPL)
            
            let new_tbRightMeasureDBSPL = UITextField()
            new_tbRightMeasureDBSPL.borderStyle = .roundedRect
            new_tbRightMeasureDBSPL.textAlignment = .center
            new_tbRightMeasureDBSPL.keyboardType = UIKeyboardType.decimalPad
            
            array_tbMeasuredDBSPL += [new_tbRightMeasureDBSPL]
            svRightMeasuredDBSPL.addArrangedSubview(new_tbRightMeasureDBSPL)
        }

    }
    
    // Init' function
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        array_freq = UserDefaults.standard.array(forKey: "freqArray") as! [Double]!
            ?? [Double]()
        
        setupAudioPlayer()
        
        setupMainStackview()
        
        // Reload previous setting
        currentSetting = UserDefaults.standard.string(forKey: "currentSetting")
            ?? nil
        
        // Load setting List
        array_picker = UserDefaults.standard.array(forKey: "settingList")
            as! [String]! ?? [String]()
        
        if(currentSetting != nil) {
            loadSetting(currentSetting)
        }
        
        
        
        checkCurrentPB()
        
        checkLoadList()
        
        //*******************
        // Hides keyboard on tap
        //*******************
        
        let tap: UITapGestureRecognizer =
            UITapGestureRecognizer(
                target: self,
                action: #selector(CalibrationViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap 
        //not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(backupCurrentSetting),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(backupCurrentSetting),
            name: NSNotification.Name.UIApplicationWillTerminate,
            object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CalibrationViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return array_picker.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return array_picker[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        
        currentSelection = array_picker[row]
        
//        pbLoad.setTitle(currentSetting, for: .normal)
    }
}

