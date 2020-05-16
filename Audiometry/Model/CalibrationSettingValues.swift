//
//  CalibrationSettingValues+CoreDataProperties.swift
//  
//
//  Created by Xavier Chan on 16/5/20.
//
//

import Foundation
import CoreData

public class CalibrationSettingValues: NSManagedObject {

}

extension CalibrationSettingValues {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CalibrationSettingValues> {
        return NSFetchRequest<CalibrationSettingValues>(entityName: "CalibrationSettingValues")
    }

    @NSManaged public var expectedLevel: Double
    @NSManaged public var frequency: Int16
    @NSManaged public var leftMeasuredLevel: Double
    @NSManaged public var rightMeasuredLevel: Double
    @NSManaged public var presentationLevel: Double
    @NSManaged public var setting: CalibrationSetting?

}
