//
//  FileManagerService.swift
//  Sunny
//
//  Created by Josh Bourke on 21/2/2026.
//

import Foundation

@Observable
final class FileManagerService {

    private let fm = FileManager.default

    // MARK: - Base Directories

    private var sunnyDataURL: URL {
        fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SunnyData", isDirectory: true)
    }

    private var imagesURL: URL {
        sunnyDataURL.appendingPathComponent("Images", isDirectory: true)
    }

    private var pdfsURL: URL {
        sunnyDataURL.appendingPathComponent("PDFs", isDirectory: true)
    }

    // MARK: - Init

    init() {
        createDirectoriesIfNeeded()
    }

    private func createDirectoriesIfNeeded() {
        [sunnyDataURL, imagesURL, pdfsURL].forEach { url in
            guard !fm.fileExists(atPath: url.path) else { return }
            try? fm.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    // MARK: - Images

    /// Saves image data to `Documents/SunnyData/Images/{spotId}/{photoId}.jpg`.
    /// - Returns: A relative path string suitable for storage in CoreData.
    @discardableResult
    func saveImage(_ data: Data, spotId: UUID, photoId: UUID) throws -> String {
        let spotFolder = imagesURL.appendingPathComponent(spotId.uuidString, isDirectory: true)
        if !fm.fileExists(atPath: spotFolder.path) {
            try fm.createDirectory(at: spotFolder, withIntermediateDirectories: true)
        }
        let fileName = "\(photoId.uuidString).jpg"
        let fileURL = spotFolder.appendingPathComponent(fileName)
        try data.write(to: fileURL, options: .atomic)
        return "Images/\(spotId.uuidString)/\(fileName)"
    }

    /// Loads image data from a relative path previously returned by `saveImage`.
    func loadImage(at relativePath: String) -> Data? {
        let fullURL = sunnyDataURL.appendingPathComponent(relativePath)
        return try? Data(contentsOf: fullURL)
    }

    /// Deletes a single image file at the given relative path.
    func deleteImage(at relativePath: String) {
        let fullURL = sunnyDataURL.appendingPathComponent(relativePath)
        try? fm.removeItem(at: fullURL)
    }

    /// Deletes the entire folder for a skin spot (all its photos).
    func deleteAllImages(forSpotId spotId: UUID) {
        let spotFolder = imagesURL.appendingPathComponent(spotId.uuidString)
        try? fm.removeItem(at: spotFolder)
    }

    // MARK: - PDFs

    /// Saves PDF data to `Documents/SunnyData/PDFs/{name}.pdf`.
    /// - Returns: A relative path string suitable for storage.
    @discardableResult
    func savePDF(_ data: Data, named name: String) throws -> String {
        let fileName = name.hasSuffix(".pdf") ? name : "\(name).pdf"
        let fileURL = pdfsURL.appendingPathComponent(fileName)
        try data.write(to: fileURL, options: .atomic)
        return "PDFs/\(fileName)"
    }

    /// Loads PDF data from a relative path.
    func loadPDF(at relativePath: String) -> Data? {
        let fullURL = sunnyDataURL.appendingPathComponent(relativePath)
        return try? Data(contentsOf: fullURL)
    }

    /// Returns all PDF file URLs in the PDFs directory.
    func listPDFs() -> [URL] {
        (try? fm.contentsOfDirectory(at: pdfsURL, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles)) ?? []
    }

    /// Deletes a PDF at the given relative path.
    func deletePDF(at relativePath: String) {
        let fullURL = sunnyDataURL.appendingPathComponent(relativePath)
        try? fm.removeItem(at: fullURL)
    }

    /// Returns the absolute URL for a given relative path (for sharing or opening).
    func fullURL(for relativePath: String) -> URL {
        sunnyDataURL.appendingPathComponent(relativePath)
    }
}
