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
    
    static let repo = PatientProfileRepo()

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
    
    func fetchAllSorted() throws -> [PatientProfile] {
        let sortByTimestamp = NSSortDescriptor(
            key: #keyPath(PatientProfile.timestamp),
            ascending: false)
        return try self.fetchAll([sortByTimestamp])
    }
    
    // MARK: validate functions
    func validateAnyPatientProfiles() throws -> Bool {
        return (try self.fetchAll().count > 0)
    }
}
