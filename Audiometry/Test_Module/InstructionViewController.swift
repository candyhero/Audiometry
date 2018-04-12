//
//  InstructionViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 3/27/18.
//  Copyright © 2018 Xavier Chan. All rights reserved.
//

import UIKit

class InstructionViewController: UIViewController {

    @IBOutlet private weak var pbFirstInterval: UIButton!
    @IBOutlet private weak var pbSecondInterval: UIButton!
    
    @IBOutlet private weak var pbNoSound: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async { [unowned self] in
            let pbImgDir = "Shapes/500Hz"
            let pbImg = UIImage(named: pbImgDir)?.withRenderingMode(.alwaysOriginal)
            
            self.pbFirstInterval.imageView?.contentMode = .scaleAspectFit
            self.pbSecondInterval.imageView?.contentMode = .scaleAspectFit
            
            self.pbFirstInterval.setImage(pbImg, for: .normal)
            self.pbSecondInterval.setImage(pbImg, for: .normal)
            
            self.pbFirstInterval.adjustsImageWhenHighlighted = false
            self.pbSecondInterval.adjustsImageWhenHighlighted = false
            self.pbNoSound.adjustsImageWhenHighlighted = false
            
            self.pbNoSound.setBackgroundImage(UIImage(named: "Shapes/no_sound"), for: .normal)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
