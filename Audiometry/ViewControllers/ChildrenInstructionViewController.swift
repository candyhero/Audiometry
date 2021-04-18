
import UIKit
import CoreData

class ChildrenInstructionViewController: UIViewController {
    
    private let _managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    // All test setup settings
    private var _globalSetting: GlobalSetting!
    
    @IBOutlet weak var pbReturnToTitle: UIButton!
    @IBOutlet weak var pbRepeat: UIButton!
    @IBOutlet weak var pbStartTesting: UIButton!

    @IBOutlet weak var pbFirstInterval: UIButton!
    @IBOutlet weak var pbSecondInterval: UIButton!
    @IBOutlet weak var pbNoSound: UIButton!
    
    @IBOutlet weak var lbCaption: UILabel!
    
    private func reloadGlobalSetting() {
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

    private func reloadLocaleSetting(){
        pbReturnToTitle.setTitle(
            NSLocalizedString("Return To Title", comment: ""), for: .normal)
        pbStartTesting.setTitle(
            NSLocalizedString("Start Testing", comment: ""), for: .normal)
        pbRepeat.setTitle(
            NSLocalizedString("Repeat", comment: ""), for: .normal)
        
        lbCaption.text = NSLocalizedString("Children Caption", comment: "")
        
        let testLanguage = _globalSetting.getTestLanguage()
        reloadInstructionCaption(testLanguage)
        reloadNoSoundImage(testLanguage)
    }
    
    private func reloadInstructionCaption(_ testLanguage: TestLanguage!) {
        if (testLanguage == .portuguese) {
            let attachment:NSTextAttachment = NSTextAttachment()
            attachment.image = UIImage(named: NO_SOUND_EMOJI)
            
            let captionText: String = NSLocalizedString("Children Caption", comment: "")
            let caption: NSMutableAttributedString = NSMutableAttributedString(string: captionText)
            caption.append(NSAttributedString(attachment: attachment))
            
            lbCaption.text = ""
            lbCaption.attributedText = caption
        }
    }
    
    private func reloadNoSoundImage(_ testLanguage: TestLanguage!) {
        let isPortuguese = (testLanguage == .portuguese)
        let noSoundImagePath = isPortuguese ? NO_SOUND_PORTUGUESE : NO_SOUND_CHILDREN
        let noSoundImage = UIImage(named: noSoundImagePath)
        pbNoSound.setBackgroundImage(noSoundImage, for: .normal)
        pbNoSound.adjustsImageWhenHighlighted = false
    }
    
    private func reloadButtonImage() {
        let imagePath = "Animal_Icons/500Hz"
        let image = UIImage(named: imagePath)?.withRenderingMode(.alwaysOriginal)
        
        pbFirstInterval.imageView?.contentMode = .scaleAspectFit
        pbSecondInterval.imageView?.contentMode = .scaleAspectFit
        
        pbFirstInterval.setImage(image, for: .normal)
        pbSecondInterval.setImage(image, for: .normal)
        
        pbFirstInterval.adjustsImageWhenHighlighted = false
        pbSecondInterval.adjustsImageWhenHighlighted = false
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async { [unowned self] in
            self.reloadGlobalSetting()
            self.reloadLocaleSetting()
            self.reloadButtonImage()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
