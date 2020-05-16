//
//  CalibrationSetting+CoreDataProperties.swift
//  
//
//  Created by Xavier Chan on 16/5/20.
//
//

import Foundation
import CoreData

public class CalibrationSetting: NSManagedObject {

}

extension CalibrationSetting {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CalibrationSetting> {
        return NSFetchRequest<CalibrationSetting>(entityName: "CalibrationSetting")
    }

    @NSManaged public var name: String?
    @NSManaged public var timestamp: Date?
//    @NSManaged public var globalSetting: GlobalSetting?
    @NSManaged public var values: NSOrderedSet?

}

// MARK: Generated accessors for values
extension CalibrationSetting {

    @objc(insertObject:inValuesAtIndex:)
    @NSManaged public func insertIntoValues(_ value: CalibrationSettingValues, at idx: Int)

    @objc(removeObjectFromValuesAtIndex:)
    @NSManaged public func removeFromValues(at idx: Int)

    @objc(insertValues:atIndexes:)
    @NSManaged public func insertIntoValues(_ values: [CalibrationSettingValues], at indexes: NSIndexSet)

    @objc(removeValuesAtIndexes:)
    @NSManaged public func removeFromValues(at indexes: NSIndexSet)

    @objc(replaceObjectInValuesAtIndex:withObject:)
    @NSManaged public func replaceValues(at idx: Int, with value: CalibrationSettingValues)

    @objc(replaceValuesAtIndexes:withValues:)
    @NSManaged public func replaceValues(at indexes: NSIndexSet, with values: [CalibrationSettingValues])

    @objc(addValuesObject:)
    @NSManaged public func addToValues(_ value: CalibrationSettingValues)

    @objc(removeValuesObject:)
    @NSManaged public func removeFromValues(_ value: CalibrationSettingValues)

    @objc(addValues:)
    @NSManaged public func addToValues(_ values: NSOrderedSet)

    @objc(removeValues:)
    @NSManaged public func removeFromValues(_ values: NSOrderedSet)

}
