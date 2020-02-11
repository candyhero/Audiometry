//
//  TestProcotolCoordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 9/2/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit

class TestProtocolCoordinator: Coordinator {
    
    var _navController: UINavigationController = AppDelegate.navController
    
    private var _globalSetting: GlobalSetting!
    private let _globalSettingRepo: GlobalSettingRepo = GlobalSettingRepo()
    private let _testProtocolRepo = TestProtocolRepo()
    
    private var _frequencyBuffer: [Int] = []
    private var _testProtocol: TestProtocol! = nil
    private var _testProtocols: [TestProtocol] = []
    
    func isPractice() -> Bool {
        return _globalSetting.isPractice
    }
    
    func isAdult() -> Bool {
        return _globalSetting.isAdult
    }
    
    func setIsAdult(isAdult: Bool) -> Bool {
        _globalSetting.isAdult = isAdult
        return _globalSetting.isAdult
    }
    func setTestLanguage(langauge: TestLanguage) -> String {
        _globalSetting.testLanguage = langauge.toString()
        return _globalSetting.testLanguage!
    }
    
    func setTestEarOrder(isLeft: Bool, isBoth: Bool) {
        _globalSetting.isTestingLeft = isLeft
        _globalSetting.isTestingBoth = isBoth
    }
    
    func getAllTestProtocols() -> [TestProtocol]{
        do {
            return try _testProtocolRepo.fetchAll()
        } catch let error as NSError{
            print("Could not fetch protocls.")
            print("\(error), \(error.userInfo)")
        }
        return []
    }
    func saveAsNewProtocol(_ protocolName: String) {
        do{
            let newProtocol = try _testProtocolRepo.create()
            newProtocol.timestamp = Date()
            newProtocol.frequencySequence = _globalSetting.testFrequencySequence
            newProtocol.isTestLeftFirst = _globalSetting.isTestingLeft
            newProtocol.isTestBoth = _globalSetting.isTestingBoth
            try _testProtocolRepo.update()
            
            _testProtocol = newProtocol
        } catch let error as NSError{
            print("Could not save test protocol.")
            print("\(error), \(error.userInfo)")
        }
    }
    func deleteCurrentTestProtocol() -> Bool!{
        // Validate current protocol
        if(_testProtocol == nil) { return false }
        
        do {
            try _testProtocolRepo.delete(_testProtocol)
            _testProtocol = nil
            _frequencyBuffer = []
            return true
        } catch let error as NSError {
            print("Could not fetch test protocols.")
            print("\(error), \(error.userInfo)")
            return false
        }
    }
    
    func loadProtocol(_ index: Int) -> [Int]{
        _testProtocol = _testProtocols[index]
        _frequencyBuffer = _testProtocol.frequencySequence ?? []
        return _frequencyBuffer
    }
    
    func getFrequencyBufferCount() -> Int{
        return _frequencyBuffer.count
    }
    
    func addTestFrequencyValue(_ frequency: Int) -> [Int]{
        if(!_frequencyBuffer.contains(frequency) ) {
            _frequencyBuffer.append(frequency)
        }
        return _frequencyBuffer
    }
    
    func removeLastTestFrequencyValue() -> [Int]{
        if(_frequencyBuffer.count > 0) {
            _frequencyBuffer.removeLast()
        }
        return _frequencyBuffer
    }
    
    func removeAllTestFrequencyValues() -> [Int]{
        if(_frequencyBuffer.count > 0) {
            _frequencyBuffer.removeAll()
        }
        return _frequencyBuffer
    }
    
    func start() {
        return
    }
    
    func back() {
        self._navController.popViewController(animated: true)
    }
    
    func showInstructionView(sender: Any? = nil, isAdult: Bool) {
        let vc = isAdult ? AdultInstructionViewController.instantiate()
            : ChildrenInstructionViewController.instantiate()
//        vc.coordinator = self
        self._navController.setNavigationBarHidden(true, animated: false)
        self._navController.show(vc, sender: nil)
    }
}
