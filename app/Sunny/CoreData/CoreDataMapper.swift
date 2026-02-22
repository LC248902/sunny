//
//  CoreDataMapper.swift
//  Sunny
//
//  Created by Josh Bourke on 21/2/2026.
//

import CoreData

/// Converts between CoreData managed objects and Swift value types.
/// Images are loaded from FileManagerService into the transient `imageData` field
/// so that views that read `photo.imageData` work without modification.
enum CoreDataMapper {

    // MARK: - CoreData → Value Types

    static func toSkinSpot(_ cd: CDSkinSpot, fileManager: FileManagerService) -> SkinSpot? {
        guard
            let id = cd.id,
            let title = cd.title,
            let createdDate = cd.createdDate,
            let lastModified = cd.lastModified,
            let bodyPartRaw = cd.bodyPart,
            let bodyPart = BodyPart(rawValue: bodyPartRaw)
        else { return nil }

        let subPart = cd.subPart.flatMap { BodySubPart(rawValue: $0) }

        let photos: [SkinSpotPhoto] = (cd.photos as? Set<CDSkinSpotPhoto>)?
            .compactMap { toSkinSpotPhoto($0, fileManager: fileManager) }
            .sorted { $0.dateTaken < $1.dateTaken } ?? []

        let analysisRecord: SkinLesionRecord? = cd.analysisRecord.flatMap { toSkinLesionRecord($0) }

        return SkinSpot(
            id: id,
            title: title,
            notes: cd.notes,
            photos: photos,
            createdDate: createdDate,
            lastModified: lastModified,
            bodyPart: bodyPart,
            subPart: subPart,
            analysisRecord: analysisRecord
        )
    }

    static func toSkinSpotPhoto(_ cd: CDSkinSpotPhoto, fileManager: FileManagerService) -> SkinSpotPhoto? {
        guard
            let id = cd.id,
            let dateTaken = cd.dateTaken
        else { return nil }

        let imageData = cd.imagePath.flatMap { fileManager.loadImage(at: $0) }

        return SkinSpotPhoto(
            id: id,
            imagePath: cd.imagePath,
            imageData: imageData,
            dateTaken: dateTaken,
            notes: cd.notes
        )
    }

    static func toSkinLesionRecord(_ cd: CDSkinLesionRecord) -> SkinLesionRecord? {
        guard
            let id = cd.id,
            let imagePath = cd.imagePath,
            let timestamp = cd.timestamp,
            let cdAnalysis = cd.analysis,
            let analysis = toSkinAnalysis(cdAnalysis)
        else { return nil }

        return SkinLesionRecord(
            id: id,
            imagePath: imagePath,
            timestamp: timestamp,
            analysis: analysis,
            latency: cd.latency
        )
    }

    static func toSkinAnalysis(_ cd: CDSkinAnalysis) -> SkinAnalysis? {
        guard
            let lesionType = cd.lesionType,
            let color = cd.color,
            let symmetry = cd.symmetry,
            let borders = cd.borders,
            let texture = cd.texture,
            let summary = cd.summary
        else { return nil }

        return SkinAnalysis(
            lesionType: lesionType,
            color: color,
            symmetry: symmetry,
            borders: borders,
            texture: texture,
            summary: summary
        )
    }

    static func toBodyPartStatus(_ cd: CDBodyPartStatus) -> (key: String, status: BodyPartStatus)? {
        guard
            let bodyPartRaw = cd.bodyPart,
            let bodyPart = BodyPart(rawValue: bodyPartRaw),
            let scanStatusRaw = cd.scanStatus,
            let scanStatus = ScanStatus(rawValue: scanStatusRaw)
        else { return nil }

        let subPart = cd.subPart.flatMap { BodySubPart(rawValue: $0) }
        let key: String = subPart != nil
            ? "\(bodyPartRaw)-\(subPart!.rawValue)"
            : bodyPartRaw

        let status = BodyPartStatus(
            bodyPart: bodyPart,
            subPart: subPart,
            scanStatus: scanStatus,
            photoCount: Int(cd.photoCount),
            lastScanned: cd.lastScanned
        )

        return (key, status)
    }

    // MARK: - Value Types → CoreData

    /// Populates a CDSkinSpot from a SkinSpot value. Photo image data must be
    /// persisted separately via FileManagerService before calling this.
    static func populate(_ cd: CDSkinSpot, from spot: SkinSpot, context: NSManagedObjectContext) {
        cd.id = spot.id
        cd.title = spot.title
        cd.notes = spot.notes
        cd.createdDate = spot.createdDate
        cd.lastModified = spot.lastModified
        cd.bodyPart = spot.bodyPart.rawValue
        cd.subPart = spot.subPart?.rawValue
    }

    static func makeCDPhoto(from photo: SkinSpotPhoto, imagePath: String?, context: NSManagedObjectContext) -> CDSkinSpotPhoto {
        let cdPhoto = CDSkinSpotPhoto(context: context)
        cdPhoto.id = photo.id
        cdPhoto.imagePath = imagePath
        cdPhoto.dateTaken = photo.dateTaken
        cdPhoto.notes = photo.notes
        return cdPhoto
    }

    static func makeCDAnalysisRecord(from record: SkinLesionRecord, context: NSManagedObjectContext) -> CDSkinLesionRecord {
        let cdRecord = CDSkinLesionRecord(context: context)
        cdRecord.id = record.id
        cdRecord.imagePath = record.imagePath
        cdRecord.timestamp = record.timestamp
        cdRecord.latency = record.latency

        let cdAnalysis = CDSkinAnalysis(context: context)
        cdAnalysis.lesionType = record.analysis.lesionType
        cdAnalysis.color = record.analysis.color
        cdAnalysis.symmetry = record.analysis.symmetry
        cdAnalysis.borders = record.analysis.borders
        cdAnalysis.texture = record.analysis.texture
        cdAnalysis.summary = record.analysis.summary
        cdRecord.analysis = cdAnalysis

        return cdRecord
    }

    // MARK: - CDSkinReport

    static func toSkinReport(_ cd: CDSkinReport) -> SkinReport? {
        guard
            let id = cd.id,
            let reportId = cd.reportId,
            let createdDate = cd.createdDate,
            let pdfPath = cd.pdfPath
        else { return nil }

        return SkinReport(
            id: id,
            reportId: reportId,
            createdDate: createdDate,
            pdfPath: pdfPath,
            filterBodyPart: cd.filterBodyPart,
            dateRangeStart: cd.dateRangeStart,
            dateRangeEnd: cd.dateRangeEnd,
            totalPhotos: Int(cd.totalPhotos),
            totalScans: Int(cd.totalScans)
        )
    }

    @discardableResult
    static func makeCDReport(from report: SkinReport, context: NSManagedObjectContext) -> CDSkinReport {
        let cd = CDSkinReport(context: context)
        cd.id = report.id
        cd.reportId = report.reportId
        cd.createdDate = report.createdDate
        cd.pdfPath = report.pdfPath
        cd.filterBodyPart = report.filterBodyPart
        cd.dateRangeStart = report.dateRangeStart
        cd.dateRangeEnd = report.dateRangeEnd
        cd.totalPhotos = Int32(report.totalPhotos)
        cd.totalScans = Int32(report.totalScans)
        return cd
    }

    static func upsertCDBodyPartStatus(
        bodyPart: BodyPart,
        subPart: BodySubPart?,
        status: BodyPartStatus,
        context: NSManagedObjectContext
    ) {
        let request = CDBodyPartStatus.fetchRequest()
        request.predicate = NSPredicate(
            format: "bodyPart == %@ AND subPart == %@",
            bodyPart.rawValue,
            subPart?.rawValue ?? ""
        )
        request.fetchLimit = 1

        let existing = (try? context.fetch(request))?.first ?? CDBodyPartStatus(context: context)
        existing.bodyPart = bodyPart.rawValue
        existing.subPart = subPart?.rawValue
        existing.scanStatus = status.scanStatus.rawValue
        existing.photoCount = Int32(status.photoCount)
        existing.lastScanned = status.lastScanned
    }
}
