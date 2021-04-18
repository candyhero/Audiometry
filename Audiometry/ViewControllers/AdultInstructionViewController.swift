
import UIKit
import CoreData

class AdultInstructionViewController: UIViewController {
    
    @IBOutlet weak var pbReturnToTitle: UIButton!
    @IBOutlet weak var pbPause: UIButton!
    @IBOutlet weak var pbRepeat: UIButton!
    @IBOutlet weak var pbStartTesting: UIButton!
    
    @IBOutlet weak var pbFirstInterval: UIButton!
    @IBOutlet weak var pbSecondInterval: UIButton!
    @IBOutlet weak var pbNoSound: UIButton!
    
    @IBOutlet weak var lbCaption: UILabel!
    
    private func loadPortuguse(){
        pbNoSound.setBackgroundImage(UIImage(named: NO_SOUND_PORTUGUESE), for: .normal)
        
    }
    
    private func reloadLocaleSetting(){
        pbReturnToTitle.setTitle(
            NSLocalizedString("Return To Title", comment: ""), for: .normal)
        pbStartTesting.setTitle(
            NSLocalizedString("Start Testing", comment: ""), for: .normal)
        pbRepeat.setTitle(
            NSLocalizedString("Repeat", comment: ""), for: .normal)
        pbPause.setTitle(
            NSLocalizedString("Pause", comment: ""), for: .normal)
        pbNoSound.setTitle(
            NSLocalizedString("No Sound", comment: ""), for: .normal)
        
        lbCaption.text = NSLocalizedString("Adult Caption", comment: "")
    }
    
    private func reloadButtonImage() {
        let imagePath = "Shape_Icons/500Hz"
        let image = UIImage(named: imagePath)?.withRenderingMode(.alwaysOriginal)
        
        pbFirstInterval.imageView?.contentMode = .scaleAspectFit
        pbSecondInterval.imageView?.contentMode = .scaleAspectFit
        
        pbFirstInterval.setImage(image, for: .normal)
        pbSecondInterval.setImage(image, for: .normal)
        
        pbFirstInterval.adjustsImageWhenHighlighted = false
        pbSecondInterval.adjustsImageWhenHighlighted = false
        
        pbNoSound.setBackgroundImage(UIImage(named: NO_SOUND_ADULT), for: .normal)
        pbNoSound.adjustsImageWhenHighlighted = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async { [unowned self] in
            self.reloadLocaleSetting()
            self.reloadButtonImage()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
