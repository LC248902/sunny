//
//  CDSkinSpotPhoto+CoreData.swift
//  Sunny
//
//  Created by Josh Bourke on 21/2/2026.
//

import CoreData

@objc(CDSkinSpotPhoto)
public class CDSkinSpotPhoto: NSManagedObject {}

extension CDSkinSpotPhoto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDSkinSpotPhoto> {
        NSFetchRequest<CDSkinSpotPhoto>(entityName: "CDSkinSpotPhoto")
    }

    @NSManaged public var id: UUID?
    /// Relative path within Documents/SunnyData/ — e.g. "Images/{spotId}/{photoId}.jpg"
    @NSManaged public var imagePath: String?
    @NSManaged public var dateTaken: Date?
    @NSManaged public var notes: String?
    @NSManaged public var spot: CDSkinSpot?
}
