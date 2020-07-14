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
    
    private var _viewModel: TestInstructionViewPresentable!
    var viewModelBuilder: TestInstructionViewModel.ViewModelBuilder!
    
    private let _disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        _viewModel = viewModelBuilder((
        ))
    }
}
