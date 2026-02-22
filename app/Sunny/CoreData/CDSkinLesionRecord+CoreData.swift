//
//  CDSkinLesionRecord+CoreData.swift
//  Sunny
//
//  Created by Josh Bourke on 21/2/2026.
//

import CoreData

@objc(CDSkinLesionRecord)
public class CDSkinLesionRecord: NSManagedObject {}

extension CDSkinLesionRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDSkinLesionRecord> {
        NSFetchRequest<CDSkinLesionRecord>(entityName: "CDSkinLesionRecord")
    }

    @NSManaged public var id: String?
    @NSManaged public var imagePath: String?
    @NSManaged public var timestamp: String?
    @NSManaged public var latency: String?
    @NSManaged public var analysis: CDSkinAnalysis?
    @NSManaged public var spot: CDSkinSpot?
}
