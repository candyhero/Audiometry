
import UIKit

class AdultTestViewController: UIViewController, Storyboarded {
    // MARK:
    let coordinator = AppDelegate.testCoordinator
    
    // Used by animator
    private var timer, firstTimer, secondTimer: Timer?
    private var pulseCounter: Int!
    
    private var buttonCounter: Int!
    private var lastClicked: Int!
    
    @IBOutlet private weak var svIcons: UIStackView!
    
    @IBOutlet private weak var pbFirst: UIButton!
    @IBOutlet private weak var pbSecond: UIButton!
    @IBOutlet private weak var pbNoSound: UIButton!
    
    @IBOutlet private weak var pbRepeat: UIButton!
    @IBOutlet private weak var pbPause: UIButton!
    
    @IBOutlet weak var lbInstruction: UILabel!
    @IBOutlet weak var lbProgress: UILabel!
    
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch coordinator.getTestLanguage() {
        case "Invalid":
            print("Invalid language option!!")
            break
        case "Portuguese":
            print("Loading Portuguese...")
            loadPortuguese()
            break
        default:
            break
        }

        // Set UI
        pbNoSound.setBackgroundImage(UIImage(named: "\(SHAPE_ICON_PATH)/no_sound"), for: .normal)
        pbNoSound.adjustsImageWhenHighlighted = false
        pbNoSound.tag = 0
        pbFirst.tag = 1
        pbSecond.tag = 2
        
        toggleButtons(toggle: false)
        testNewFreq()
    }

    private func loadPortuguese() {
        lbInstruction.text = PORT_ADULT_INSTRCUTION_TEXT
        pbNoSound.setBackgroundImage(UIImage(named: "\(ANIMAL_ICON_PATH)/no_sound_Port"), for: .normal)
        pbNoSound.setTitle("", for: .normal)
        pbPause.setTitle(PORT_PAUSE_TEXT, for: .normal)
        pbRepeat.setTitle(PORT_REPEAT_TEXT, for: .normal)
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
//------------------------------------------------------------------------------
// Main Flow
//------------------------------------------------------------------------------
    private func testNewFreq() {
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
        timer = Timer.scheduledTimer(
                timeInterval: 1.0,
                target: self,
                selector: #selector(testNextDB),
                userInfo: nil,
                repeats: false
        )
    }

    private func loadButtonUI() {
        let freq: Int = coordinator.getTestFreq()
        let imgDir = "\(SHAPE_ICON_PATH)/\(freq)Hz"
        if let img = UIImage(named: imgDir)?.withRenderingMode(.alwaysOriginal) {
            self.pbFirst.imageView?.contentMode = .scaleAspectFit
            self.pbSecond.imageView?.contentMode = .scaleAspectFit

            self.pbFirst.setImage(img, for: .normal)
            self.pbSecond.setImage(img, for: .normal)

            self.pbFirst.adjustsImageWhenHighlighted = false
            self.pbSecond.adjustsImageWhenHighlighted = false
        }
        print(freq, imgDir)
    }

    @objc func testNextDB() {
        DispatchQueue.main.async { [unowned self] in
            self.coordinator.playSignalCase()
            self.pulseAnimation(0)
        }
    }

    // Test
    @IBAction private func checkResponse(_ sender: UIButton) {
        pausePlaying(sender)
        checkSpam(sender)
        let freq = coordinator.getTestFreq()
        let isThresholdFound = coordinator.checkResponse(sender.tag)
        if isThresholdFound! { // Done for this freq
//            print("Next Freq: ", coordinator.getNewTestFreq())
            if(freq < 0) {
                print("Switching to the other ear")
                coordinator.showPauseView()
            } else if(freq == 0) {
                // Already tested both ears
                coordinator.showPauseView()
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

    private func checkSpam(_ sender: UIButton) { //Check if same button 5 times in a row
        buttonCounter = (sender.tag == lastClicked ?? nil) ? buttonCounter + 1 : 0
        if(buttonCounter >= 4) {
            buttonCounter = 0
            coordinator.increaseSpamCount()
            errorPrompt(errorMsg: "Please ask for re-instrcution.")
        }
//        print("Button Spam Count: ", buttonCounter)
        lastClicked = sender.tag
    }

    // MARK: UI Functions
    @IBAction private func repeatPlaying(_ sender: UIButton) {
        pulseToggle(isPlaying: true)
        pulseAnimation(0)
        coordinator.replaySignalCase()
    }

    @IBAction private func pausePlaying(_ sender: UIButton) {
        toggleButtons(toggle: false)
        pulseToggle(isPlaying: false)

        firstTimer?.invalidate()
        secondTimer?.invalidate()
        timer?.invalidate()
        pulseCounter = 0
        coordinator.pausePlaying()
    }

    // MARK: Animations
    private func toggleButtons(toggle: Bool!) {
        pbNoSound.isEnabled = toggle
        pbNoSound.isHighlighted = !toggle
        pbFirst.isEnabled = toggle
        pbSecond.isEnabled = toggle
    }

    private func pulseToggle(isPlaying: Bool!) {
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
        pbFirst.isEnabled = true
        pulseCounter = NUM_OF_PULSE_ADULT
        pulseInterval(pbFirst)
    }

    @objc private func pulseSecondInterval() {
        pbSecond.isEnabled = true
        pulseCounter = NUM_OF_PULSE_ADULT
        pulseInterval(pbSecond)
    }

    @objc private func pulseInterval(_ pbInterval: UIButton) {
        if(pulseCounter == 0) {return}
        pulseCounter -= 1

        UIView.animate(withDuration: PULSE_TIME_ADULT / 2,
                delay: 0,
                options: .allowUserInteraction,
                animations: { pbInterval.transform = CGAffineTransform(
                        scaleX: ANIMATE_SCALE, y: ANIMATE_SCALE)},
                completion: {_ in self.restoreInterval(pbInterval)}
        )
    }

    @objc private func restoreInterval(_ pbInterval: UIButton) {
        UIView.animate(withDuration: PULSE_TIME_ADULT / 2,
                delay: 0,
                options: .allowUserInteraction,
                animations: { pbInterval.transform = CGAffineTransform.identity},
                completion: {_ in self.pulseInterval(pbInterval)}
        )
    }
}
