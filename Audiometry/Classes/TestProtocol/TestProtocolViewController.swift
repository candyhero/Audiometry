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
    @IBOutlet weak var SaveAsNewButton: UIButton!
    @IBOutlet weak var loadOtherButton: UIButton!
    @IBOutlet weak var deleteCurrentButton: UIButton!
    
    @IBOutlet weak var adultTestButton: UIButton!
    @IBOutlet weak var childrenTestButton: UIButton!
    
    private var _frequencyButtons: [Int:UIButton]!
    private var _earOrderButtons: [TestEarOrder:UIButton]!
    
    let loadTestProtocolPickerView = UIPickerView(
        frame: CGRect(x: 0, y: 50, width: 260, height: 160)
    )
    
    // MARK: I/O for viewmodel
    private var _viewModel: TestProtocolViewPresentable!
    var viewModelBuilder: TestProtocolViewModel.ViewModelBuilder!
    
    private lazy var _relays = (
        onSelectFrequency: PublishRelay<Int>(),
        onSelectEarOrder: PublishRelay<TestEarOrder>()
    )
    
    private let _disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        _viewModel = viewModelBuilder((
            onClickReturn: returnButton.rx.tap.asSignal(),
            onSelectFrequency: _relays.onSelectFrequency.asSignal(),
            onClearLastFrequency: clearLastFrequencyButton.rx.tap.asSignal(),
            onClearAllFrequency: clearAllFrequencyButton.rx.tap.asSignal(),
            
            onSelectEarOrder: _relays.onSelectEarOrder.asSignal()
        ))
        
        setupView()
        setupBinding()
    }

    private func setupView() {
        testFrequencyButtonStackView.axis = .horizontal
        testFrequencyButtonStackView.distribution = .fillEqually
        testFrequencyButtonStackView.alignment = .center
        testFrequencyButtonStackView.spacing = 15

        testFrequencySelectionLabel.textAlignment = .center
        testFrequencySelectionLabel.numberOfLines = 0
        
        _frequencyButtons = DEFAULT_FREQ.reduce(
            into: [Int: UIButton]()
        ){ (lookup, frequency) in
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
}

extension TestProtocolViewController {
    private func setupBinding() {
        bindTestFrequencySelection()
        bindTestEarOrderSelection()
    }
    
    private func bindTestFrequencySelection(){
        _ = _frequencyButtons.map{ (frequency, button) in
            button.rx.tap
                .map{ frequency }
                .bind(to: _relays.onSelectFrequency)
                .disposed(by: _disposeBag)
        }
        
        _viewModel.output.currentFrequencySelection
            .map{ frequencySelection in
                if(frequencySelection.isEmpty){
                    return "Test Sequence: None"
                }
                
                let (size, count) = (5, frequencySelection.count)
                return String("Test Sequence:") +
                    stride(from: 0, to: count, by: size).map {
                        frequencySelection[$0 ..< min($0 + size, count)]
                            .map{"\($0) Hz ► "}.joined()
                    }.joined(separator: "\n")
                
            }.drive(testFrequencySelectionLabel.rx.text)
            .disposed(by: _disposeBag)
    }
    
    private func bindTestEarOrderSelection(){
        _ = _earOrderButtons.map{(testEarOrder, button) in
            button.rx.tap
                .map{ testEarOrder }
                .bind(to: _relays.onSelectEarOrder)
                .disposed(by: _disposeBag)
        }
        
        _viewModel.output.currentEarOrderSelection
            .map{[_earOrderButtons] testEarOrder in
                if let button = _earOrderButtons?[testEarOrder],
                    let label = button.titleLabel?.text{
                    return label
                } else {
                    return "Error"
                }
            }.drive(testEarOrderLabel.rx.text)
            .disposed(by: _disposeBag)
    }
}

//    // MARK: CoreData
//    @IBAction func saveFreqSeqProtocol(_ sender: UIButton) {
//        if coordinator.getFrequencyBufferCount() == 0 {
//            errorPrompt(errorMsg: "There is no test frequency selected")
//        } else {
//            inputPrompt(promptMsg: "Please Enter Protocol Name:",
//                        errorMsg: "Protocol name cannot be empty!",
//                        fieldMsg: "",
//                        confirmFunction: saveProtocol)
//        }
//    }
//
//    @IBAction func loadFreqSeqProtocol(_ sender: UIButton) {
//        _pickerIndex = 0
//
//        if !coordinator.isAnyTestProtocols() {
//            errorPrompt(errorMsg: "There is no saved protocol!")
//        }
//        else {
//            pickerPrompt(confirmFunction: { () in
//                self.updateFreqSeqLabel(
//                        self.coordinator.loadProtocol(self._pickerIndex)
//                )
//            })
//        }
//    }
//
//    func saveProtocol(_ protocolName: String) {
//        if coordinator.isProtocolNameExisted(protocolName) {
//            errorPrompt(errorMsg: "Protocol name already exists!")
//            return
//        }
//        coordinator.saveAsNewProtocol(protocolName)
//    }
//
//    @IBAction func deleteFreqSeqProtocol(_ sender: UIButton) {
//        if coordinator.deleteCurrentTestProtocol() {
//            errorPrompt(errorMsg: "There is no selected protcol!")
//        } else {
//            clearFreqSeqLabel()
//        }
//    }
//
//    @IBAction func startAdultTest(_ sender: UIButton) {
//        coordinator.setIsAdult(isAdult: true)
//        promptToStartTest()
//    }
//
//    @IBAction func startChildrenTest(_ sender: UIButton) {
//        coordinator.setIsAdult(isAdult: false)
//        promptToStartTest()
//    }
//
//    func promptToStartTest() {
//        // Error, no freq selected
//        if(coordinator.getFrequencyBufferCount() == 0) {
//            errorPrompt(errorMsg: "There is no frequency selected!")
//            return
//        }
//
//        // Double Textfield Prompt
//        let alertCtrl = UIAlertController(
//            title: "Save",
//            message: "Please Enter Patient's Group & Name:",
//            preferredStyle: .alert)
//
//        alertCtrl.addTextField { (textField) in textField.placeholder = "Patient's Group" }
//        alertCtrl.addTextField { (textField) in textField.placeholder = "Patient's Name, i.e. John Smith 1" }
//
//        let confirmActionHandler = { (action: UIAlertAction) in
//            if let patientGroup = alertCtrl.textFields?[0].text,
//                let patientName = alertCtrl.textFields?[1].text{
//                self.startTest(patientGroup, patientName)
//            }
//        }
//
//        alertCtrl.addAction(UIAlertAction(title: "Confirm", style: .default, handler: confirmActionHandler))
//        alertCtrl.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//
//        self.present(alertCtrl, animated: true, completion: nil)
//    }
//
//    func startTest(_ patientGroup: String, _ patientName: String) {
//        let isAdult = coordinator.isAdult()
//        do{
//            guard patientGroup.count > 0 else { throw PreTestError.invalidPaientGroup }
//            guard patientName.count > 0 else { throw PreTestError.invalidPatentName }
//
//            coordinator.saveNewPatientProfile(patientGroup, patientName, lbEarOrder.text!)
//            coordinator.showInstructionView(sender: nil, isAdult: isAdult)
//        } catch PreTestError.invalidPaientGroup {
//            errorPrompt(errorMsg: "Patient group cannot be empty!")
//        } catch PreTestError.invalidPatentName {
//            errorPrompt(errorMsg: "Patient name cannot be empty!")
//        } catch {
//            print("[Error] Unexpected error: \(error).")
//        }
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//}
//
//extension TestProtocolViewController: UIPickerViewDelegate, UIPickerViewDataSource{
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return coordinator.getTestProtocolCount()
//    }
//
//    func pickerView(_ pickerView: UIPickerView,
//                    titleForRow row: Int,
//                    forComponent component: Int) -> String? {
//        return coordinator.getTestProtocolName(_pickerIndex)
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        _pickerIndex = row
//    }
//}
