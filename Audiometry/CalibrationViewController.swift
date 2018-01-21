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
    private let _DB_SYSTEM_MAX: Double! = 105.0 // At volume amplitude = 1.0
    private let _DB_DEFAULT: Double! = 70.0
    private let _RAMP_TIME: Double! = 0.1
    private let _RAMP_TIMESTEP: Double! = 0.01
    
    //*******************
    // Variables
    //*******************
    
    private var _array_freq: [Double]!
    private var _array_picker: [String]!
    
    private var _array_pbPlay = [UIButton]()
    private var _array_tbExpectedDBSPL = [UITextField]()
    private var _array_tbPresentDBHL = [UITextField]()
    private var _array_tbMeasuredDBSPL = [UITextField]()
    
    private var _currentSetting: String!
    private var _currentSelection: String!
    private var _currentIndex: Int! = -1
    
    private var _generator: AKOperationGenerator! = nil
    
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
        
        self.saveSetting(_currentSetting)
    }
    
    
    // Save and Load
    //
    func saveSetting(_ settingKey: String){
        
        // Create a dictionary to map all settings
        // with their corresponding freqs
        var newSetting = [String: [String]]()
        
        for i in 0..<_array_freq.count {
            
            // Put the strings in to a string array
            var _array_db = [String]()
            
            _array_db.append(_array_tbExpectedDBSPL[i].text!)
            _array_db.append(_array_tbPresentDBHL[i].text!)
            _array_db.append(_array_tbMeasuredDBSPL[i * 2].text!)
            _array_db.append(_array_tbMeasuredDBSPL[i * 2 + 1].text!)
            
            // Map volume (dB) string array to their respective frequencies
            let freqKey: String = String(_array_freq[i])
            newSetting[freqKey] = _array_db
        }
        
        // Store the setting dictionary into user defaults
        UserDefaults.standard.set(newSetting, forKey: settingKey)
        
        // Update setting list if this is a new setting
        if(!_array_picker.contains(settingKey)){
            _array_picker.append(settingKey)
            UserDefaults.standard.set(_array_picker, forKey: "settingList")
        }
        
        // Update current setting string
        _currentSetting = settingKey
        backupCurrentSetting()
        lbCurrentSetting.text = _currentSetting
    }
    
    @IBAction func deleteCurrent(_ sender: UIButton) {
        
        // Find the setting from the setting list
        if let index = _array_picker.index(where: {$0 == _currentSetting}) {
            
            // If found
            // Remove the setting name from the setting list
            _array_picker.remove(at: index)
            UserDefaults.standard.set(_array_picker, forKey: "settingList")
            
            // Remove the setting object from UserDefaults.standard
            UserDefaults.standard.removeObject(forKey: _currentSetting)
            
            _currentSetting = nil
            backupCurrentSetting()
            lbCurrentSetting.text = "None"
            
            checkCurrentPB()
            checkLoadList()
        }
    }
    
    func loadSetting(_ settingKey: String){
        
        var setting = UserDefaults.standard.dictionary(forKey: settingKey)!
        
        for i in 0..<_array_freq.count {
            
            // Retrieve saved volume strings by trying every key (freq)
            let freqKey: String = String(_array_freq[i])
            var _array_db = setting[freqKey] as! [String]! ?? nil
            
            if(_array_db != nil){
                
                _array_tbExpectedDBSPL[i].text = _array_db?[0] ?? nil
                _array_tbPresentDBHL[i].text = _array_db?[1] ?? nil
                _array_tbMeasuredDBSPL[i * 2].text = _array_db?[2] ?? nil
                _array_tbMeasuredDBSPL[i * 2 + 1].text = _array_db?[3] ?? nil
            }
        }
        
        _currentSetting = settingKey
        backupCurrentSetting()
        lbCurrentSetting.text = _currentSetting
    }
    
    @objc func backupCurrentSetting() {
        UserDefaults.standard.set(_currentSetting, forKey: "currentSetting")
    }
    
    @IBAction func loadOther(_ sender: UIButton) {
        
        let settingList = UserDefaults.standard.array(forKey: "settingList")
            as! [String]! ?? nil
        let alertController: UIAlertController!
        
        if settingList != nil && settingList!.count > 0 {
            
            _currentSelection = _array_picker[0]
            
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
                
                self.loadSetting(self._currentSelection)
                    
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
        
        if(_array_picker.count == 0) {
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
        if(_currentSetting == nil){
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
        
        for i in 0..<_array_freq.count {
            
            _array_tbPresentDBHL[i].text = String(_DB_DEFAULT)
        }
    }
    
    @IBAction func clearMeasuredLv(_ sender: UIButton) {
        
        for i in 0..<_array_freq.count {
            
            _array_tbMeasuredDBSPL[i * 2].text = ""
            _array_tbMeasuredDBSPL[i * 2 + 1].text = ""
        }
    }
    
    @IBAction func playSignal(_ sender: UIButton) {
        // No tone playing at all, simply toggle on
        if(!_generator.isStarted){
            
            _currentIndex = _array_pbPlay.index(of: sender)!
            _array_pbPlay[_currentIndex].setTitle("On", for: .normal)
            
            _generator.start()
            
            // Update freq & vol
            _generator.parameters[0] = _array_freq[_currentIndex]
            updatePlayerVolume()
        }
        // Same tone, toggle it off
        else if(_array_pbPlay[_currentIndex] == sender){
            
            _array_pbPlay[_currentIndex].setTitle("Off", for: .normal)
            _currentIndex = -1
            
            _generator.stop()
        }
        // Else tone, switch frequency
        else {
            
            let senderIndex = _array_pbPlay.index(of: sender)!
            
            _array_pbPlay[_currentIndex].setTitle("Off", for: .normal)
            _currentIndex = senderIndex
            
            // Update freq & vol
            _generator.parameters[0] = _array_freq[_currentIndex]
            updatePlayerVolume()
            
            _array_pbPlay[_currentIndex].setTitle("On", for: .normal)
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
        let ampDB: Double = dB - _DB_SYSTEM_MAX
        
        let amp: Double = pow(10.0, ampDB / 20.0)
        
//        print(amp)
        return ((amp > 1) ? 1 : amp)
    }
    
    // Update volume to currently playing frequency tone
    func updatePlayerVolume()
    {
        // skip if not playing currently
        if(!_generator.isStarted || (_currentIndex == -1)){
            return
        }
        
        // retrieve vol
        let expectedTxt: String = _array_tbExpectedDBSPL[_currentIndex].text!
        let presentTxt: String = _array_tbPresentDBHL[_currentIndex].text!
        
        let leftMeasuredTxt: String =
            _array_tbMeasuredDBSPL[_currentIndex * 2].text!
        let rightMeasuredTxt: String =
            _array_tbMeasuredDBSPL[_currentIndex * 2 + 1].text!
        
        let expectedDBSPL: Double! = Double(expectedTxt) ?? 0.0
        let presentDBHL: Double! = Double(presentTxt) ?? 0.0
        
        let leftMeasuredDBSPL: Double! =
            Double(leftMeasuredTxt) ?? expectedDBSPL
        let rightMeasuredDBSPL: Double! =
            Double(rightMeasuredTxt) ?? expectedDBSPL
        
        let leftCorrectionFactor: Double! = expectedDBSPL - leftMeasuredDBSPL
        let rightCorrectionFactor: Double! = expectedDBSPL - rightMeasuredDBSPL
        
        for i in stride(from: 0.0, through: 1.0, by: _RAMP_TIMESTEP){

            DispatchQueue.main.asyncAfter(
                deadline: .now() + i * _RAMP_TIME, execute:
            {
                self._generator.parameters[1] = self.dbToAmp(
                    (presentDBHL! + leftCorrectionFactor!) * i)
                self._generator.parameters[2] = self.dbToAmp(
                    (presentDBHL! + rightCorrectionFactor!) * i)
            })
        }
    }
    
    func setupAudioPlayer(){
        //*******************
        // Setup oscillator player which generates pure tones
        //*******************
        
        // _generator to be configured by setting _generator.parameters
        _generator = AKOperationGenerator(numberOfChannels: 2) {
            
            parameters in
            
            let leftOutput = AKOperation.sineWave(frequency: parameters[0],
                                                  amplitude: parameters[1])
            let rightOutput = AKOperation.sineWave(frequency: parameters[0],
                                                   amplitude: parameters[2])
            
            return [leftOutput, rightOutput]
        }
        
        AudioKit.output = _generator
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
        for i in 0..<_array_freq.count {
            
            // Add frequency labels to svLabels
            let new_lbFreq = UILabel()
            new_lbFreq.text = String(_array_freq[i])
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
            _array_pbPlay += [new_pbPlay]
            svButtons.addArrangedSubview(new_pbPlay)
            
            // Add textboxes to sv70dBHL
            let new_tbExpectedSPL = UITextField()
            new_tbExpectedSPL.borderStyle = .roundedRect
            new_tbExpectedSPL.textAlignment = .center
            new_tbExpectedSPL.keyboardType = UIKeyboardType.decimalPad
            
            _array_tbExpectedDBSPL += [new_tbExpectedSPL]
            svExpectedDBSPL.addArrangedSubview(new_tbExpectedSPL)
            
            // Add textboxes to svPresentLv for volume input in dB
            let new_tbPresentDBHL = UITextField()
            new_tbPresentDBHL.borderStyle = .roundedRect
            new_tbPresentDBHL.textAlignment = .center
            new_tbPresentDBHL.keyboardType = UIKeyboardType.decimalPad
            new_tbPresentDBHL.text = String(_DB_DEFAULT)
            
            _array_tbPresentDBHL += [new_tbPresentDBHL]
            svPresentDBHL.addArrangedSubview(new_tbPresentDBHL)
            
            // Add textboxes to svMeasuredLV for volume input in dB
            let new_tbLeftMeasureDBSPL = UITextField()
            new_tbLeftMeasureDBSPL.borderStyle = .roundedRect
            new_tbLeftMeasureDBSPL.textAlignment = .center
            new_tbLeftMeasureDBSPL.keyboardType = UIKeyboardType.decimalPad
            
            _array_tbMeasuredDBSPL += [new_tbLeftMeasureDBSPL]
            svLeftMeasuredDBSPL.addArrangedSubview(new_tbLeftMeasureDBSPL)
            
            let new_tbRightMeasureDBSPL = UITextField()
            new_tbRightMeasureDBSPL.borderStyle = .roundedRect
            new_tbRightMeasureDBSPL.textAlignment = .center
            new_tbRightMeasureDBSPL.keyboardType = UIKeyboardType.decimalPad
            
            _array_tbMeasuredDBSPL += [new_tbRightMeasureDBSPL]
            svRightMeasuredDBSPL.addArrangedSubview(new_tbRightMeasureDBSPL)
        }

    }
    
    // Init' function
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Load frequencies
        _array_freq = ARRAY_FREQ
        
        setupAudioPlayer()
        
        setupMainStackview()
        
        // Reload previous setting
        _currentSetting = UserDefaults.standard.string(forKey: "currentSetting")
            ?? nil
        
        // Load setting List
        _array_picker = UserDefaults.standard.array(forKey: "settingList")
            as! [String]! ?? [String]()
        
        if(_currentSetting != nil) {
            loadSetting(_currentSetting)
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
        return _array_picker.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return _array_picker[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        
        _currentSelection = _array_picker[row]
    }
}

