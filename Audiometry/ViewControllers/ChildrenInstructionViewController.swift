
import UIKit
import CoreData

class ChildrenInstructionViewController: UIViewController {
    
    private let _managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    // All test setup settings
    private var _globalSetting: GlobalSetting!

    @IBOutlet private weak var pbFirstInterval: UIButton!
    @IBOutlet private weak var pbSecondInterval: UIButton!
    
    @IBOutlet private weak var pbNoSound: UIButton!
    @IBOutlet private weak var pbRepeat: UIButton!
    @IBOutlet private weak var pbStart: UIButton!
    @IBOutlet weak var lbCaption: UILabel!
    
    private func loadGlobalSetting() {
        // fetch global setting
        let request:NSFetchRequest<GlobalSetting> =
            GlobalSetting.fetchRequest()
        request.fetchLimit = 1
        
        do {
            _globalSetting = try _managedContext.fetch(request).first
            
        } catch let error as NSError{
            print("Could not fetch global setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    private func loadButtonUI() {
        let pbImgDir = "Animal_Icons/500Hz"
        let pbImg = UIImage(named: pbImgDir)?.withRenderingMode(.alwaysOriginal)
        
        self.pbFirstInterval.imageView?.contentMode = .scaleAspectFit
        self.pbSecondInterval.imageView?.contentMode = .scaleAspectFit
        
        self.pbFirstInterval.setImage(pbImg, for: .normal)
        self.pbSecondInterval.setImage(pbImg, for: .normal)
        
        self.pbFirstInterval.adjustsImageWhenHighlighted = false
        self.pbSecondInterval.adjustsImageWhenHighlighted = false
        self.pbNoSound.adjustsImageWhenHighlighted = false
        
    }
    
    private func loadPortuguse(){
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.image = UIImage(named: "Animal_Icons/emoji")
        
        var caption:NSMutableAttributedString =
            NSMutableAttributedString(string: PORT_CHILDREN_CAPTION_TEXT)
        
        caption.append(NSAttributedString(attachment: attachment))
        
        lbCaption.attributedText = caption
        
        pbStart.setTitle(PORT_START_TEXT, for: .normal)
        pbRepeat.setTitle(PORT_REPEAT_TEXT, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async { [unowned self] in
            self.loadGlobalSetting()
            
            switch self._globalSetting.testLanguage{
            case "Invalid":
                print("Invalid language option!!")
                break
            case "Portuguese":
                print("Loading Portugese...")
                self.loadPortuguse()
                self.pbNoSound.setBackgroundImage(UIImage(named: "Animal_Icons/no_sound_Port"), for: .normal)
            default:
                self.pbNoSound.setBackgroundImage(UIImage(named: "Animal_Icons/no_sound"), for: .normal)
                break
            }
            
            self.loadButtonUI()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
