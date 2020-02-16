//
//  GlobalSettingRepo.swift
//  Audiometry
//
//  Created by Xavier Chan on 15/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit
import CoreData

class GlobalSettingRepo: Repository<GlobalSetting> {
    // MARK:
    static let repo = GlobalSettingRepo()

    // MARK:
    func fetchOrCreate() throws -> GlobalSetting
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
}
