//
//  PatientProfileRepo.swift
//  Audiometry
//
//  Created by Xavier Chan on 15/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit
import CoreData

class PatientProfileRepo {
    
    private let _managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    // MARK: fetch functions
    func fetchAllPatientProfiles() throws -> [PatientProfile] {
        let request: NSFetchRequest<PatientProfile> = PatientProfile.fetchRequest()
        return try _managedContext.fetch(request)
    }
    
    func fetchAllPatientProfilesSorted() throws -> [PatientProfile] {
        let request: NSFetchRequest<PatientProfile> = PatientProfile.fetchRequest()
        
        let sortByTimestamp = NSSortDescriptor(
            key: #keyPath(PatientProfile.timestamp),
            ascending: false)
        
        request.sortDescriptors = [sortByTimestamp]
        return try _managedContext.fetch(request)
    }
    
    // MARK: validate functions
    func validateAnyPatientProfiles() throws -> Bool {
        return (try self.fetchAllPatientProfiles().count > 0)
    }
}
