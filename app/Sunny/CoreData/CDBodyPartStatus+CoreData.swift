//
//  CDBodyPartStatus+CoreData.swift
//  Sunny
//
//  Created by Josh Bourke on 21/2/2026.
//

import CoreData

@objc(CDBodyPartStatus)
public class CDBodyPartStatus: NSManagedObject {}

extension CDBodyPartStatus {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDBodyPartStatus> {
        NSFetchRequest<CDBodyPartStatus>(entityName: "CDBodyPartStatus")
    }

    @NSManaged public var bodyPart: String?
    @NSManaged public var subPart: String?
    @NSManaged public var scanStatus: String?
    @NSManaged public var photoCount: Int32
    @NSManaged public var lastScanned: Date?
}
