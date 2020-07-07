//
//  TestProtocolService.swift
//  Audiometry
//
//  Created by Xavier Chan on 8/7/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import Foundation

class TestProtocolService: Repository<TestProtocol> {
    
    static let shared: TestProtocolService = TestProtocolService()
    
    override init() {
    }
    
    func createNewTestProtocol(
        name: String,
        frequencyOrder: [Int],
        earOrder: TestEarOrder
    ) -> TestProtocol {
        let newProtocol = TestProtocol(context: _managedContext)
        newProtocol.name = name
        newProtocol.testFrequencyOrder = frequencyOrder
        newProtocol.testEarOrder = Int16(earOrder.rawValue)
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
