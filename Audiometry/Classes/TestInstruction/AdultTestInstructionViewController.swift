//
//  AdultTestInstructionViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 14/7/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AdultTestInstructionViewController: UIViewController, Storyboardable {
    // MARK: UI Components
    @IBOutlet private weak var returnButton: UIButton!
    @IBOutlet private weak var startTestButton: UIButton!
    
    @IBOutlet private weak var firstResponseButton: UIButton!
    @IBOutlet private weak var secondResponseButton: UIButton!
    @IBOutlet private weak var noSoundResponseButton: UIButton!

    @IBOutlet private weak var repeatButton: UIButton!
    @IBOutlet private weak var pauseButton: UIButton!
    
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

extension AdultTestInstructionViewController {
    private func setupView() {
        
    }
}
