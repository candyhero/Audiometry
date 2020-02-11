//
//  PatientProfileRepo.swift
//  Audiometry
//
//  Created by Xavier Chan on 15/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit
import CoreData

class PatientProfileRepo: IRepository<PatientProfile> {
    
    static let repo = PatientProfileRepo()
    
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
