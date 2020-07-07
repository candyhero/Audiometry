//
//  TestProtocolService.swift
//  Audiometry
//
//  Created by Xavier Chan on 8/7/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import Foundation

class TestProtocolService: Repository<TestProtocol> {
    
    static let shared: CalibrationSettingService = CalibrationSettingService()
    
    override init() {
    }
    
    func createNewTestProtocol(name: String) -> TestProtocol {
        let newProtocol = TestProtocol(context: _managedContext)
        newProtocol.name = name
        newProtocol.timestamp = Date()
        
        do {
            try _managedContext.save()
        } catch let error as NSError {
            print("Failed to save new test protocol")
            print(error)
        }
        return newProtocol
    }
    
    func fetchAllSortedByTime() throws -> [TestProtocol]{
        let sortByTimestamp = NSSortDescriptor(key: #keyPath(TestProtocol.timestamp),
                                               ascending: false)
        return try self.fetchAll([sortByTimestamp])
    }
}
