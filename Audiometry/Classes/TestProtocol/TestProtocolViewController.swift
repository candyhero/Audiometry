//
//  TestProtocolViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 28/6/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TestProtocolViewController: UIViewController, Storyboardable {
    // MARK: UI Components
    @IBOutlet weak var returnButton: UIButton!

    @IBOutlet weak var testFrequencyButtonStackView: UIStackView!
    @IBOutlet weak var testFrequencySelectionLabel: UILabel!
    @IBOutlet weak var testEarOrderLabel: UILabel!
    @IBOutlet weak var testLanguageLabel: UILabel!
    
    @IBOutlet weak var setLeftOnly: UIButton!
    @IBOutlet weak var setRightOnly: UIButton!
    @IBOutlet weak var setLeftRight: UIButton!
    @IBOutlet weak var setRightLeft: UIButton!
    
    @IBOutlet weak var clearLastFrequencyButton: UIButton!
    @IBOutlet weak var clearAllFrequencyButton: UIButton!
    @IBOutlet weak var saveAsNewButton: UIButton!
    @IBOutlet weak var loadOtherButton: UIButton!
    @IBOutlet weak var deleteCurrentButton: UIButton!
    
    @IBOutlet weak var adultTestButton: UIButton!
    @IBOutlet weak var childrenTestButton: UIButton!
    
    private var _frequencyButtons: [Int:UIButton]!
    private var _earOrderButtons: [TestEarOrder:UIButton]!
    
    private let _loadTestProtocolPickerView = UIPickerView(
        frame: CGRect(x: 0, y: 50, width: 260, height: 160)
    )
    
    // MARK: I/O for viewmodel
    private var _viewModel: TestProtocolViewPresentable!
    var viewModelBuilder: TestProtocolViewModel.ViewModelBuilder!
    
    private lazy var _relays = (
        onSelectFrequency: PublishRelay<Int>(),
        onSelectEarOrder: PublishRelay<TestEarOrder>(),
        
        onSaveNewProtocol: PublishRelay<String>(),
        onLoadSelectedProtocol: PublishRelay<String>(),
        
        onValidateState: PublishRelay<PatientRole>(),
        onStartTest: PublishRelay<PatientProfileModel>()
    )
    
    private let _disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        _viewModel = viewModelBuilder((
            onClickReturn: returnButton.rx.tap.asSignal(),
            onClickLoadOther: loadOtherButton.rx.tap.asSignal(),
            onClickDeleteCurrent: deleteCurrentButton.rx.tap.asSignal(),
            
            onClearLastFrequency: clearLastFrequencyButton.rx.tap.asSignal(),
            onClearAllFrequency: clearAllFrequencyButton.rx.tap.asSignal(),
            
            onSelectFrequency: _relays.onSelectFrequency.asSignal(),
            onSelectEarOrder: _relays.onSelectEarOrder.asSignal(),
            
            onSaveNewProtocol: _relays.onSaveNewProtocol.asSignal(),
            onLoadSelectedProtocol: _relays.onLoadSelectedProtocol.asSignal(),

            onValidateState: _relays.onValidateState.asSignal(),
            onStartTest: _relays.onStartTest.asSignal()
        ))
        
        setupView()
        setupBinding()
    }
}

extension TestProtocolViewController {
    private func setupView() {
        testFrequencyButtonStackView.axis = .horizontal
        testFrequencyButtonStackView.distribution = .fillEqually
        testFrequencyButtonStackView.alignment = .center
        testFrequencyButtonStackView.spacing = 15

        testFrequencySelectionLabel.textAlignment = .center
        testFrequencySelectionLabel.numberOfLines = 0
        
        _frequencyButtons = DEFAULT_FREQ.reduce(
            into: [Int: UIButton]()
        ) { (lookup, frequency) in
            let button = UIButton(type:.system)
            button.setTitle(String(frequency) + " Hz", for: .normal)
            button.bounds = CGRect(x:0, y:0, width:300, height:300)
            button.backgroundColor = UIColor.gray
            button.setTitleColor(UIColor.white, for: .normal)
            button.titleEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
            
            lookup[frequency] = button
            testFrequencyButtonStackView.addArrangedSubview(button)
        }
        
        _earOrderButtons = [
            .LeftOnly: setLeftOnly,
            .RightOnly: setRightOnly,
            .LeftRight: setLeftRight,
            .RightLeft: setRightLeft
        ]
    }
    
    private func setupBinding() {
        bindTestFrequencySelection()
        bindTestEarOrderSelection()
        
        bindSaveAsNew()
        bindLoadOther()
        
        bindStartTest()
    }
        
    private func bindTestFrequencySelection() {
        _ = _frequencyButtons.map { (frequency, button) in
            button.rx.tap
                .map { frequency }
                .bind(to: _relays.onSelectFrequency)
                .disposed(by: _disposeBag)
        }
        
        _viewModel.output.currentFrequencySelection
            .map { frequencySelection in
                if(frequencySelection.isEmpty) {
                    return "Test Sequence: None"
                }
                
                let (size, count) = (5, frequencySelection.count)
                return String("Test Sequence:") +
                    stride(from: 0, to: count, by: size).map {
                        frequencySelection[$0 ..< min($0 + size, count)]
                            .map {"\($0) Hz ► "}.joined()
                    }.joined(separator: "\n")
                
            }.drive(testFrequencySelectionLabel.rx.text)
            .disposed(by: _disposeBag)
    }
    
    private func bindTestEarOrderSelection() {
        _ = _earOrderButtons.map { (testEarOrder, button) in
            button.rx.tap
                .map { testEarOrder }
                .bind(to: _relays.onSelectEarOrder)
                .disposed(by: _disposeBag)
        }
        
        _viewModel.output.currentEarOrderSelection
            .map { [_earOrderButtons] testEarOrder in
                if let button = _earOrderButtons?[testEarOrder],
                    let label = button.titleLabel?.text{
                    return label
                } else {
                    return "Error"
                }
            }.drive(testEarOrderLabel.rx.text)
            .disposed(by: _disposeBag)
    }
    
    private func bindSaveAsNew() {
        saveAsNewButton.rx.tap
            .bind { promptSettingNameInputPrompt() }
            .disposed(by: _disposeBag)
        
        func promptSettingNameInputPrompt() {
            let alertController = UIAlertController(
                title: "Save",
                message: "Please enter protocol name:",
                preferredStyle: .alert
            )
            let actions = [
                UIAlertAction(title: "Confirm", style: .default) { _ in
                    if let protocolName = alertController.textFields?[0].text {
                        confirmAction(protocolName: protocolName)
                    }
                },
                UIAlertAction(title: "Cancel", style: .cancel)
            ]
            actions.forEach(alertController.addAction)
            alertController.addTextField { $0.placeholder = "i.e. iPad1-EP1" }
            self.present(alertController, animated: true, completion: nil)
        }
        
        func confirmAction(protocolName: String) {
            if(protocolName.isNotEmpty) {
                _relays.onSaveNewProtocol.accept(protocolName)
            } else {
                promptProtocolNameInputError()
            }
        }
        
        func promptProtocolNameInputError() {
            let alertController = UIAlertController(
                title: "Error",
                message: "Protocol name cannot be empty!",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    private func bindLoadOther() {
//        loadOtherButton.rx.tap
        let onSelectedProtocol = BehaviorRelay<String>(value: "")
        let allTestProtocolNames = _viewModel.output.allTestProtocolNames.skip(1)
        
        _loadTestProtocolPickerView.rx.itemSelected.asDriver()
            .withLatestFrom(allTestProtocolNames) { $1[$0.row] }
            .drive(onSelectedProtocol)
            .disposed(by: _disposeBag)
        
        allTestProtocolNames
            .drive(_loadTestProtocolPickerView.rx.itemTitles) { (row, element) in
                return element
            }.disposed(by: _disposeBag)
        
        allTestProtocolNames
            .drive(onNext: { allNames in
                if let defaultName = allNames.first{
                    onSelectedProtocol.accept(defaultName)
                    promptPickerView()
                } else {
                    promptPickerViewError()
                }
            }).disposed(by: _disposeBag)
        
        func promptPickerView() {
            let alertController: UIAlertController! = UIAlertController(
                title: "Select a different test protocol",
                message: "\n\n\n\n\n\n\n\n\n",
                preferredStyle: .alert
            )
            let actions = [
                UIAlertAction(title: "Confirm", style: .default) { [_relays] _ in
                    _relays.onLoadSelectedProtocol.accept(onSelectedProtocol.value)
                },
                UIAlertAction(title: "Cancel", style: .cancel)
            ]
            actions.forEach(alertController.addAction)
            alertController.view.addSubview(_loadTestProtocolPickerView)
            present(alertController, animated: true, completion: nil)
        }
        
        func promptPickerViewError() {
            let alertController = UIAlertController(
                title: "Error",
                message: "There is no other test protocols!",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    private func bindStartTest() {
        // TO-DO
        let patientRole = BehaviorRelay<PatientRole>(value: .Invalid)
        
        adultTestButton.rx.tap
            .map { PatientRole.Adult }
            .bind(to: patientRole)
            .disposed(by: _disposeBag)
        
        childrenTestButton.rx.tap
            .map { PatientRole.Children }
            .bind(to: patientRole)
            .disposed(by: _disposeBag)
        
        patientRole
            .bind(to: _relays.onValidateState)
            .disposed(by: _disposeBag)
        
        _viewModel.output.validateState
            .skip(1)
            .drive(onNext: { isValid in
                isValid
                    ? promptPatientNameGroupInput(patientRole: patientRole.value)
                    : promptError(errorMessage: "Frequency cannot be empty!")
            })
            .disposed(by: _disposeBag)
        
        func validateFrequencySelection(_ frequencySelection: [Int], testMode: TestMode) -> Bool {
            if(frequencySelection.isEmpty) {
                promptError(errorMessage: "There is no test frequency selected!")
                return false
            } else if(testMode == .Practice && frequencySelection.count > 1) {
                promptError(errorMessage: "Please select only one frequency for practice!")
                return false
            }
            return true
        }
        
        func promptPatientNameGroupInput(patientRole: PatientRole) {
            let alertController = UIAlertController(
                title: "Save",
                message: "Please Enter Patient's Group & Name:",
                preferredStyle: .alert
            )
            alertController.addTextField { $0.placeholder = "Patient's Group, i.e. ABC" }
            alertController.addTextField { $0.placeholder = "Patient's Name, i.e. John Smith 1" }
            
            let actions = [
                UIAlertAction(title: "Confirm", style: .default) { _ in
                    if let patientGroup = alertController.textFields?[0].text,
                        let patientName = alertController.textFields?[1].text{
                        
                        let model = PatientProfileModel(
                            patientName: patientGroup,
                            patientGroup: patientName,
                            patientRole: patientRole
                        )
                        confirmAction(model: model)
                    }
                },
                UIAlertAction(title: "Cancel", style: .cancel)
            ]
            actions.forEach(alertController.addAction)
            self.present(alertController, animated: true, completion: nil)
        }

        func confirmAction(model: PatientProfileModel) {
            if(model.patientGroup.isEmpty) {
                promptError(errorMessage: "Patient group cannot be empty!")
            }
            else if(model.patientName.isEmpty) {
                promptError(errorMessage: "Patient Name cannot be empty!")
            }
            else {
                _relays.onStartTest.accept(model)
            }
        }
        
        func promptError(errorMessage: String) {
            let alertController = UIAlertController(
                title: "Error",
                message: errorMessage,
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true, completion: nil)
        }
    }
}

