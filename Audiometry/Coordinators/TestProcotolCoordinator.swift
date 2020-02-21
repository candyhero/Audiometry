//
//  TestProcotolCoordinator.swift
//  Audiometry
//
//  Created by Xavier Chan on 9/2/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit

class TestProtocolCoordinator: Coordinator {
    // MARK:
    var _navController = AppDelegate.navController

    private let _globalSettingRepo = GlobalSettingRepo.repo
    private let _testProtocolRepo = TestProtocolRepo.repo
    private let _patientProfileRepo = PatientProfileRepo.repo

    // MARK:
    private var _globalSetting: GlobalSetting!
    private var _frequencyBuffer: [Int]!
    private var _testProtocol: TestProtocol!
    private var _testProtocols: [TestProtocol]!
    
    func start() {
        do {
            _globalSetting = try _globalSettingRepo.fetchOrCreate()
            _frequencyBuffer = []
        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    func back() {
        _navController.popViewController(animated: true)
    }
    
    func showInstructionView(sender: Any? = nil, isAdult: Bool) {
        let vc = isAdult
                ? AdultInstructionViewController.instantiate(AppStoryboards.AdultTest)
                : ChildrenInstructionViewController.instantiate(AppStoryboards.ChildrenTest)
        _navController.setNavigationBarHidden(true, animated: false)
        _navController.show(vc, sender: nil)
    }

    func isPractice() -> Bool {
        return _globalSetting.isPractice
    }

    func isAdult() -> Bool {
        return _globalSetting.isAdult
    }

    func setIsAdult(isAdult: Bool) {
        _globalSetting.isAdult = isAdult
    }

    func setTestLanguage(language: TestLanguage) -> String{
        _globalSetting.testLanguageCode = Int16(language.rawValue)
        return language.toString()
    }

    func setTestEarOrder(isLeft: Bool, isBoth: Bool) {
        _globalSetting.isTestingLeft = isLeft
        _globalSetting.isTestingBoth = isBoth
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

    func getTestProtocolCount() -> Int {
        return _testProtocols.count
    }

    func getTestProtocolName(_ pickerIndex: Int) -> String {
        return _testProtocols[pickerIndex].name!
    }

    func fetchAllTestProtocols(){
        do {
            _testProtocols = try _testProtocolRepo.fetchAll()
        } catch let error as NSError{
            print("Could not fetch protocols.")
            print("\(error), \(error.userInfo)")
        }
    }

    func isAnyTestProtocols() -> Bool {
        fetchAllTestProtocols()
        return _testProtocols.isNotEmpty
    }

    func loadProtocol(_ pickerIndex: Int) -> [Int]{
        _testProtocol = _testProtocols[pickerIndex]
        _frequencyBuffer = _testProtocol.frequencySequence ?? []
        return _frequencyBuffer
    }

    func isProtocolNameExisted(_ protocolName: String) -> Bool{
        return _testProtocols.map{$0.name}.contains(protocolName)
    }

    func saveAsNewProtocol(_ protocolName: String){
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

    func saveNewPatientProfile(_ patientGroup: String, _ patientName: String, _ earOrder: String){
        // Format date
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .short
//        dateFormatter.timeStyle = .short
//
//        let localDate = dateFormatter.string(from: NSDate() as Date)

        do{
            let profile = try _patientProfileRepo.create()
            profile.group = patientGroup
            profile.name = patientName

            profile.earOrder = earOrder
            profile.isAdult = _globalSetting.isAdult
            profile.isPractice = _globalSetting.isPractice

            profile.timestamp = NSDate() as Date
            profile.durationSeconds = 0
            profile.frequencyOrder = _frequencyBuffer

            _globalSetting.patientProfile = profile
            _globalSetting.testFrequencySequence = _frequencyBuffer
            _globalSetting.currentTestCount = 0
            _globalSetting.totalTestCount = _globalSetting.isTestingBoth
                    ? Int16(_frequencyBuffer.count * 2)
                    : Int16(_frequencyBuffer.count)
            print(_globalSetting)

            try _globalSettingRepo.update()
        } catch let error as NSError{
            print("Could not save test settings to global setting.")
            print("\(error), \(error.userInfo)")
        }
    }
}
