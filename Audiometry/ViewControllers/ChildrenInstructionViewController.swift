
import UIKit
import CoreData

class ChildrenInstructionViewController: UIViewController, Storyboarded {
    // MARK:
    let coordinator = AppDelegate.testCoordinator

    // MARK:
    @IBOutlet private weak var pbFirst: UIButton!
    @IBOutlet private weak var pbSecond: UIButton!
    @IBOutlet private weak var pbNoSound: UIButton!

    @IBOutlet private weak var pbRepeat: UIButton!
    @IBOutlet private weak var pbStart: UIButton!
    @IBOutlet weak var lbCaption: UILabel!

    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async { [unowned self] in
            self.loadButtonUI()
        }
        
        switch self.coordinator.getTestLanguage(){
        case "Invalid":
            print("Invalid language option!!")
            break
        case "Portuguese":
            print("Loading Portuguese...")
            self.loadPortuguese()
            self.pbNoSound.setBackgroundImage(UIImage(named: "\(ANIMAL_ICON_PATH)/no_sound_Port"), for: .normal)
        default:
            self.pbNoSound.setBackgroundImage(UIImage(named: "\(ANIMAL_ICON_PATH)/no_sound"), for: .normal)
            break
        }
    }
    
    @IBAction func startTest(_ sender: UIButton) {
        coordinator.showTestView(isAdult: false)
    }

    @IBAction func back(_ sender: UIButton) {
        coordinator.back()
    }

    // MARK:
    private func loadPortuguese() {
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.image = UIImage(named: "\(ANIMAL_ICON_PATH)/emoji")
        
        let caption:NSMutableAttributedString = NSMutableAttributedString(string: PORT_CHILDREN_CAPTION_TEXT)
        caption.append(NSAttributedString(attachment: attachment))
        lbCaption.attributedText = caption
        
        pbStart.setTitle(PORT_START_TEXT, for: .normal)
        pbRepeat.setTitle(PORT_REPEAT_TEXT, for: .normal)
    }
    
    private func loadButtonUI() {
        let pbImgDir = "\(ANIMAL_ICON_PATH)/500Hz"
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
