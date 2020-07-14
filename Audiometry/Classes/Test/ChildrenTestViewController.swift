//
//  ChildrenTestViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 13/7/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChildrenTestViewController: UIViewController, Storyboardable {
    // MARK: UI Components
    @IBOutlet private weak var returnButton: UIButton!
    
    @IBOutlet private weak var firstResponseButton: UIButton!
    @IBOutlet private weak var secondResponseButton: UIButton!
    @IBOutlet private weak var noSoundResponseButton: UIButton!

    @IBOutlet private weak var repeatButton: UIButton!
    @IBOutlet private weak var pauseButton: UIButton!
    
    @IBOutlet weak var progressLabel: UILabel!
    
    // MARK: I/O for viewmodel
    private var _viewModel: TestViewPresentable!
    var viewModelBuilder: TestViewModel.ViewModelBuilder!
    
    private let _disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        _viewModel = viewModelBuilder((
            onClickReturn: returnButton.rx.tap.asSignal(),
            ()
        ))
        
        setupView()
        setupBinding()
    }
}

extension ChildrenTestViewController {
    private func setupView() {
        
    }
    
    private func setupBinding() {
        
    }
}
