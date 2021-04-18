
import UIKit

class ChildrenTestViewController: UIViewController {
    
//------------------------------------------------------------------------------
// Local Variables
//------------------------------------------------------------------------------
    private var _testModel = TestModel()
    
    // Used by animator
    private var _timer, _firstTimer, _secondTimer: Timer?
    private var _pulseCounter: Int!
    
    private var _sameSelectionCounter: Int!
    private var _lastSelection: UIButton!
    
    @IBOutlet weak var pbReturnToTitle: UIButton!
    @IBOutlet weak var pbRepeat: UIButton!
    @IBOutlet weak var pbPause: UIButton!
    
    @IBOutlet weak var pbFirstInterval: UIButton!
    @IBOutlet weak var pbSecondInterval: UIButton!
    @IBOutlet weak var pbNoSound: UIButton!
    
    @IBOutlet weak var lbProgress: UILabel!
    
    @IBOutlet weak var svIcons: UIStackView!
//------------------------------------------------------------------------------
// Main Flow
//------------------------------------------------------------------------------
    private func testNewFrequency(){
        _pulseCounter = 0
        _sameSelectionCounter = 0
        
        // Setup UI for next freq
        DispatchQueue.main.async { [unowned self] in
            self.reloadTestProgress()
            self.reloadButtonImage()
        }

        // run test
        pulseToggle(isPlaying: true)
        _timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(testNextDB),
                                     userInfo: nil,
                                     repeats: false)
    }

    private func reloadTestProgress() {
        // Loading Progress Caption
        let currentProgress: Int = _testModel.getCurrentProgress()
        lbProgress.text = "Test Progress: \(currentProgress)%"
    }
    
    private func reloadButtonImage() {
        let testFrequency: Int = _testModel.getNewTestFrequency()
        let imagePath = "Animal_Icons/\(testFrequency)Hz"
        let image = UIImage(named:imagePath)?.withRenderingMode(.alwaysOriginal)
        
        print(testFrequency, imagePath)
        
        pbFirstInterval.imageView?.contentMode = .scaleAspectFit
        pbSecondInterval.imageView?.contentMode = .scaleAspectFit
        
        pbFirstInterval.setImage(image, for: .normal)
        pbSecondInterval.setImage(image, for: .normal)
        
        pbFirstInterval.adjustsImageWhenHighlighted = false
        pbSecondInterval.adjustsImageWhenHighlighted = false
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
        setButtonToggle(toggle: false)
        pulseToggle(isPlaying: false)
        
        _firstTimer?.invalidate()
        _secondTimer?.invalidate()
        _timer?.invalidate()
        _pulseCounter = 0
        _testModel.pausePlaying()
    }
    
    @IBAction func returnToTitle(_ sender: Any) {
        _testModel.pausePlaying()
        performSegue(withIdentifier: "segueTitleFromChildrenTest", sender: nil)
    }
    
//------------------------------------------------------------------------------
// Test Functions
//------------------------------------------------------------------------------
    @IBAction private func checkResponse(_ sender: UIButton) {
        pausePlaying(sender)
        
        //Check if same button 5 times in a row
        if(sender == _lastSelection ?? nil){
            _sameSelectionCounter += 1
        }
        else {
            _sameSelectionCounter = 0
        }
        
        if(_sameSelectionCounter >= 4){
            _sameSelectionCounter = 0
            _testModel.increaseSpamCount()
            
            errorPrompt(
                errorMsg: "Please ask for re-instrcution.",
                uiCtrl: self)
        }
        
//        print("Button Spam Count: ", buttonCounter)
        _lastSelection = sender
        
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
            if(_testModel.getNewTestFrequency() < 0) {
                print("Switching to the other ear")
                _testModel.terminatePlayer()
                performSegue(withIdentifier: "segueSwitchEar", sender: nil)
            } else if(_testModel.getNewTestFrequency() == 0){
                // Already tested both ears
                _testModel.terminatePlayer()
                performSegue(withIdentifier: "segueResult", sender: nil)
            } else {
                testNewFrequency()
            }
            return
        }
        
        // Still testing this frequency
        pulseToggle(isPlaying: true)
        _timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(testNextDB),
                                     userInfo: nil,
                                     repeats: false)
    }
    
//------------------------------------------------------------------------------
// Animation Functions
//------------------------------------------------------------------------------
    private func setButtonToggle(toggle: Bool!) {
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
        _firstTimer = Timer.scheduledTimer(timeInterval: delay,
                                          target: self,
                                          selector: #selector(self.pulseFirstInterval),
                                          userInfo: nil,
                                          repeats: false)
        
        let firstDuration = PULSE_TIME_CHILDREN * Double(NUM_OF_PULSE_CHILDREN) + PLAY_GAP_TIME
        _secondTimer = Timer.scheduledTimer(timeInterval: delay + firstDuration,
                                           target: self,
                                           selector: #selector(self.pulseSecondInterval),
                                           userInfo: nil,
                                           repeats: false)
        
        let totalDuration = PULSE_TIME_CHILDREN * Double(NUM_OF_PULSE_CHILDREN * 2) + PLAY_GAP_TIME
        _timer = Timer.scheduledTimer(timeInterval: delay + totalDuration,
                                     target: self,
                                     selector: #selector(self.toggleNoSoundOn),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    @objc private func pulseFirstInterval() {
        pbFirstInterval.isEnabled = true
        _pulseCounter = NUM_OF_PULSE_CHILDREN
        pulseInterval(pbFirstInterval)
    }
    
    @objc private func pulseSecondInterval() {
        pbSecondInterval.isEnabled = true
        _pulseCounter = NUM_OF_PULSE_CHILDREN
        pulseInterval(pbSecondInterval)
    }
    
    @objc private func pulseInterval(_ pbInterval: UIButton) {
        if(_pulseCounter == 0) {return}
        _pulseCounter -= 1
        
        UIView.animate(withDuration: PULSE_TIME_CHILDREN / 2,
                       delay: 0,
                       options: .allowUserInteraction,
                       animations: {
                        pbInterval.transform = CGAffineTransform(
                            scaleX: ANIMATE_SCALE, y: ANIMATE_SCALE)},
                       completion: {_ in self.restoreInterval(pbInterval)}
        )
    }
    
    @objc private func restoreInterval(_ pbInterval: UIButton) {
        UIView.animate(withDuration: PULSE_TIME_CHILDREN / 2,
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
        
        reloadLocaleSetting()
        setButtonToggle(toggle: false)
        testNewFrequency()
    }
    
    private func reloadLocaleSetting() {
        pbReturnToTitle.setTitle(
            NSLocalizedString("Return To Title", comment: ""), for: .normal)
        pbRepeat.setTitle(
            NSLocalizedString("Repeat", comment: ""), for: .normal)
        pbPause.setTitle(
            NSLocalizedString("Pause", comment: ""), for: .normal)
        
        let isPortuguese = (_testModel.getTestLauguage() == .portuguese)
        let noSoundImagePath = isPortuguese ? NO_SOUND_PORTUGUESE : NO_SOUND_CHILDREN
        let noSoundImage = UIImage(named: noSoundImagePath)
        
        pbNoSound.setBackgroundImage(noSoundImage, for: .normal)
        pbNoSound.adjustsImageWhenHighlighted = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
