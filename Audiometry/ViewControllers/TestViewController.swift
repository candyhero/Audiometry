
import UIKit

protocol TestViewController: UIViewController, Storyboarded {
    // MARK:
    var coordinator: TestCoordinator! { get set}

    // Used by animator
    var imgDir: String {get set}
    var timer: Timer? { get set}
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
    }

    // Test
    internal func checkResponse(_ senderTag: Int, isAdult: Bool) {
        pause()
        checkSpam(senderTag)
        if coordinator.checkResponse(senderTag) { // Done for this freq
//            print("Next Freq: ", coordinator.getNewTestFreq())
            if(coordinator.isPaused()) {
                print("Switching to the other ear")
                coordinator.showPauseView(isAdult: isAdult)
                return
            } else if(coordinator.isStopped()) {
                // Already tested both ears
                coordinator.showResultView()
                return
            } else {
                testNewFreq()
            }
        }
        play(isAdult: isAdult)
    }

    internal func checkSpam(_ senderTag: Int) { //Check if same button 5 times in a row
        spamButtonCounter = (senderTag == lastClicked ?? nil) ? spamButtonCounter + 1 : 0
        if(spamButtonCounter >= 4) {
            spamButtonCounter = 0
            coordinator.increaseSpamCount()
            DispatchQueue.main.async {
                self.errorPrompt(errorMsg: "Please ask for re-instrcution.")
            }
        }
//        print("Button Spam Count: ", spamButtonCounter)
        lastClicked = senderTag
    }

    // MARK: UI Functions
    internal func pause() {
        toggleButtons(toggle: false)
        pulseToggle(isPlaying: false)
        
        firstTimer?.invalidate()
        secondTimer?.invalidate()
        timer?.invalidate()
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

    internal func play(isAdult: Bool) {
        pulseToggle(isPlaying: true)
        
        let pulseCount: Int! = isAdult ? NUM_OF_PULSE_ADULT : NUM_OF_PULSE_CHILDREN
        let pulseTime: Double! = isAdult ? PULSE_TIME_ADULT : PULSE_TIME_CHILDREN

        let firstDuration = PLAY_GAP_TIME + pulseTime * Double(pulseCount)
        let totalDuration = PLAY_GAP_TIME + pulseTime * Double(pulseCount * 2)

        firstTimer = Timer.scheduledTimer(withTimeInterval: 0, repeats: false){ _ in
            self.pbFirst.isEnabled = true
            self.pulseInterval(self.pbFirst, pulseTime, pulseCount)
        }

        secondTimer = Timer.scheduledTimer(withTimeInterval: firstDuration, repeats: false){ _ in
            self.pbSecond.isEnabled = true
            self.pulseInterval(self.pbSecond, pulseTime, pulseCount)
        }

        timer = Timer.scheduledTimer(withTimeInterval: totalDuration, repeats: false){ _ in
            self.pbNoSound.isEnabled = true
            self.pulseToggle(isPlaying: false)
        }
        DispatchQueue.main.async(){
            self.coordinator.playAudio()
        }
    }

    internal func pulseInterval(_ pbInterval: UIButton, _ pulseTime: Double, _ counter: Int) {
        if(counter == 0) { return }
        UIView.animate(withDuration: pulseTime / 2,
                delay: 0,
                options: .allowUserInteraction,
                animations: {pbInterval.transform =
                    CGAffineTransform(scaleX: ANIMATE_SCALE, y: ANIMATE_SCALE) },
                completion: {_ in self.restoreInterval(pbInterval, pulseTime, counter)}
        )
    }

    internal func restoreInterval(_ pbInterval: UIButton, _ pulseTime: Double, _ counter: Int) {
        UIView.animate(withDuration: pulseTime / 2,
                delay: 0,
                options: .allowUserInteraction,
                animations: { pbInterval.transform = CGAffineTransform.identity},
                completion: {_ in self.pulseInterval(pbInterval, pulseTime, counter-1)}
        )
    }
}
