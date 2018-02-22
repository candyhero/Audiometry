//
//  CalibrationViewController
//  Audiometry
//
//  Created by Xavier Chan on 7/21/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import UIKit

class CalibrationViewController: UIViewController {
    
    private var _currentPickerIndex: Int! = -1
    
    @IBOutlet weak var pbSetCurrentVol: UIButton!
    @IBOutlet weak var pbLoadDefaultPresentLv: UIButton!
    @IBOutlet weak var pbClearMesauredLv: UIButton!
    
    @IBOutlet weak var pbSaveAs: UIButton!
    @IBOutlet weak var pbSaveToCurrent: UIButton!
    @IBOutlet weak var pbLoadOther: UIButton!
    @IBOutlet weak var pbDeleteCurrent: UIButton!
    
    @IBOutlet weak var lbCurrentSetting: UILabel!
    static var currentSettingName = ""
    
    private var calibrationModel: CalibrationModel! = nil
    private var mainSetting: MainSetting! = nil
    
    static var array_pbPlay = [UIButton]()
    static var array_tbExpectedDBSPL = [UITextField]()
    static var array_tbPresentDBHL = [UITextField]()
    static var array_tbMeasuredDBSPL_L = [UITextField]()
    static var array_tbMeasuredDBSPL_R = [UITextField]()
    
    @IBOutlet weak var svLabels: UIStackView!
    @IBOutlet weak var svButtons: UIStackView!
    @IBOutlet weak var svExpectedDBSPL: UIStackView!
    @IBOutlet weak var svPresentDBHL: UIStackView!
    @IBOutlet weak var svMeasuredDBSPL_L: UIStackView!
    @IBOutlet weak var svMeasuredDBSPL_R: UIStackView!
    
    //*******************
    // IBActions & their sub-functions
    //*******************
    @IBAction func saveAs(_ sender: UIButton) {
        
        inputPrompt(promptMsg: "Please enter setting name:",
                    errorMsg: "Setting name cannot be empty!",
                    fieldMsg: "i.e. iPad1-EP1",
                    confirmFunction: saveSetting,
                    uiCtrl: self)
    }
    
    func saveSetting(_ newSettingName: String){
        
        if(!calibrationModel.isSettingExisted(newSettingName) ){
            // Init new setting in realm
            calibrationModel.updateSetting(newSettingName)
            lbCurrentSetting.text = CalibrationViewController.currentSettingName
            // make sure load setting is enabled
            checkCurrentPB()
            checkLoadList()
        }
        else { // Prompt for user error for duplicated setting name
            errorPrompt(errorMsg: "Calibration setting name already exists!",
                        uiCtrl: self)
        }
    }
    
    @IBAction func saveToCurrent(_ sender: UIButton) {
        
        calibrationModel.updateSetting(
            CalibrationViewController.currentSettingName)
        
        // make sure load setting is enabled
        checkCurrentPB()
        checkLoadList()
    }
    
    @IBAction func deleteCurrent(_ sender: UIButton) {
        
        calibrationModel.deleteCurrentSetting()
        lbCurrentSetting.text = "None"
        
        checkCurrentPB()
        checkLoadList()
    }
    
    @IBAction func loadOther(_ sender: UIButton) {
        
        _currentPickerIndex = 0
        
        pickerPrompt(confirmFunction: {()->Void in
            self.calibrationModel.loadSetting(self._currentPickerIndex)
            self.lbCurrentSetting.text = CalibrationViewController.currentSettingName
            
            self.checkCurrentPB()
        },
            uiCtrl: self)
        
    }
    
    @IBAction func playSignal(_ sender: UIButton) {
    
        let newPlayIndex = sender.tag
        
        calibrationModel.playSingal(newPlayIndex)
    }
    
    // ******
    //  Refresh UI
    // ******
    func checkLoadList() {
        if(mainSetting.array_calibrationSettings.count == 0) {
            pbLoadOther.isEnabled = false;
            pbLoadOther.setTitleColor(.lightGray, for: .normal)
        }
        else {
            pbLoadOther.isEnabled = true;
            pbLoadOther.setTitleColor(.white, for: .normal)
        }
    }
    
    func checkCurrentPB(){
        if(mainSetting.calibrationSettingIndex < 0){
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
    
    
    //*******************
    // Setup oscillator player which generates pure tones
    //*******************
    @IBAction func updateVolume(_ sender: UIButton) {
        
        calibrationModel.updatePlayerVolume()
    }
    
    
    //*******************
    // Setup the main stackview that holds the main UI elements
    //*******************
    
    func setupStackview(_ sv: UIStackView!){
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .center
        sv.spacing = 20
    }
    
    func setupMainStackview(){
        
        // Config stackviews
        setupStackview(svLabels)
        setupStackview(svButtons)
        setupStackview(svExpectedDBSPL)
        setupStackview(svPresentDBHL)
        setupStackview(svMeasuredDBSPL_L)
        setupStackview(svMeasuredDBSPL_R)
        
        CalibrationViewController.array_pbPlay.removeAll()
        CalibrationViewController.array_tbExpectedDBSPL.removeAll()
        CalibrationViewController.array_tbPresentDBHL.removeAll()
        CalibrationViewController.array_tbMeasuredDBSPL_L.removeAll()
        CalibrationViewController.array_tbMeasuredDBSPL_R.removeAll()
        
        //Creating play buttons for each respective freq
        for i in 0..<ARRAY_DEFAULT_FREQ.count {
            
            // Add frequency labels to svLabels
            let new_lbFreq = UILabel()
            new_lbFreq.text = String(ARRAY_DEFAULT_FREQ[i])
            new_lbFreq.textAlignment = .center
            
            svLabels.addArrangedSubview(new_lbFreq)
            
            // Add buttons to svButtons
            let new_pbPlay = UIButton(type:.system)
            
            new_pbPlay.bounds = CGRect(x:0, y:0, width:300, height:300)
            new_pbPlay.setTitle("Off", for: .normal)
            new_pbPlay.backgroundColor = UIColor.gray
            new_pbPlay.setTitleColor(UIColor.white, for: .normal)
            new_pbPlay.tag = i
            
            // Binding an action function to the new button
            // i.e. to play signal
            new_pbPlay.addTarget(self, action: #selector(playSignal(_:)),
                                 for: .touchUpInside)
            new_pbPlay.titleEdgeInsets = UIEdgeInsets(
                top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
            
            // Add the button to our current button array
            CalibrationViewController.array_pbPlay += [new_pbPlay]
            svButtons.addArrangedSubview(new_pbPlay)
            
            // Add textboxes to sv70dBHL
            let new_tbExpectedSPL = UITextField()
            new_tbExpectedSPL.borderStyle = .roundedRect
            new_tbExpectedSPL.textAlignment = .center
            new_tbExpectedSPL.keyboardType = UIKeyboardType.decimalPad
            
            CalibrationViewController.array_tbExpectedDBSPL.append(new_tbExpectedSPL)
            svExpectedDBSPL.addArrangedSubview(new_tbExpectedSPL)
            
            // Add textboxes to svPresentLv for volume input in dB
            let new_tbPresentDBHL = UITextField()
            new_tbPresentDBHL.borderStyle = .roundedRect
            new_tbPresentDBHL.textAlignment = .center
            new_tbPresentDBHL.keyboardType = UIKeyboardType.decimalPad
            
            CalibrationViewController.array_tbPresentDBHL.append(new_tbPresentDBHL)
            svPresentDBHL.addArrangedSubview(new_tbPresentDBHL)
            
            // Add textboxes to svMeasuredLV for volume input in dB
            let new_tbMeasureDBSPL_L = UITextField()
            new_tbMeasureDBSPL_L.borderStyle = .roundedRect
            new_tbMeasureDBSPL_L.textAlignment = .center
            new_tbMeasureDBSPL_L.keyboardType = UIKeyboardType.decimalPad
            
            CalibrationViewController.array_tbMeasuredDBSPL_L.append(new_tbMeasureDBSPL_L)
            svMeasuredDBSPL_L.addArrangedSubview(new_tbMeasureDBSPL_L)
            
            let new_tbMeasureDBSPL_R = UITextField()
            new_tbMeasureDBSPL_R.borderStyle = .roundedRect
            new_tbMeasureDBSPL_R.textAlignment = .center
            new_tbMeasureDBSPL_R.keyboardType = UIKeyboardType.decimalPad
            
            CalibrationViewController.array_tbMeasuredDBSPL_R.append(new_tbMeasureDBSPL_R)
            svMeasuredDBSPL_R.addArrangedSubview(new_tbMeasureDBSPL_R)
        }
    }
    
    @IBAction func loadDefaultPrLv(_ sender: UIButton) {
        
        for i in 0..<ARRAY_DEFAULT_FREQ.count {
            
            CalibrationViewController.array_tbPresentDBHL[i].text = String(_DB_DEFAULT)
        }
    }
    
    @IBAction func clearMeasuredLv(_ sender: UIButton) {
        
        for i in 0..<ARRAY_DEFAULT_FREQ.count {
            
            CalibrationViewController.array_tbMeasuredDBSPL_L[i].text = ""
            CalibrationViewController.array_tbMeasuredDBSPL_R[i].text = ""
        }
    }
    
    //*******************
    // Support functions
    //*******************
    // Init' function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainStackview()
        
        calibrationModel = CalibrationModel()
        mainSetting = calibrationModel.getMainSetting()
        
        let currentSettingID = mainSetting.calibrationSettingIndex
        
        if(mainSetting.calibrationSettingIndex >= 0){
            lbCurrentSetting.text = mainSetting.array_calibrationSettings[currentSettingID].name
            calibrationModel.loadSetting(mainSetting.calibrationSettingIndex)
        }
        
        // Refresh UI
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
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Calls this function when the tap is recognized to clear keyboard
    @objc func dismissKeyboard() {
        
        //Causes the view (or one of its embedded text fields)
        //to resign the first responder status.
        view.endEditing(true)
    }
}

// Extension for picker view setting
extension CalibrationViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return (mainSetting?.array_calibrationSettings.count)!
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return mainSetting?.array_calibrationSettings[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        
        _currentPickerIndex = row
    }
}
