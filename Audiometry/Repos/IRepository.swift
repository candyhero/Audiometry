//
//  Repository.swift
//  Audiometry
//
//  Created by Xavier Chan on 29/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit
import CoreData

class IRepository<Entity: NSManagedObject> {
    
    internal let _managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    internal init(){
        
    }
    
    func create() throws -> Entity {
        let entity = Entity(context: _managedContext)
        try _managedContext.save()
        return entity
    }
    
    func update() throws {
        try _managedContext.save()
    }
    
    func fetchAll(_ sortDescriptors: [NSSortDescriptor] = []) throws -> [Entity] {
        let request: NSFetchRequest<Entity> = Entity.fetchRequest() as! NSFetchRequest<Entity>
        request.sortDescriptors = sortDescriptors
        return try _managedContext.fetch(request)
    }
    
    func delete<Entity: NSManagedObject>(_ entity: Entity) throws {
        _managedContext.delete(entity)
        try _managedContext.save()
    }
}
