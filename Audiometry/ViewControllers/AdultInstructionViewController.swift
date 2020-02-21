
import UIKit
import CoreData

class AdultInstructionViewController: UIViewController, Storyboarded {
    // MARK:
    let coordinator = AppDelegate.testCoordinator
    
    // MARK:
    @IBOutlet private weak var pbFirstInterval: UIButton!
    @IBOutlet private weak var pbSecondInterval: UIButton!
    
    @IBOutlet private weak var pbNoSound: UIButton!
    @IBOutlet weak var pbStart: UIButton!
    @IBOutlet weak var pbPause: UIButton!
    @IBOutlet weak var pbRepeat: UIButton!
    
    @IBOutlet weak var lbCaption: UILabel!

    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async { [unowned self] in
            switch self.coordinator.getTestLanguage(){
            case "Invalid":
                print("Invalid language option!!")
                break
            case "Portuguese":
                print("Loading Portugese...")
                self.loadPortuguse()
            default:
                let background = UIImage(named: "\(SHAPE_ICON_PATH)/no_sound")  
                self.pbNoSound.setBackgroundImage(background, for: .normal)
                break
            }
            self.loadButtonUI()
        }
    }

    @IBAction func back(_ sender: UIButton) {
        coordinator.back()
    }
    
    // MARK:
    private func loadPortuguse() {
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
        
        self.pbFirstInterval.imageView?.contentMode = .scaleAspectFit
        self.pbSecondInterval.imageView?.contentMode = .scaleAspectFit
        
        self.pbFirstInterval.setImage(pbImg, for: .normal)
        self.pbSecondInterval.setImage(pbImg, for: .normal)
        
        self.pbFirstInterval.adjustsImageWhenHighlighted = false
        self.pbSecondInterval.adjustsImageWhenHighlighted = false
        self.pbNoSound.adjustsImageWhenHighlighted = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
