//
//  PatientProfileRepo.swift
//  Audiometry
//
//  Created by Xavier Chan on 15/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit
import CoreData

class PatientProfileRepo: Repository<PatientProfile> {
    // MARK:
    static let repo = PatientProfileRepo()
    // MARK:
    func createNewProfile(_ frequencyBuffer: [Int]) -> PatientProfile {
        let profile = PatientProfile(context: _managedContext)
        profile.frequencyOrder = frequencyBuffer
        for frequency in frequencyBuffer {
            let values = PatientProfileValues(context: _managedContext)
            values.frequency = Int16(frequency)
            profile.addToValues(values)
        }
        return profile
    }

    func createValues() -> PatientProfileValues{
        return PatientProfileValues(context: _managedContext)
    }
    
    func fetchAllSorted() throws -> [PatientProfile] {
        let sortByTimestamp = NSSortDescriptor(
            key: #keyPath(PatientProfile.timestamp),
            ascending: false)
        return try fetchAll([sortByTimestamp])
    }
    
    // MARK: validate functions
    func validateAnyPatientProfiles() throws -> Bool {
        var profiles = try fetchAll()

        for emptyProfile in profiles.filter({$0.values?.count == 0}){
            _managedContext.delete(emptyProfile)
        }
        profiles.removeAll(where: {$0.values?.count == 0})
        return profiles.isNotEmpty
    }
}
