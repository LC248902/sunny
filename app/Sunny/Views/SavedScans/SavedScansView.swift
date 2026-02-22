//
//  SavedScansView.swift
//  Sunny
//
//  Created by Josh Bourke on 20/2/2026.
//

import SwiftUI
import CoreData

// MARK: - Scan Filter

enum ScanFilter: String, CaseIterable, Identifiable {
    case all    = "All"
    case head   = "Head"
    case arms   = "Arms"
    case torso  = "Torso"
    case legs   = "Legs"

    var id: Self { self }

    var bodyParts: [BodyPart]? {
        switch self {
        case .all:   return nil
        case .head:  return [.head]
        case .arms:  return [.leftArm, .rightArm]
        case .torso: return [.torso]
        case .legs:  return [.leftLeg, .rightLeg]
        }
    }
}

// MARK: - Saved Scans View

struct SavedScansView: View {

    @Environment(SkinSpotService.self)
    private var skinSpotService

    @Environment(FileManagerService.self)
    private var fileManagerService

    @Environment(\.managedObjectContext)
    private var viewContext

    @State private var activeFilter: ScanFilter = .all

    // MARK: - Row Delete State

    @State private var spotPendingDelete: SkinSpot? = nil
    @State private var showRowDeleteConfirmation = false

    // MARK: - Report State

    @State private var showReportOptions = false
    @State private var isGeneratingReport = false
    @State private var generatedReportURL: URL?
    @State private var showReportSuccess = false
    @State private var showReportError = false
    @State private var reportErrorMessage = ""
    @State private var showShareSheet = false

    private var filteredSpots: [SkinSpot] {
        guard let parts = activeFilter.bodyParts else {
            return skinSpotService.allSkinSpots
        }
        return skinSpotService.allSkinSpots.filter { parts.contains($0.bodyPart) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if skinSpotService.allSkinSpots.isEmpty {
                    emptyState
                } else {
                    scanList
                }
            }
            .backgroundViewModifier()
            .navigationTitle("Saved Scans")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: SkinSpot.self) { spot in
                SavedScanDetailView(spot: spot)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showReportOptions = true
                    } label: {
                        Image(systemName: "doc.text")
                    }
                    .disabled(skinSpotService.allSkinSpots.isEmpty)
                }
            }
            .sheet(isPresented: $showReportOptions) {
                ReportOptionsView(initialFilter: activeFilter) { filter, dateRange in
                    generateReport(filter: filter, dateRange: dateRange)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = generatedReportURL {
                    ActivityShareSheet(items: [url])
                        .presentationDetents([.medium, .large])
                }
            }
            .alert("Report Saved", isPresented: $showReportSuccess) {
                Button("Share") { showShareSheet = true }
                Button("Done", role: .cancel) {}
            } message: {
                Text("Your skin examination report has been saved to your device.")
            }
            .alert("Report Failed", isPresented: $showReportError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(reportErrorMessage)
            }
            .overlay {
                if isGeneratingReport {
                    generatingOverlay
                }
            }
        }
    }

    // MARK: - Generating Overlay

    @ViewBuilder
    private var generatingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            VStack(spacing: 14) {
                ProgressView()
                    .tint(.primary)
                Text("Generating Report…")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(28)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
        }
    }

    // MARK: - Report Generation

    private func generateReport(filter: ScanFilter, dateRange: ClosedRange<Date>?) {
        var spots = skinSpotService.allSkinSpots
        if let parts = filter.bodyParts {
            spots = spots.filter { parts.contains($0.bodyPart) }
        }
        if let range = dateRange {
            spots = spots.filter { range.contains($0.createdDate) }
        }
        guard !spots.isEmpty else { return }

        isGeneratingReport = true

        let capturedSpots = spots
        let capturedFileManager = fileManagerService
        let capturedContext = viewContext
        let filterLabel = filter == .all ? nil : filter.rawValue
        let rangeStart = dateRange?.lowerBound
        let rangeEnd = dateRange?.upperBound
        let photoCount = spots.reduce(0) { $0 + $1.photos.count }
        let scanCount = spots.count

        Task.detached(priority: .userInitiated) {
            let (pdfData, reportId) = PDFReportService.shared.generate(spots: capturedSpots)

            do {
                let relativePath = try capturedFileManager.savePDF(pdfData, named: reportId)
                let fullURL = capturedFileManager.fullURL(for: relativePath)

                let report = SkinReport(
                    id: UUID(),
                    reportId: reportId,
                    createdDate: Date(),
                    pdfPath: relativePath,
                    filterBodyPart: filterLabel,
                    dateRangeStart: rangeStart,
                    dateRangeEnd: rangeEnd,
                    totalPhotos: photoCount,
                    totalScans: scanCount
                )

                await MainActor.run {
                    CoreDataMapper.makeCDReport(from: report, context: capturedContext)
                    PersistenceController.shared.save(context: capturedContext)
                    generatedReportURL = fullURL
                    isGeneratingReport = false
                    showReportSuccess = true
                }
            } catch {
                await MainActor.run {
                    reportErrorMessage = error.localizedDescription
                    isGeneratingReport = false
                    showReportError = true
                }
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var scanList: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                Section {
                    if filteredSpots.isEmpty {
                        filteredEmptyState
                            .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredSpots) { spot in
                                NavigationLink(value: spot) {
                                    SavedScanRowView(spot: spot)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        spotPendingDelete = spot
                                        showRowDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    }
                } header: {
                    filterBar
                }
            }
        }
        .scrollIndicators(.hidden)
        .alert("Delete Scan?", isPresented: $showRowDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let spot = spotPendingDelete {
                    skinSpotService.deleteSkinSpot(spot, from: spot.bodyPart, subPart: spot.subPart)
                    spotPendingDelete = nil
                }
            }
            Button("Cancel", role: .cancel) { spotPendingDelete = nil }
        } message: {
            Text("This scan and its photos will be permanently removed.")
        }
    }

    @ViewBuilder
    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Filter:")
                .fontWeight(.semibold)
                .font(.caption)
                .foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ScanFilter.allCases) { filter in
                        ScanFilterChip(
                            filter: filter,
                            isSelected: activeFilter == filter
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                activeFilter = filter
                            }
                        }
                    }
                }
            }
        }//: VSTACK
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private var emptyState: some View {
        ContentUnavailableView(
            "No Saved Scans",
            systemImage: "camera.badge.clock",
            description: Text("Scans you save will appear here.")
        )
    }

    @ViewBuilder
    private var filteredEmptyState: some View {
        ContentUnavailableView(
            "No \(activeFilter.rawValue) Scans",
            systemImage: "magnifyingglass",
            description: Text("No scans found for this category.")
        )
    }
}

// MARK: - Scan Filter Chip

private struct ScanFilterChip: View {
    let filter: ScanFilter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(filter.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(isSelected ? .white : .secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                isSelected
                    ? Color.accentColor
                    : Color(.tertiarySystemBackground),
                in: Capsule()
            )
            .overlay(
                Capsule().strokeBorder(
                    isSelected ? Color.clear : Color(.separator),
                    lineWidth: 0.5
                )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Saved Scan Row View

struct SavedScanRowView: View {
    let spot: SkinSpot

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
            info
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .contentViewModifier()
    }

    // MARK: - Row Subviews

    @ViewBuilder
    private var thumbnail: some View {
        if let imageData = spot.photos.first?.imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipShape(.rect(cornerRadius: 10))
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.15))
                .frame(width: 70, height: 70)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
        }
    }

    @ViewBuilder
    private var info: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(spot.title)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text(subtitleText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Text(spot.createdDate.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    private var subtitleText: String {
        if let subPart = spot.subPart {
            return "\(spot.bodyPart.displayName) · \(subPart.displayName)"
        }
        return spot.bodyPart.displayName
    }
}

// MARK: - Saved Scan Detail View

struct SavedScanDetailView: View {

    @Environment(SkinSpotService.self)
    private var skinSpotService

    @Environment(\.dismiss)
    private var dismiss

    let spot: SkinSpot

    @State private var showingEdit = false
    @State private var currentSpot: SkinSpot
    @State private var isDeleted = false

    init(spot: SkinSpot) {
        self.spot = spot
        self._currentSpot = State(initialValue: spot)
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                heroImage
                    .padding(.top, 8)

                metaTagsRow
                    .padding(.top, 10)

                if let record = currentSpot.analysisRecord {
                    aiAnalysisSection(record.analysis)
                        .padding(.top, 12)
                }

                if let notes = currentSpot.notes, !notes.isEmpty {
                    notesSection(notes)
                        .padding(.top, 12)
                }

                Spacer(minLength: 32)
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .backgroundViewModifier()
        .navigationTitle(currentSpot.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit, onDismiss: {
            if isDeleted { dismiss() }
        }) {
            EditScanSheet(
                spot: currentSpot,
                onSave: { updatedSpot in
                    skinSpotService.updateSkinSpot(
                        updatedSpot,
                        oldBodyPart: currentSpot.bodyPart,
                        oldSubPart: currentSpot.subPart
                    )
                    currentSpot = updatedSpot
                },
                onDelete: {
                    skinSpotService.deleteSkinSpot(
                        currentSpot,
                        from: currentSpot.bodyPart,
                        subPart: currentSpot.subPart
                    )
                    isDeleted = true
                }
            )
        }
    }

    // MARK: - Hero Image

    @ViewBuilder
    private var heroImage: some View {
        if let imageData = currentSpot.photos.first?.imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        } else {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.15))
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                        Text("No image")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
        }
    }

    // MARK: - Meta Tags Row

    @ViewBuilder
    private var metaTagsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                let bodyLabel: String = {
                    if let subPart = currentSpot.subPart {
                        return "\(currentSpot.bodyPart.displayName) · \(subPart.displayName)"
                    }
                    return currentSpot.bodyPart.displayName
                }()
                SavedScanMetaTag(icon: "figure.arms.open", label: bodyLabel)
                SavedScanMetaTag(
                    icon: "calendar",
                    label: currentSpot.createdDate.formatted(date: .abbreviated, time: .omitted)
                )
                SavedScanMetaTag(
                    icon: "clock",
                    label: currentSpot.createdDate.formatted(date: .omitted, time: .shortened)
                )
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 36)
    }

    // MARK: - AI Analysis Section

    @ViewBuilder
    private func aiAnalysisSection(_ analysis: SkinAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "sun.max.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Sunny Analysis")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            Text("Not a diagnostic tool — always consult a healthcare professional.")
                .font(.caption2)
                .foregroundStyle(.tertiary)

            VStack(spacing: 10) {
                SavedAnalysisRow(label: "Lesion Type", value: analysis.lesionType)
                Divider()
                SavedAnalysisRow(label: "Colour", value: analysis.color)
                Divider()
                SavedAnalysisRow(label: "Symmetry", value: analysis.symmetry)
                Divider()
                SavedAnalysisRow(label: "Borders", value: analysis.borders)
                Divider()
                SavedAnalysisRow(label: "Texture", value: analysis.texture)

                if !analysis.summary.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Summary")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(analysis.summary)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .contentViewModifier()
        }
    }

    // MARK: - Notes Section

    @ViewBuilder
    private func notesSection(_ notes: String) -> some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "pencil")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Notes")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }
            Text(notes)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentViewModifier()
        }
    }
}

// MARK: - Edit Scan Sheet

private struct EditScanSheet: View {

    @Environment(\.dismiss) private var dismiss

    let spot: SkinSpot
    let onSave: (SkinSpot) -> Void
    let onDelete: () -> Void

    @State private var title: String
    @State private var selectedBodyPart: BodyPart
    @State private var selectedSubPart: BodySubPart?
    @State private var notes: String
    @State private var showDeleteConfirmation = false

    init(spot: SkinSpot, onSave: @escaping (SkinSpot) -> Void, onDelete: @escaping () -> Void) {
        self.spot = spot
        self.onSave = onSave
        self.onDelete = onDelete
        self._title = State(initialValue: spot.title)
        self._selectedBodyPart = State(initialValue: spot.bodyPart)
        self._selectedSubPart = State(initialValue: spot.subPart)
        self._notes = State(initialValue: spot.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Editable Section
                Section {
                    TextField("Title", text: $title)

                    Picker("Body Part", selection: $selectedBodyPart) {
                        ForEach(BodyPart.allCases) { part in
                            Text(part.displayName).tag(part)
                        }
                    }
                    .onChange(of: selectedBodyPart) { _, newPart in
                        if let current = selectedSubPart,
                           !newPart.subParts.contains(current) {
                            selectedSubPart = nil
                        }
                    }

                    Picker("Sub-location", selection: $selectedSubPart) {
                        Text("None").tag(Optional<BodySubPart>.none)
                        ForEach(selectedBodyPart.subParts) { sub in
                            Text(sub.displayName).tag(Optional(sub))
                        }
                    }
                } header: {
                    Text("Location")
                }

                Section {
                    ZStack(alignment: .topLeading) {
                        if notes.isEmpty {
                            Text("Add notes…")
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $notes)
                            .frame(minHeight: 80)
                    }
                } header: {
                    Text("Notes")
                }

                // MARK: Read-only Section
                Section {
                    LabeledContent("Date") {
                        Text(spot.createdDate.formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Scan Info")
                } footer: {
                    Text("Date and AI analysis results cannot be changed.")
                }

                if let record = spot.analysisRecord {
                    Section {
                        readOnlyAnalysisRow("Lesion Type", value: record.analysis.lesionType)
                        readOnlyAnalysisRow("Colour", value: record.analysis.color)
                        readOnlyAnalysisRow("Symmetry", value: record.analysis.symmetry)
                        readOnlyAnalysisRow("Borders", value: record.analysis.borders)
                        readOnlyAnalysisRow("Texture", value: record.analysis.texture)
                        if !record.analysis.summary.isEmpty {
                            readOnlyAnalysisRow("Summary", value: record.analysis.summary)
                        }
                    } header: {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                            Text("Sunny Analysis — Read Only")
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Scan")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Scan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updated = SkinSpot(
                            id: spot.id,
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? spot.title
                                : title.trimmingCharacters(in: .whitespacesAndNewlines),
                            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? nil
                                : notes.trimmingCharacters(in: .whitespacesAndNewlines),
                            photos: spot.photos,
                            createdDate: spot.createdDate,
                            lastModified: Date(),
                            bodyPart: selectedBodyPart,
                            subPart: selectedSubPart,
                            analysisRecord: spot.analysisRecord
                        )
                        onSave(updated)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Delete Scan?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This scan and its photos will be permanently removed.")
            }
        }
    }

    @ViewBuilder
    private func readOnlyAnalysisRow(_ label: String, value: String) -> some View {
        LabeledContent(label) {
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
    }
}

// MARK: - Saved Scan Meta Tag

private struct SavedScanMetaTag: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2)
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.tertiarySystemBackground), in: Capsule())
        .overlay(Capsule().strokeBorder(Color(.separator), lineWidth: 0.5))
    }
}

// MARK: - Saved Analysis Row

private struct SavedAnalysisRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 2)
    }
}

// MARK: - Activity Share Sheet

private struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Previews

#Preview("With Scans") {
    let fmService = FileManagerService()
    let service = SkinSpotService(
        context: PersistenceController.preview.viewContext,
        fileManager: fmService
    )
    let photo = SkinSpotPhoto(
        imageData: UIImage(systemName: "sun.max.fill")?.pngData(),
        dateTaken: Date()
    )
    let spot = SkinSpot(
        title: "Single Scan - Forearm",
        notes: "Looks like a freckle, monitoring over time.",
        photos: [photo],
        bodyPart: .leftArm,
        subPart: .armLower
    )
    service.addSkinSpot(spot, to: .leftArm, subPart: .armLower)

    return SavedScansView()
        .environment(service)
        .environment(fmService)
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}

#Preview("Empty") {
    let fmService = FileManagerService()
    return SavedScansView()
        .environment(SkinSpotService(
            context: PersistenceController.preview.viewContext,
            fileManager: fmService
        ))
        .environment(fmService)
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
