
import UIKit

protocol TestViewController: UIViewController, Storyboarded {
    // MARK:
    var coordinator: TestCoordinator! { get set}

    // Used by animator
    var imgDir: String {get set}
    var nosoundTimer: Timer? { get set}
    var firstTimer: Timer? { get set}
    var secondTimer: Timer? { get set}

    var spamButtonCounter: Int! { get set}
    var lastClicked: Int! { get set}

    // MARK: IBOutlet
    var svIcons: UIStackView! { get set}

    var pbFirst: UIButton! { get set}
    var pbSecond: UIButton! { get set}
    var pbNoSound: UIButton! { get set}

    var pbRepeat: UIButton! { get set}
    var pbPause: UIButton! { get set}

    var lbProgress: UILabel! { get set}
}

extension TestViewController {
    // MARK:
    internal func setupButtonUI() {
        pbNoSound.setBackgroundImage(UIImage(named: "\(imgDir)/no_sound"), for: .normal)
        pbNoSound.adjustsImageWhenHighlighted = false
        pbNoSound.tag = 0
        pbFirst.tag = 1
        pbSecond.tag = 2
    }

    internal func testNewFreq() {
        let freq = coordinator.getTestFreq()

        DispatchQueue.main.async { [unowned self] in
            if let img = UIImage(named: "\(self.imgDir)/\(freq)Hz")?.withRenderingMode(.alwaysOriginal) {
                self.pbFirst.imageView?.contentMode = .scaleAspectFit
                self.pbSecond.imageView?.contentMode = .scaleAspectFit

                self.pbFirst.setImage(img, for: .normal)
                self.pbSecond.setImage(img, for: .normal)

                self.pbFirst.adjustsImageWhenHighlighted = false
                self.pbSecond.adjustsImageWhenHighlighted = false
            }
            print(freq, self.imgDir)
        }

        lbProgress.text = "Test Progress: \(coordinator.getCurrentProgress())%"
        spamButtonCounter = 0
        play()
    }

    // Test
    internal func checkResponse(_ senderTag: Int) {
        pause()
        checkSpam(senderTag)
        let isThresholdFound = coordinator.checkResponse(senderTag)!
        let freq = coordinator.getTestFreq()

        if isThresholdFound { // Done for this freq
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
        play()
    }

    internal func checkSpam(_ senderTag: Int) { //Check if same button 5 times in a row
        spamButtonCounter = (senderTag == lastClicked ?? nil) ? spamButtonCounter + 1 : 0
        if(spamButtonCounter >= 4) {
            spamButtonCounter = 0
            coordinator.increaseSpamCount()
            errorPrompt(errorMsg: "Please ask for re-instrcution.")
        }
//        print("Button Spam Count: ", spamButtonCounter)
        lastClicked = senderTag
    }

    // MARK: UI Functions
    internal func play() {
        DispatchQueue.main.async { [unowned self] in
            self.pulseAnimation(delay: 0.0)
        }
        pulseToggle(isPlaying: true)

        DispatchQueue.main.async { [unowned self] in
            self.coordinator.playAudio()
        }
    }

    internal func pause() {
        toggleButtons(toggle: false)
        pulseToggle(isPlaying: false)

        firstTimer?.invalidate()
        secondTimer?.invalidate()
        nosoundTimer?.invalidate()
        coordinator.pauseAudio()
    }

    // MARK: Animations
    internal func toggleButtons(toggle: Bool!) {
        pbNoSound.isEnabled = toggle
        pbNoSound.isHighlighted = !toggle
        pbFirst.isEnabled = toggle
        pbSecond.isEnabled = toggle
    }

    internal func pulseToggle(isPlaying: Bool!) {
        pbPause.isHidden = !isPlaying
        pbRepeat.isHidden = isPlaying
    }

    internal func pulseAnimation(delay: Double) {
        // Play pulse Animation by number of times
        let firstDuration = PULSE_TIME_ADULT * Double(NUM_OF_PULSE_ADULT) + PLAY_GAP_TIME
        let totalDuration = PULSE_TIME_ADULT * Double(NUM_OF_PULSE_ADULT * 2) + PLAY_GAP_TIME

        firstTimer =  Timer.scheduledTimer(withTimeInterval: delay , repeats: false){ _ in
            self.pbFirst.isEnabled = true
            self.pulseInterval(self.pbFirst)
        }
        secondTimer = Timer.scheduledTimer(withTimeInterval: delay + firstDuration, repeats: false){ _ in
            self.pbSecond.isEnabled = true
            self.pulseInterval(self.pbSecond)
        }
        nosoundTimer = Timer.scheduledTimer(withTimeInterval: delay + totalDuration, repeats: false) { _ in
            self.pbNoSound.isEnabled = true
            self.pulseToggle(isPlaying: false)
        }
    }

    private func pulseInterval(_ pbInterval: UIButton) {
//        pulseCounter = isAdult ? NUM_OF_PULSE_ADULT : NUM_OF_PULSE_CHILDREN
//        if(pulseCounter == 0) {return}
//        pulseCounter -= 1
//
//        let pulseTimer = Timer.scheduledTimer(withTimeInterval: 0, repeats: true){ _ in
//        }

    }

    private func shrinkInterval(_ pbInterval: UIButton){
        UIView.animate(
                withDuration: PULSE_TIME_ADULT / 2,
                delay: 0,
                options: .allowUserInteraction,
                animations: { pbInterval.transform = CGAffineTransform(scaleX: ANIMATE_SCALE, y: ANIMATE_SCALE) },
                completion: {_ in self.restoreInterval(pbInterval)}
        )
    }

    internal func restoreInterval(_ pbInterval: UIButton) {
        UIView.animate(
            withDuration: PULSE_TIME_ADULT / 2,
            delay: 0,
            options: .allowUserInteraction,
            animations: { pbInterval.transform = CGAffineTransform.identity},
            completion: {_ in self.pulseInterval(pbInterval)}
        )
    }
}
