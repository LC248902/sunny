//
//  CDSkinReport+CoreData.swift
//  Sunny
//
//  Created by Josh Bourke on 21/2/2026.
//

import CoreData

// MARK: - Managed Object

@objc(CDSkinReport)
public class CDSkinReport: NSManagedObject {}

extension CDSkinReport {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDSkinReport> {
        NSFetchRequest<CDSkinReport>(entityName: "CDSkinReport")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var reportId: String?
    @NSManaged public var createdDate: Date?
    @NSManaged public var pdfPath: String?
    @NSManaged public var filterBodyPart: String?
    @NSManaged public var dateRangeStart: Date?
    @NSManaged public var dateRangeEnd: Date?
    @NSManaged public var totalPhotos: Int32
    @NSManaged public var totalScans: Int32
}

// MARK: - Value Type

struct SkinReport: Identifiable {
    let id: UUID
    let reportId: String
    let createdDate: Date
    let pdfPath: String
    let filterBodyPart: String?
    let dateRangeStart: Date?
    let dateRangeEnd: Date?
    let totalPhotos: Int
    let totalScans: Int
}
