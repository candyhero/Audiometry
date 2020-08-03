//
//  ChildTestInstructionViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 14/7/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChildrenTestInstructionViewController: UIViewController, Storyboardable {
    // MARK: UI Components
    @IBOutlet private weak var returnButton: UIButton!
    @IBOutlet private weak var startTestButton: UIButton!
    
    @IBOutlet private weak var firstResponseButton: UIButton!
    @IBOutlet private weak var secondResponseButton: UIButton!
    @IBOutlet private weak var noSoundResponseButton: UIButton!

    @IBOutlet private weak var repeatButton: UIButton!
    
    @IBOutlet weak var instructionLabel: UILabel!
    
    // MARK: I/O for viewmodel
    private var _viewModel: TestInstructionViewPresentable!
    var viewModelBuilder: TestInstructionViewModel.ViewModelBuilder!
    
    private let _disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        _viewModel = viewModelBuilder((
            onClickReturn: returnButton.rx.tap.asSignal(),
            onClickStartTest: startTestButton.rx.tap.asSignal()
        ))
        
        setupView()
    }
}

extension ChildrenTestInstructionViewController {
    private func setupView() {
        let imagePath = "\(ANIMAL_ICON_PATH)/500Hz"
        let image = UIImage(named: imagePath)?.withRenderingMode(.alwaysOriginal)
        
        self.firstResponseButton.imageView?.contentMode = .scaleAspectFit
        self.secondResponseButton.imageView?.contentMode = .scaleAspectFit
        
        self.firstResponseButton.setImage(image, for: .normal)
        self.secondResponseButton.setImage(image, for: .normal)
        
        self.firstResponseButton.adjustsImageWhenHighlighted = false
        self.secondResponseButton.adjustsImageWhenHighlighted = false
        self.noSoundResponseButton.adjustsImageWhenHighlighted = false
    }
    
//    private func loadPortuguese() {
//        let attachment:NSTextAttachment = NSTextAttachment()
//        attachment.image = UIImage(named: "\(ANIMAL_ICON_PATH)/emoji")
//
//        let caption:NSMutableAttributedString = NSMutableAttributedString(string: PORT_CHILDREN_CAPTION_TEXT)
//        caption.append(NSAttributedString(attachment: attachment))
//        lbCaption.attributedText = caption
//
//        pbStart.setTitle(PORT_START_TEXT, for: .normal)
//        pbRepeat.setTitle(PORT_REPEAT_TEXT, for: .normal)
//    }
}
