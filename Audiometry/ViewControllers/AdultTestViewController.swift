
import UIKit

class AdultTestViewController: UIViewController, TestViewController {

    var coordinator: TestCoordinator! = AppDelegate.testCoordinator
    
    // Used by animator
    internal var imgDir: String = SHAPE_ICON_PATH
    internal var timer, firstTimer, secondTimer: Timer?
    internal var pulseCounter: Int!

    internal var spamButtonCounter: Int!
    internal var lastClicked: Int!
    
    @IBOutlet internal weak var svIcons: UIStackView!
    
    @IBOutlet internal weak var pbFirst: UIButton!
    @IBOutlet internal weak var pbSecond: UIButton!
    @IBOutlet internal weak var pbNoSound: UIButton!
    
    @IBOutlet internal weak var pbRepeat: UIButton!
    @IBOutlet internal weak var pbPause: UIButton!

    @IBOutlet internal weak var lbProgress: UILabel!
    @IBOutlet internal weak var lbInstruction: UILabel!
    
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleButtons(toggle: false)

        // Set UI
        switch coordinator.getTestLanguage() {
            case "Invalid":
                print("Invalid language option!!")
                break
            case "Portuguese":
                print("Loading Portuguese...")
                lbInstruction.text = PORT_ADULT_INSTRCUTION_TEXT
                pbNoSound.setBackgroundImage(UIImage(named: "\(ANIMAL_ICON_PATH)/no_sound_Port"), for: .normal)
                pbNoSound.setTitle("", for: .normal)
                pbPause.setTitle(PORT_PAUSE_TEXT, for: .normal)
                pbRepeat.setTitle(PORT_REPEAT_TEXT, for: .normal)
                break
            default:
                break
        }
        setupButtonUI()
        testNewFreq()
        play(isAdult: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLoad()
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    // MARK: UI Functions
    @IBAction func backToTitle(_ sender: UIButton) {
        coordinator.backToTitle()
    }

    @IBAction private func checkResponse(_ sender: UIButton) {
        checkResponse(sender.tag, isAdult: true)
    }

    @IBAction private func repeatPlaying(_ sender: UIButton) {
        play(isAdult: true)
    }

    @IBAction private func pausePlaying(_ sender: UIButton) {
        pause()
    }
}
