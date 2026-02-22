//
//  CDSkinSpot+CoreData.swift
//  Sunny
//
//  Created by Josh Bourke on 21/2/2026.
//

import CoreData

@objc(CDSkinSpot)
public class CDSkinSpot: NSManagedObject {}

extension CDSkinSpot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDSkinSpot> {
        NSFetchRequest<CDSkinSpot>(entityName: "CDSkinSpot")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var notes: String?
    @NSManaged public var createdDate: Date?
    @NSManaged public var lastModified: Date?
    @NSManaged public var bodyPart: String?
    @NSManaged public var subPart: String?
    @NSManaged public var photos: NSSet?
    @NSManaged public var analysisRecord: CDSkinLesionRecord?
}

// MARK: - Photos relationship helpers

extension CDSkinSpot {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: CDSkinSpotPhoto)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: CDSkinSpotPhoto)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)
}
