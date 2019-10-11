
import UIKit

class AdultTestViewController: UIViewController {
    
//------------------------------------------------------------------------------
// Local Variables
//------------------------------------------------------------------------------
    private var _testModel = TestModel()
    
    // Used by animator
    private var timer, firstTimer, secondTimer: Timer?
    private var pulseCounter: Int!
    
    private var buttonCounter: Int!
    private var pbLastClicked: UIButton!
    
    @IBOutlet private weak var svIcons: UIStackView!
    
    @IBOutlet private weak var pbFirstInterval: UIButton!
    @IBOutlet private weak var pbSecondInterval: UIButton!
    @IBOutlet private weak var pbNoSound: UIButton!
    
    @IBOutlet private weak var pbRepeat: UIButton!
    @IBOutlet private weak var pbPause: UIButton!
    
    @IBOutlet weak var lbInstruction: UILabel!
    @IBOutlet weak var lbProgress: UILabel!
//------------------------------------------------------------------------------
// Main Flow
//------------------------------------------------------------------------------
    private func loadButtonUI() {
        let freq: Int = _testModel.getNewTestFreq()
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
    
    private func testNewFreq(){
        pulseCounter = 0
        buttonCounter = 0
        
        // Setup UI for next freq
        DispatchQueue.main.async { [unowned self] in
            // Loading Progress Caption
            let currentProgress: Int = self._testModel.getCurrentProgress()
            self.lbProgress.text = "Test Progress: \(currentProgress)%"
            
            self.loadButtonUI()
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
            self._testModel.playSignalCase()
            self.pulseAnimation(0)
        }
    }
    
//------------------------------------------------------------------------------
// UI Functions
//------------------------------------------------------------------------------
    @IBAction private func repeatPlaying(_ sender: UIButton) {
        pulseToggle(isPlaying: true)
        pulseAnimation(0)
        _testModel.replaySignalCase()
    }
    
    @IBAction private func pausePlaying(_ sender: UIButton) {
        toggleButtons(toggle: false)
        pulseToggle(isPlaying: false)
        
        firstTimer?.invalidate()
        secondTimer?.invalidate()
        timer?.invalidate()
        pulseCounter = 0
        _testModel.pausePlaying()
    }

//------------------------------------------------------------------------------
// Test Functions
//------------------------------------------------------------------------------
    @IBAction private func checkResponse(_ sender: UIButton) {
        pausePlaying(sender)
        
        //Check if same button 5 times in a row
        if(sender == pbLastClicked ?? nil){
            buttonCounter += 1
        }
        else {
            buttonCounter = 0
        }
        
        if(buttonCounter >= 4){
            buttonCounter = 0
            _testModel.increaseSpamCount()
            
            errorPrompt(
                errorMsg: "Please ask for re-instrcution.",
                uiCtrl: self)
        }
        
//        print("Button Spam Count: ", buttonCounter)
        pbLastClicked = sender
        
        // DispatchQueue default **
        // Compare test blah
        let currentPlaycase: Int! = _testModel.getCurrentPlayCase()
        
        // determine next volume level
        var isThresholdFound: Bool!
        
        switch currentPlaycase {
        case 0: // Slient interval
            isThresholdFound = _testModel.checkNoSound(sender == pbNoSound)
            break
        case 1: // First interval
            isThresholdFound = _testModel.checkThreshold(sender == pbFirstInterval)
            break
        case 2: // Second interval
            isThresholdFound = _testModel.checkThreshold(sender == pbSecondInterval)
            break
        default:
            break
        }
        
        if(isThresholdFound){ // Done for this freq
//            print("Next Freq: ", _testModel.getNewTestFreq())
            if(_testModel.getNewTestFreq() < 0) {
                print("Switching to the other ear")
                _testModel.terminatePlayer()
                performSegue(withIdentifier: "segueSwitchEar", sender: nil)
            } else if(_testModel.getNewTestFreq() == 0){
                // Already tested both ears
                _testModel.terminatePlayer()
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
    
    private func loadPortuguse(){
        lbInstruction.text = PORT_ADULT_INSTRCUTION_TEXT
        pbNoSound.setBackgroundImage(UIImage(named: "Animal_Icons/no_sound_Port"), for: .normal)
        pbNoSound.setTitle("", for: .normal)
        pbPause.setTitle(PORT_PAUSE_TEXT, for: .normal)
        pbRepeat.setTitle(PORT_REPEAT_TEXT, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set UI
        pbNoSound.setBackgroundImage(UIImage(named: "Shape_Icons/no_sound"), for: .normal)
        pbNoSound.adjustsImageWhenHighlighted = false
        
        switch _testModel.getTestLauguage(){
        case "Invalid":
            print("Invalid language option!!")
            break
        case "Portuguese":
            print("Loading Portugese...")
            loadPortuguse()
            break
        default:
            break
        }
        
        toggleButtons(toggle: false)
        testNewFreq()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
