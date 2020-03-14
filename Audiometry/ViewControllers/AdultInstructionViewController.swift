
import UIKit
import CoreData

class AdultInstructionViewController: UIViewController, Storyboarded {
    // MARK:
    let coordinator = AppDelegate.testCoordinator
    
    // MARK:
    @IBOutlet private weak var pbFirst: UIButton!
    @IBOutlet private weak var pbSecond: UIButton!
    @IBOutlet private weak var pbNoSound: UIButton!

    @IBOutlet private weak var pbStart: UIButton!
    @IBOutlet private weak var pbPause: UIButton!
    @IBOutlet private weak var pbRepeat: UIButton!
    
    @IBOutlet weak var lbCaption: UILabel!

    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async { [unowned self] in
            self.loadButtonUI()
        }
        
        switch coordinator.getTestLanguage(){
            case "Invalid":
                print("Invalid language option!!")
                break
            case "Portuguese":
                print("Loading Portuguese...")
                self.loadPortuguese()
            default:
                let background = UIImage(named: "\(SHAPE_ICON_PATH)/no_sound")
                self.pbNoSound.setBackgroundImage(background, for: .normal)
                break
        }
    }
    
    @IBAction func startTest(_ sender: UIButton) {
        coordinator.showTestView(isAdult: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        coordinator.back()
    }
    
    // MARK:
    private func loadPortuguese() {
        lbCaption.text = PORT_ADULT_CAPTION_TEXT
        pbNoSound.setBackgroundImage(UIImage(named: "\(ANIMAL_ICON_PATH)/no_sound_Port"), for: .normal)
        pbNoSound.setTitle("", for: .normal)
        pbStart.setTitle(PORT_START_TEXT, for: .normal)
        pbPause.setTitle(PORT_PAUSE_TEXT, for: .normal)
        pbRepeat.setTitle(PORT_REPEAT_TEXT, for: .normal)
    }
    
    private func loadButtonUI() {
        let pbImgDir = "\(SHAPE_ICON_PATH)/500Hz"
        print(pbImgDir)
        let pbImg = UIImage(named: pbImgDir)?.withRenderingMode(.alwaysOriginal)
        
        self.pbFirst.imageView?.contentMode = .scaleAspectFit
        self.pbSecond.imageView?.contentMode = .scaleAspectFit
        
        self.pbFirst.setImage(pbImg, for: .normal)
        self.pbSecond.setImage(pbImg, for: .normal)
        
        self.pbFirst.adjustsImageWhenHighlighted = false
        self.pbSecond.adjustsImageWhenHighlighted = false
        self.pbNoSound.adjustsImageWhenHighlighted = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
