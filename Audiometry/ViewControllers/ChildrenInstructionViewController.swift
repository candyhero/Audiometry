
import UIKit

class ChildrenInstructionViewController: UIViewController {

    @IBOutlet private weak var pbFirstInterval: UIButton!
    @IBOutlet private weak var pbSecondInterval: UIButton!
    
    @IBOutlet private weak var pbNoSound: UIButton!
    
    @IBOutlet private weak var pbRepeat: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async { [unowned self] in
            let pbImgDir = "Animal_Icons/500Hz"
            let pbImg = UIImage(named: pbImgDir)?.withRenderingMode(.alwaysOriginal)
            
            self.pbFirstInterval.imageView?.contentMode = .scaleAspectFit
            self.pbSecondInterval.imageView?.contentMode = .scaleAspectFit
            
            self.pbFirstInterval.setImage(pbImg, for: .normal)
            self.pbSecondInterval.setImage(pbImg, for: .normal)
            
            self.pbFirstInterval.adjustsImageWhenHighlighted = false
            self.pbSecondInterval.adjustsImageWhenHighlighted = false
            self.pbNoSound.adjustsImageWhenHighlighted = false
            
            self.pbNoSound.setBackgroundImage(UIImage(named: "Animal_Icons/no_sound"), for: .normal)
            
//            self.pbRepeat.setImage(UIImage(named: "Animal_Icons/Repeat"), for: .normal)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
