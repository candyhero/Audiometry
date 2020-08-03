//
//  PatientProfileService.swift
//  Audiometry
//
//  Created by Xavier Chan on 2/8/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import Foundation

class PatientProfileService: Repository<PatientProfile> {
    
    static let shared: PatientProfileService = PatientProfileService()
    static let sharedProfile: PatientProfile! = nil
    
    override init() {
    }
    
    func createNewPatientProfile(
        model: PatientProfileModel,
        testMode: TestMode,
        testEarOrder: TestEarOrder,
        testFrequencyOrder: [Int]
    ) -> PatientProfile {
        let newProfile = PatientProfile(context: _managedContext)
        newProfile.timestamp = Date()
        
        newProfile.name = model.patientName
        newProfile.group = model.patientGroup
        newProfile.testRole = Int16(model.patientRole.rawValue)
        
        newProfile.testMode = Int16(testMode.rawValue)
        newProfile.testEarOrder = Int16(testEarOrder.rawValue)
        newProfile.testFrequencyOrder = testFrequencyOrder
        
        do {
            try _managedContext.save()
        } catch let error as NSError {
            print("Failed to save new patient profile")
            print(error)
        }
        return newProfile
    }
    
    func fetchAllSortedByTime() throws -> [PatientProfile]{
        let sortByTimestamp = NSSortDescriptor(key: #keyPath(PatientProfile.timestamp),
                                               ascending: false)
        return try self.fetchAll([sortByTimestamp])
    }
    
    func addNewValues() {
        
    }
}
