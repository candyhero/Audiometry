//
//  GlobalSettingRepo.swift
//  Audiometry
//
//  Created by Xavier Chan on 15/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit
import CoreData

class GlobalSettingRepo {
    
    private let _managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    func fetchGlobalSetting() throws -> GlobalSetting
    {
        let request:NSFetchRequest<GlobalSetting> =
            GlobalSetting.fetchRequest()
        request.fetchLimit = 1
    
        guard let setting = try _managedContext.fetch(request).first
        else {
            let newSetting = GlobalSetting(context: _managedContext)
            try _managedContext.save()
            return newSetting
        }
        return setting
    }
    
    func update(_ setting: GlobalSetting) throws -> GlobalSetting {
        try _managedContext.save()
        return setting
    }
}
