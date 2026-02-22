//
//  SkinSpotService.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI
import CoreData

@Observable
class SkinSpotService {

    // MARK: - Properties

    /// Dictionary tracking status of each body part and sub-part combination.
    /// Key format: "bodyPart" or "bodyPart-subPart"
    var bodyPartStatus: [String: BodyPartStatus] = [:]

    /// All skin spots organised by their full identifier key.
    var skinSpots: [String: [SkinSpot]] = [:]

    // MARK: - Dependencies

    private let context: NSManagedObjectContext
    private let fileManager: FileManagerService

    // MARK: - Initialization

    init(context: NSManagedObjectContext, fileManager: FileManagerService) {
        self.context = context
        self.fileManager = fileManager

        // Seed default body part statuses for top-level parts
        for bodyPart in BodyPart.allCases {
            let key = makeKey(bodyPart: bodyPart, subPart: nil)
            bodyPartStatus[key] = BodyPartStatus(bodyPart: bodyPart)
        }

        loadData()
    }

    // MARK: - Helper Methods

    private func makeKey(bodyPart: BodyPart, subPart: BodySubPart?) -> String {
        if let subPart {
            return "\(bodyPart.rawValue)-\(subPart.rawValue)"
        }
        return bodyPart.rawValue
    }

    // MARK: - Body Part Methods

    func getStatus(for bodyPart: BodyPart, subPart: BodySubPart? = nil) -> BodyPartStatus {
        let key = makeKey(bodyPart: bodyPart, subPart: subPart)
        return bodyPartStatus[key] ?? BodyPartStatus(bodyPart: bodyPart, subPart: subPart)
    }

    func updateStatus(for bodyPart: BodyPart, subPart: BodySubPart? = nil, status: BodyPartStatus) {
        let key = makeKey(bodyPart: bodyPart, subPart: subPart)
        bodyPartStatus[key] = status
        saveBodyPartStatus(bodyPart: bodyPart, subPart: subPart, status: status)
    }

    func getPhotoCount(for bodyPart: BodyPart, subPart: BodySubPart? = nil) -> Int {
        let key = makeKey(bodyPart: bodyPart, subPart: subPart)
        return skinSpots[key]?.count ?? 0
    }

    func getTotalPhotoCount(for bodyPart: BodyPart) -> Int {
        var total = getPhotoCount(for: bodyPart, subPart: nil)
        for subPart in bodyPart.subParts {
            total += getPhotoCount(for: bodyPart, subPart: subPart)
        }
        return total
    }

    func needsUpdate(_ bodyPart: BodyPart, subPart: BodySubPart? = nil) -> Bool {
        let key = makeKey(bodyPart: bodyPart, subPart: subPart)
        guard let lastScanned = bodyPartStatus[key]?.lastScanned else { return false }
        let days = Calendar.current.dateComponents([.day], from: lastScanned, to: Date()).day ?? 0
        return days > 30
    }

    func getScannedSubParts(for bodyPart: BodyPart) -> [BodySubPart] {
        bodyPart.subParts.filter { getStatus(for: bodyPart, subPart: $0).scanStatus == .scanned }
    }

    func getAggregatedStatus(for bodyPart: BodyPart) -> ScanStatus {
        let subParts = bodyPart.subParts
        let scannedCount = subParts.filter { getStatus(for: bodyPart, subPart: $0).scanStatus == .scanned }.count

        if scannedCount == 0 { return .notScanned }
        return .scanned
    }

    // MARK: - Skin Spot Methods

    func addSkinSpot(_ spot: SkinSpot, to bodyPart: BodyPart, subPart: BodySubPart? = nil) {
        let key = makeKey(bodyPart: bodyPart, subPart: subPart)

        let persistedPhotos = spot.photos.map { photo -> SkinSpotPhoto in
            guard let data = photo.imageData else { return photo }
            let path = try? fileManager.saveImage(data, spotId: spot.id, photoId: photo.id)
            return SkinSpotPhoto(
                id: photo.id,
                imagePath: path,
                imageData: photo.imageData,
                dateTaken: photo.dateTaken,
                notes: photo.notes
            )
        }

        let persistedSpot = SkinSpot(
            id: spot.id,
            title: spot.title,
            notes: spot.notes,
            photos: persistedPhotos,
            createdDate: spot.createdDate,
            lastModified: spot.lastModified,
            bodyPart: spot.bodyPart,
            subPart: spot.subPart,
            analysisRecord: spot.analysisRecord
        )

        if skinSpots[key] == nil { skinSpots[key] = [] }
        skinSpots[key]?.append(persistedSpot)

        let photoCount = skinSpots[key]?.count ?? 0
        let newStatus = BodyPartStatus(
            bodyPart: bodyPart,
            subPart: subPart,
            scanStatus: .scanned,
            photoCount: photoCount,
            lastScanned: Date()
        )
        bodyPartStatus[key] = newStatus

        // Persist to CoreData
        saveSkinSpot(persistedSpot)
        saveBodyPartStatus(bodyPart: bodyPart, subPart: subPart, status: newStatus)
        PersistenceController.shared.save(context: context)
    }

    func getSkinSpots(for bodyPart: BodyPart, subPart: BodySubPart? = nil) -> [SkinSpot] {
        let key = makeKey(bodyPart: bodyPart, subPart: subPart)
        return skinSpots[key] ?? []
    }

    func getAllSkinSpots(for bodyPart: BodyPart) -> [SkinSpot] {
        var allSpots = getSkinSpots(for: bodyPart, subPart: nil)
        for subPart in bodyPart.subParts {
            allSpots.append(contentsOf: getSkinSpots(for: bodyPart, subPart: subPart))
        }
        return allSpots
    }

    func updateSkinSpot(_ updatedSpot: SkinSpot, oldBodyPart: BodyPart, oldSubPart: BodySubPart?) {
        let oldKey = makeKey(bodyPart: oldBodyPart, subPart: oldSubPart)
        let newKey = makeKey(bodyPart: updatedSpot.bodyPart, subPart: updatedSpot.subPart)

        // Remove from old key
        skinSpots[oldKey]?.removeAll { $0.id == updatedSpot.id }

        if skinSpots[newKey] == nil { skinSpots[newKey] = [] }
        skinSpots[newKey]?.append(updatedSpot)

        if oldKey != newKey {
            let oldCount = skinSpots[oldKey]?.count ?? 0
            if var oldStatus = bodyPartStatus[oldKey] {
                oldStatus.photoCount = oldCount
                if oldCount == 0 {
                    oldStatus.scanStatus = .notScanned
                    oldStatus.lastScanned = nil
                }
                bodyPartStatus[oldKey] = oldStatus
                saveBodyPartStatus(bodyPart: oldBodyPart, subPart: oldSubPart, status: oldStatus)
            }
        }

        let newCount = skinSpots[newKey]?.count ?? 0
        let newStatus = BodyPartStatus(
            bodyPart: updatedSpot.bodyPart,
            subPart: updatedSpot.subPart,
            scanStatus: .scanned,
            photoCount: newCount,
            lastScanned: bodyPartStatus[newKey]?.lastScanned ?? updatedSpot.lastModified
        )
        bodyPartStatus[newKey] = newStatus
        saveBodyPartStatus(bodyPart: updatedSpot.bodyPart, subPart: updatedSpot.subPart, status: newStatus)

        updateCDSkinSpot(updatedSpot)
        PersistenceController.shared.save(context: context)
    }

    func deleteSkinSpot(_ spot: SkinSpot, from bodyPart: BodyPart, subPart: BodySubPart? = nil) {
        let key = makeKey(bodyPart: bodyPart, subPart: subPart)
        skinSpots[key]?.removeAll { $0.id == spot.id }

        let photoCount = skinSpots[key]?.count ?? 0
        if var status = bodyPartStatus[key] {
            status.photoCount = photoCount
            if photoCount == 0 {
                status.scanStatus = .notScanned
                status.lastScanned = nil
            }
            bodyPartStatus[key] = status
            saveBodyPartStatus(bodyPart: bodyPart, subPart: subPart, status: status)
        }

        // Delete files and CoreData record
        fileManager.deleteAllImages(forSpotId: spot.id)
        deleteCDSkinSpot(id: spot.id)
        PersistenceController.shared.save(context: context)
    }

    // MARK: - Statistics

    var allSkinSpots: [SkinSpot] {
        skinSpots.values
            .flatMap { $0 }
            .sorted { $0.createdDate > $1.createdDate }
    }

    var scannedBodyPartsCount: Int {
        bodyPartStatus.values.filter { $0.scanStatus == .scanned }.count
    }

    var scannedTopLevelBodyPartsCount: Int {
        BodyPart.allCases.filter { getAggregatedStatus(for: $0) == .scanned }.count
    }

    var needsUpdateCount: Int {
        bodyPartStatus.values.filter { status in
            guard let lastScanned = status.lastScanned else { return false }
            let days = Calendar.current.dateComponents([.day], from: lastScanned, to: Date()).day ?? 0
            return days > 30
        }.count
    }

    var totalPhotoCount: Int {
        bodyPartStatus.values.reduce(0) { $0 + $1.photoCount }
    }

    var completionPercentage: Double {
        let total = BodyPart.allCases.count
        guard total > 0 else { return 0 }
        return Double(scannedTopLevelBodyPartsCount) / Double(total) * 100.0
    }

    // MARK: - CoreData: Load

    private func loadData() {
        loadBodyPartStatuses()
        loadSkinSpots()
    }

    private func loadBodyPartStatuses() {
        let request = CDBodyPartStatus.fetchRequest()
        guard let results = try? context.fetch(request) else { return }

        for cdStatus in results {
            if let (key, status) = CoreDataMapper.toBodyPartStatus(cdStatus) {
                bodyPartStatus[key] = status
            }
        }
    }

    private func loadSkinSpots() {
        let request = CDSkinSpot.fetchRequest()
        guard let results = try? context.fetch(request) else { return }

        for cdSpot in results {
            guard let spot = CoreDataMapper.toSkinSpot(cdSpot, fileManager: fileManager) else { continue }
            let key = makeKey(bodyPart: spot.bodyPart, subPart: spot.subPart)
            if skinSpots[key] == nil { skinSpots[key] = [] }
            skinSpots[key]?.append(spot)
        }
    }

    // MARK: - CoreData: Save

    private func saveSkinSpot(_ spot: SkinSpot) {
        let cdSpot = CDSkinSpot(context: context)
        CoreDataMapper.populate(cdSpot, from: spot, context: context)

        for photo in spot.photos {
            let cdPhoto = CoreDataMapper.makeCDPhoto(from: photo, imagePath: photo.imagePath, context: context)
            cdPhoto.spot = cdSpot
            cdSpot.addToPhotos(cdPhoto)
        }

        if let record = spot.analysisRecord {
            let cdRecord = CoreDataMapper.makeCDAnalysisRecord(from: record, context: context)
            cdRecord.spot = cdSpot
            cdSpot.analysisRecord = cdRecord
        }
    }

    private func saveBodyPartStatus(bodyPart: BodyPart, subPart: BodySubPart?, status: BodyPartStatus) {
        CoreDataMapper.upsertCDBodyPartStatus(
            bodyPart: bodyPart,
            subPart: subPart,
            status: status,
            context: context
        )
    }

    // MARK: - CoreData: Update

    private func updateCDSkinSpot(_ spot: SkinSpot) {
        let request = CDSkinSpot.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", spot.id as CVarArg)
        request.fetchLimit = 1

        guard let cdSpot = (try? context.fetch(request))?.first else { return }
        cdSpot.title = spot.title
        cdSpot.notes = spot.notes
        cdSpot.bodyPart = spot.bodyPart.rawValue
        cdSpot.subPart = spot.subPart?.rawValue
        cdSpot.lastModified = spot.lastModified
    }

    // MARK: - CoreData: Delete

    private func deleteCDSkinSpot(id: UUID) {
        let request = CDSkinSpot.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        if let cdSpot = (try? context.fetch(request))?.first {
            context.delete(cdSpot)
        }
    }

    // MARK: - Reset

    func reset() {
        bodyPartStatus.removeAll()
        skinSpots.removeAll()

        for bodyPart in BodyPart.allCases {
            let key = makeKey(bodyPart: bodyPart, subPart: nil)
            bodyPartStatus[key] = BodyPartStatus(bodyPart: bodyPart)
        }
    }
}

// MARK: - Convenience Extension

extension SkinSpotService {
    func getSpotsCount(for bodyPart: BodyPart, subPart: BodySubPart? = nil) -> Int {
        let key = makeKey(bodyPart: bodyPart, subPart: subPart)
        return skinSpots[key]?.count ?? 0
    }

    func getSpots(for bodyPart: BodyPart, subPart: BodySubPart? = nil) -> [SkinSpot] {
        let key = makeKey(bodyPart: bodyPart, subPart: subPart)
        return skinSpots[key] ?? []
    }
}

// MARK: - SkinSpot Model

struct SkinSpot: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var notes: String?
    var photos: [SkinSpotPhoto]
    var createdDate: Date
    var lastModified: Date
    var bodyPart: BodyPart
    var subPart: BodySubPart?
    var analysisRecord: SkinLesionRecord?

    init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        photos: [SkinSpotPhoto] = [],
        createdDate: Date = Date(),
        lastModified: Date = Date(),
        bodyPart: BodyPart,
        subPart: BodySubPart? = nil,
        analysisRecord: SkinLesionRecord? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.photos = photos
        self.createdDate = createdDate
        self.lastModified = lastModified
        self.bodyPart = bodyPart
        self.subPart = subPart
        self.analysisRecord = analysisRecord
    }
}

// MARK: - SkinSpotPhoto Model

struct SkinSpotPhoto: Identifiable, Codable, Hashable {
    let id: UUID
    /// Relative path within Documents/SunnyData/ — persisted in CoreData.
    var imagePath: String?
    /// Image bytes loaded from FileManagerService at fetch time — not persisted directly.
    var imageData: Data?
    var dateTaken: Date
    var notes: String?

    init(
        id: UUID = UUID(),
        imagePath: String? = nil,
        imageData: Data? = nil,
        dateTaken: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.imagePath = imagePath
        self.imageData = imageData
        self.dateTaken = dateTaken
        self.notes = notes
    }
}
