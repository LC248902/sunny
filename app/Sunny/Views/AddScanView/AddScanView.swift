//
//  AddScanView.swift
//  Sunny
//
//  Created by Josh Bourke on 19/2/2026.
//

import SwiftUI
import PhotosUI

enum AddScanRoute: Hashable {
    case bodyPartSelection
    case subPartSelection(BodySelectionActions)
    case captureOptions
    case walkthroughScan
    case reviewScan(ReviewScanPayload)
}

// MARK: - Review Scan Payload

struct ReviewScanPayload: Hashable {
    let image: UIImage
    let scanOption: ScanOptionActions?
    let subBodyPart: SubBodyPartSelectionActions?

    static func == (lhs: ReviewScanPayload, rhs: ReviewScanPayload) -> Bool {
        lhs.image === rhs.image
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(image))
    }
}

struct AddScanView: View {

    @Environment(AIModelService.self)
    private var aiService
    
    @Environment(SkinSpotService.self)
    private var skinSpotService
    
    @Environment(CameraService.self)
    private var cameraService

    @State private var navigationPath = NavigationPath()
    @State private var analysisResults: [AnalysisResult] = []

    @State private var selectedScanOption: ScanOptionActions? = scanOptionActions.first { $0.scanOption == .singleScan }
    @State private var selectedBodyPart: BodySelectionActions?
    @State private var selectedSubBodyPart: SubBodyPartSelectionActions?
    @State private var selectedOrientation: BodyOrientation = .front

    var body: some View {
        NavigationStack(path: $navigationPath) {
            bodyPartSelectionRoot
                .backgroundViewModifier()
                .navigationTitle("New Scan")
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(for: AddScanRoute.self) { route in
                    switch route {
                    case .bodyPartSelection:
                        BodyPartSelectionView(
                            selectedBodyPart: $selectedBodyPart,
                            navigationPath: $navigationPath
                        )
                    case .subPartSelection(let bodyPart):
                        SubPartSelectionView(
                            bodyPartAction: bodyPart,
                            selectedSubBodyPart: $selectedSubBodyPart,
                            selectedOrientation: $selectedOrientation,
                            navigationPath: $navigationPath
                        )
                    case .captureOptions:
                        CaptureOptionsView(
                            navigationPath: $navigationPath,
                            selectedScanOption: $selectedScanOption,
                            selectedSubBodyPart: $selectedSubBodyPart
                        )
                    case .walkthroughScan:
                        BodyScanWalkthroughView()
                    case .reviewScan(let payload):
                        ScanReviewView(
                            image: payload.image,
                            selectedScanOption: payload.scanOption ?? selectedScanOption,
                            selectedSubBodyPart: payload.subBodyPart ?? selectedSubBodyPart,
                            onSave: { image, notes, record in
                                Task { await handleCapturedImage(image, notes: notes, record: record) }
                            },
                            onDiscard: {
                                resetSelections()
                            }
                        )
                    }
                }
        }
    }

    // MARK: - Body Part Selection Root

    @ViewBuilder
    private var bodyPartSelectionRoot: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(BodyPart.allCases, id: \.self) { bodyPart in
                    Button {
                        let action = BodySelectionActions(title: bodyPart.displayName, bodyPart: bodyPart)
                        selectedBodyPart = action
                        navigationPath.append(AddScanRoute.subPartSelection(action))
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(bodyPart.displayName)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            BodyPartPreviewTags(tags: bodyPart.previewTags)
                        }
                        .contentViewModifier()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    // MARK: - Scan Option List

    @ViewBuilder
    private var scanOptionList: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(scanOptionActions, id: \.id) { option in
                    Button {
                        selectedScanOption = option
                        switch option.scanOption {
                        case .walkthroughScan:
                            navigationPath.append(AddScanRoute.walkthroughScan)
                        case .sunscreenScan:
                            navigationPath.append(AddScanRoute.captureOptions)
                        case .singleScan:
                            navigationPath.append(AddScanRoute.bodyPartSelection)
                        }
                    } label: {
                        HStack {
                            Image(systemName: option.image)
                                .font(.title2)
                                .foregroundStyle(.primary)
                                .frame(width: 32)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.title)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                Text(option.subTitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .contentViewModifier()
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }//: VSTACK
            .padding()
        }
    }

    // MARK: - Handle Save

    @MainActor
    private func handleCapturedImage(_ image: UIImage, notes: String?, record: SkinLesionRecord?) async {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let photo = SkinSpotPhoto(imageData: imageData, dateTaken: Date())

        let title: String
        let bodyPartName: String

        if let scanOption = selectedScanOption?.scanOption {
            switch scanOption {
            case .sunscreenScan:
                title = "Sunscreen Check - \(Date().formatted(date: .abbreviated, time: .shortened))"
                bodyPartName = "General"
            case .walkthroughScan:
                title = "Walkthrough - \(selectedSubBodyPart?.title ?? "")"
                bodyPartName = selectedSubBodyPart?.title ?? "Unknown"
            case .singleScan:
                title = "Single Scan - \(selectedSubBodyPart?.title ?? "")"
                bodyPartName = selectedSubBodyPart?.title ?? "Unknown"
            }
        } else {
            title = "Scan - \(selectedSubBodyPart?.title ?? "")"
            bodyPartName = selectedSubBodyPart?.title ?? "Unknown"
        }

        if let record = record {
            withAnimation {
                analysisResults.insert(
                    AnalysisResult(image: image, bodyPart: bodyPartName, record: record),
                    at: 0
                )
            }
        }

        let finalNotes: String? = (notes?.isEmpty == false) ? notes : nil

        if let bodyPart = selectedSubBodyPart?.bodyPart,
           let subPart = selectedSubBodyPart?.subPart {
            let spot = SkinSpot(title: title, notes: finalNotes, photos: [photo], bodyPart: bodyPart, subPart: subPart, analysisRecord: record)
            skinSpotService.addSkinSpot(spot, to: bodyPart, subPart: subPart)
        } else if selectedScanOption?.scanOption == .sunscreenScan {
            let spot = SkinSpot(title: title, notes: finalNotes, photos: [photo], bodyPart: .torso, subPart: .chest, analysisRecord: record)
            skinSpotService.addSkinSpot(spot, to: .torso, subPart: .chest)
        }

        resetSelections()
    }

    private func resetSelections() {
        selectedScanOption = nil
        selectedBodyPart = nil
        selectedSubBodyPart = nil
        navigationPath = NavigationPath()
    }
}

// MARK: - Body Part Selection View

struct BodyPartSelectionView: View {
    @Binding var selectedBodyPart: BodySelectionActions?
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(BodyPart.allCases, id: \.self) { bodyPart in
                    Button {
                        let action = BodySelectionActions(title: bodyPart.displayName, bodyPart: bodyPart)
                        selectedBodyPart = action
                        navigationPath.append(AddScanRoute.subPartSelection(action))
                    } label: {
                        HStack {
                            Text(bodyPart.displayName)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }//: HSTACK
                        .contentViewModifier()
                    }
                    .buttonStyle(.plain)
                }//: LOOP
            }//: VSTACK
            .padding()
        }//: SCROLL VIEW
        .backgroundViewModifier()
        .navigationTitle("Body Part")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Sub Part Selection View

struct SubPartSelectionView: View {
    let bodyPartAction: BodySelectionActions
    @Binding var selectedSubBodyPart: SubBodyPartSelectionActions?
    @Binding var selectedOrientation: BodyOrientation
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                if hasMultipleOrientations {
                    Section {
                        Picker("Orientation", selection: $selectedOrientation) {
                            Text("Front").tag(BodyOrientation.front)
                            Text("Back").tag(BodyOrientation.back)
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical)
                    }
                }
                ForEach(filteredSubParts) { subpart in
                    Button {
                        selectedSubBodyPart = subpart
                        navigationPath.append(AddScanRoute.captureOptions)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(subpart.title)
                                    .foregroundStyle(.primary)
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            if let orientation = subpart.orientation {
                                BodyPartPreviewTags(tags: [orientation == .front ? "Front" : "Back"])
                            }
                        }
                        .contentViewModifier()
                    }
                    .buttonStyle(.plain)
                }//: LOOP
            }//: VSTACK
            .padding()
        }//: SCROLL VIEW
        .backgroundViewModifier()
        .navigationTitle(bodyPartAction.bodyPart.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var filteredSubParts: [SubBodyPartSelectionActions] {
        getSubPartActions(for: bodyPartAction, orientation: hasMultipleOrientations ? selectedOrientation : nil)
    }
    
    private var hasMultipleOrientations: Bool {
        let all = getSubPartActions(for: bodyPartAction)
        return all.contains { $0.orientation == .front } && all.contains { $0.orientation == .back }
    }
}

// MARK: - Capture Options View

struct CaptureOptionsView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var selectedScanOption: ScanOptionActions?
    @Binding var selectedSubBodyPart: SubBodyPartSelectionActions?

    @State private var showCamera = false
    @State private var capturedImage: UIImage? = nil

    var body: some View {
        ScrollView {
            HStack(spacing: 12) {
                Button {
                    showCamera = true
                } label: {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.largeTitle)
                        Text("Take Photo")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                    .contentViewModifier()
                }
                .buttonStyle(.plain)

                PhotosPicker(
                    selection: Binding(
                        get: { nil },
                        set: { item in
                            guard let item else { return }
                            Task {
                                if let data = try? await item.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    capturedImage = uiImage
                                }
                            }
                        }
                    ),
                    matching: .images
                ) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.stack")
                            .font(.largeTitle)
                        Text("Choose from\nLibrary")
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                    .contentViewModifier()
                }
                .buttonStyle(.plain)
            }//: HSTACK
            .padding()
        }//: SCROLL VIEW
        .backgroundViewModifier()
        .navigationTitle("Capture")
        .navigationBarTitleDisplayMode(.inline)
        // Library picks: no cover to dismiss, push immediately
        .onChange(of: capturedImage) { _, newImage in
            guard let image = newImage, !showCamera else { return }
            navigationPath.append(AddScanRoute.reviewScan(ReviewScanPayload(
                image: image,
                scanOption: selectedScanOption,
                subBodyPart: selectedSubBodyPart
            )))
        }
        // Camera: wait until the cover animation is fully complete before pushing
        .fullScreenCover(isPresented: $showCamera,content: {
            CameraPickerView(image: $capturedImage)
        })
    }
}

struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView

        init(_ parent: CameraPickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Partial Skin Analysis (for progressive streaming reveal)

struct PartialSkinAnalysis {
    var lesionType: String?
    var color: String?
    var symmetry: String?
    var borders: String?
    var texture: String?
    var summary: String?

    var isEmpty: Bool {
        lesionType == nil && color == nil && symmetry == nil &&
        borders == nil && texture == nil && summary == nil
    }
}

// MARK: - Body Part Preview Tags

private struct BodyPartPreviewTags: View {
    let tags: [String]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(.tertiarySystemBackground), in: Capsule())
                    .overlay(Capsule().strokeBorder(Color(.accent).opacity(0.5), lineWidth: 0.5))
            }
            Spacer()
        }
    }
}

// MARK: - Scan Meta Tag (chip)

private struct ScanMetaTag: View {
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

// MARK: - Scan Meta Tags Row

private struct ScanMetaTagsRow: View {
    let selectedScanOption: ScanOptionActions?
    let selectedSubBodyPart: SubBodyPartSelectionActions?
    let captureDate: Date

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let scanOption = selectedScanOption {
                    ScanMetaTag(icon: scanOption.image, label: scanOption.title)
                }

                if let sub = selectedSubBodyPart {
                    ScanMetaTag(icon: "figure.arms.open", label: "\(sub.bodyPart.displayName) · \(sub.title)")
                    if let orientation = sub.orientation {
                        ScanMetaTag(
                            icon: orientation == .front ? "person.fill" : "person.fill.turn.right",
                            label: orientation == .front ? "Front" : "Back"
                        )
                    }
                } else if selectedScanOption?.scanOption == .sunscreenScan {
                    ScanMetaTag(icon: "figure.arms.open", label: "General")
                }

                ScanMetaTag(
                    icon: "calendar",
                    label: captureDate.formatted(date: .abbreviated, time: .shortened)
                )
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 36)
    }
}

// MARK: - Scan Review View

struct ScanReviewView: View {
    let image: UIImage
    let selectedScanOption: ScanOptionActions?
    let selectedSubBodyPart: SubBodyPartSelectionActions?
    let onSave: (UIImage, String?, SkinLesionRecord?) -> Void
    let onDiscard: () -> Void

    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(AIModelService.self)
    private var aiService

    @State private var notes: String = ""
    @State private var captureDate: Date = Date()
    @State private var showDiscardConfirmation = false
    @State private var analysisRecord: SkinLesionRecord?
    @State private var isAnalyzing = false
    @State private var analysisError: String?
    @State private var partial: PartialSkinAnalysis = .init()
    @State private var inferenceTask: Task<Void, Never>?
    @FocusState private var isNotesFocused: Bool

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                // MARK: Hero Image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.top, 8)
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)

                // MARK: Compact Meta Tags
                ScanMetaTagsRow(
                    selectedScanOption: selectedScanOption,
                    selectedSubBodyPart: selectedSubBodyPart,
                    captureDate: captureDate
                )
                .padding(.top, 10)
                
                // MARK: AI Analysis
                Group {
                    if isAnalyzing || analysisRecord != nil || !partial.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                if isAnalyzing {
                                    ProgressView()
                                        .scaleEffect(0.75)
                                        .tint(.secondary)
                                } else {
                                    Image(systemName: "sun.max.fill")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Text("Sunny Analysis")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            Text("Not a diagnostic tool — always consult a healthcare professional.")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                            StreamingAnalysisCard(
                                partial: partial,
                                isAnalyzing: isAnalyzing,
                                finalRecord: analysisRecord
                            )
                            .contentViewModifier()
                        }
                    } else if let error = analysisError {
                        AnalysisErrorCard(message: error)
                    }
                }
                .padding(.top, 12)
                
                // MARK: Notes
                HStack {
                    Image(systemName: "pencil")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Notes")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                }//: HSTACK
                .padding(.top, 10)
                HStack {
                    TextField("Add a note about this scan…", text: $notes)
                        .focused($isNotesFocused)
                }
                .contentViewModifier()
                .padding(.top, 10)

                // MARK: Actions
                HStack(spacing: 10) {
                    Button {
                        isNotesFocused = false
                        onSave(image, notes.isEmpty ? nil : notes, analysisRecord)
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentViewModifier()
                        .opacity(isAnalyzing ? 0.4 : 1)
                    }
                    .buttonStyle(.plain)
                    .disabled(isAnalyzing)

                    Button {
                        isNotesFocused = false
                        cancelInference()
                        dismiss()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Retake")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentViewModifier()
                    }
                    .buttonStyle(.plain)

                    Button(role: .destructive) {
                        showDiscardConfirmation = true
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "trash")
                            Text("Discard")
                                .fontWeight(.semibold)
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentViewModifier()
                        .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 16)
                .padding(.bottom, 32)
            }//: VSTACK
            .padding()
        }//: SCOLL VIEW
        .backgroundViewModifier()
        .navigationTitle("Review Scan")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .destructive) {
                    showDiscardConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .fontWeight(.semibold)
                }
                .tint(.red)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isNotesFocused = false
                    cancelInference()
                    dismiss()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .fontWeight(.semibold)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isNotesFocused = false
                    onSave(image, notes.isEmpty ? nil : notes, analysisRecord)
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .fontWeight(.semibold)
                }
                .disabled(isAnalyzing)
            }
        }
        .confirmationDialog("Discard this scan?", isPresented: $showDiscardConfirmation, titleVisibility: .visible) {
            Button("Discard", role: .destructive) {
                cancelInference()
                onDiscard()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This photo won't be saved.")
        }
        .onTapGesture {
            isNotesFocused = false
        }
        .onAppear {
            inferenceTask = Task { await runInference() }
        }
        .onDisappear {
            inferenceTask?.cancel()
            inferenceTask = nil
        }
        .onChange(of: aiService.currentOutput) { _, raw in
            guard isAnalyzing else { return }
            if let v = extract("lesion_type", from: raw) { partial.lesionType = v }
            if let v = extract("color",       from: raw) { partial.color      = v }
            if let v = extract("symmetry",    from: raw) { partial.symmetry   = v }
            if let v = extract("borders",     from: raw) { partial.borders    = v }
            if let v = extract("texture",     from: raw) { partial.texture    = v }
            if let v = extract("summary",     from: raw) { partial.summary    = v }
        }
    }

    // MARK: - Cancellation

    private func cancelInference() {
        inferenceTask?.cancel()
        inferenceTask = nil
        isAnalyzing = false
    }

    // MARK: - Helpers

    private func extract(_ key: String, from raw: String) -> String? {
        let pattern = #""\#(key)"\s*:\s*"([^"]*)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: raw, range: NSRange(raw.startIndex..., in: raw)),
              let range = Range(match.range(at: 1), in: raw) else { return nil }
        let value = String(raw[range])
        return value.isEmpty ? nil : value
    }

    // MARK: - Inference

    private func runInference() async {
        isAnalyzing = true
        analysisError = nil

        let bodyPartName: String
        if let sub = selectedSubBodyPart {
            bodyPartName = sub.title
        } else if selectedScanOption?.scanOption == .sunscreenScan {
            bodyPartName = "General"
        } else {
            bodyPartName = "Unknown"
        }

        do {
            if !aiService.isModelLoaded {
                try Task.checkCancellation()
                await aiService.loadModel(aiService.model)
            }
            try Task.checkCancellation()
            let imagePath = "images/\(UUID().uuidString).jpg"
            let record = try await aiService.analyzeSkinImageStructured(
                image,
                bodyPart: bodyPartName,
                imagePath: imagePath
            )
            withAnimation(.easeInOut) {
                analysisRecord = record
            }
        } catch is CancellationError {
            // User cancelled via Retake or Discard — silently stop
        } catch {
            analysisError = error.localizedDescription
        }

        isAnalyzing = false
    }
}

// MARK: - Streaming Analysis Card

private struct StreamingAnalysisCard: View {
    let partial: PartialSkinAnalysis
    let isAnalyzing: Bool
    let finalRecord: SkinLesionRecord?

    private var rows: [(label: String, value: String?)] {
        let src = finalRecord?.analysis
        return [
            ("Lesion Type", src?.lesionType ?? partial.lesionType),
            ("Colour",      src?.color      ?? partial.color),
            ("Symmetry",    src?.symmetry   ?? partial.symmetry),
            ("Borders",     src?.borders    ?? partial.borders),
            ("Texture",     src?.texture    ?? partial.texture),
        ]
    }

    private var summaryValue: String? {
        finalRecord?.analysis.summary ?? partial.summary
    }

    var body: some View {
        VStack(spacing: 10) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 { Divider() }
                analysisRow(label: row.label, value: row.value)
            }

            // Summary — label always visible, value animates in
            Divider()
            VStack(alignment: .leading, spacing: 4) {
                Text("Summary")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let summary = summaryValue, !summary.isEmpty {
                    Text(summary)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if isAnalyzing {
                    ValuePlaceholder(wide: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // Icon and label are always rendered. Only the value slot varies.
    @ViewBuilder
    private func analysisRow(label: String, value: String?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }//: HSTACK
            if let value {
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
            } else if isAnalyzing {
                ValuePlaceholder()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 2)
    }
}

// Pulsing placeholder for just the value slot in a row.
private struct ValuePlaceholder: View {
    var wide: Bool = true
    @State private var pulse = false

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(.tertiaryLabel))
            .frame(width: wide ? 160 : 80, height: 12)
            .opacity(pulse ? 0.3 : 0.7)
            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)
            .onAppear { pulse = true }
    }
}

// MARK: - Analysis Error Card

private struct AnalysisErrorCard: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("Analysis unavailable")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .contentViewModifier()
    }
}

#Preview {
    AddScanView()
}
