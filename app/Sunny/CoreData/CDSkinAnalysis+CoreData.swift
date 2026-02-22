//
//  CDSkinAnalysis+CoreData.swift
//  Sunny
//
//  Created by Josh Bourke on 21/2/2026.
//

import CoreData

@objc(CDSkinAnalysis)
public class CDSkinAnalysis: NSManagedObject {}

extension CDSkinAnalysis {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDSkinAnalysis> {
        NSFetchRequest<CDSkinAnalysis>(entityName: "CDSkinAnalysis")
    }

    @NSManaged public var lesionType: String?
    @NSManaged public var color: String?
    @NSManaged public var symmetry: String?
    @NSManaged public var borders: String?
    @NSManaged public var texture: String?
    @NSManaged public var summary: String?
    @NSManaged public var record: CDSkinLesionRecord?
}
