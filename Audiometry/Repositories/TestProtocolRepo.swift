//
//  TestProtocolRepo.swift
//  Audiometry
//
//  Created by Xavier Chan on 15/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit
import CoreData

class TestProtocolRepo{
    
    private let _managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    func fetchAllTestProtocols() throws -> [TestProtocol]{
        // Setup CoreData fetch
        let request:NSFetchRequest<TestProtocol> =
            TestProtocol.fetchRequest()
        return try _managedContext.fetch(request)
    }
    
    func saveNewTestProtocol(_ newProtocolName: String,
                             _ globalSetting: GlobalSetting
        ) throws -> TestProtocol{
        
        let newProtocol = TestProtocol(context: _managedContext)
        newProtocol.name = newProtocolName
        newProtocol.timestamp = Date()
        newProtocol.frequencySequence = globalSetting.testFrequencySequence
        newProtocol.isTestLeftFirst = globalSetting.isTestingLeft
        newProtocol.isTestBoth = globalSetting.isTestingBoth
        
        try _managedContext.save()
        return newProtocol
    }
    
    func deleteTestProtocol(_ currentTestProtocol:TestProtocol) throws{
        _managedContext.delete(currentTestProtocol)
    }
}
