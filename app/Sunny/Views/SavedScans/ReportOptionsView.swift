//
//  ReportOptionsView.swift
//  Sunny
//
//  Created by Josh Bourke on 21/2/2026.
//

import SwiftUI

struct ReportOptionsView: View {

    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(SkinSpotService.self)
    private var skinSpotService

    let initialFilter: ScanFilter
    let onGenerate: (ScanFilter, ClosedRange<Date>?) -> Void

    @State private var selectedFilter: ScanFilter
    @State private var useDateRange = false
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var showConfirmation = false

    init(initialFilter: ScanFilter, onGenerate: @escaping (ScanFilter, ClosedRange<Date>?) -> Void) {
        self.initialFilter = initialFilter
        self.onGenerate = onGenerate
        _selectedFilter = State(initialValue: initialFilter)
        let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        _startDate = State(initialValue: threeMonthsAgo)
        _endDate = State(initialValue: Date())
    }

    // MARK: - Computed

    private var matchingSpots: [SkinSpot] {
        var spots = skinSpotService.allSkinSpots
        if let parts = selectedFilter.bodyParts {
            spots = spots.filter { parts.contains($0.bodyPart) }
        }
        if useDateRange {
            let lo = min(startDate, endDate)
            let hi = max(startDate, endDate)
            spots = spots.filter { (lo...hi).contains($0.createdDate) }
        }
        return spots
    }

    private var totalPhotos: Int {
        matchingSpots.reduce(0) { $0 + $1.photos.count }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                bodyAreaSection
                dateRangeSection
                summarySection
            }
            .navigationTitle("Generate Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                generateButton
            }
            .alert("Save Report to Device?", isPresented: $showConfirmation) {
                Button("Save") {
                    let dateRange: ClosedRange<Date>? = useDateRange
                        ? min(startDate, endDate)...max(startDate, endDate)
                        : nil
                    onGenerate(selectedFilter, dateRange)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("A PDF skin examination report will be generated and saved to your device. This report is not a medical diagnosis.")
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var bodyAreaSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ScanFilter.allCases) { filter in
                        ReportFilterChip(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter
                        ) {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedFilter = filter
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("Body Area")
        } footer: {
            Text("Only scans in the selected body area will be included in the report.")
        }
    }

    @ViewBuilder
    private var dateRangeSection: some View {
        Section {
            Toggle("Filter by date range", isOn: $useDateRange.animation())
            if useDateRange {
                DatePicker(
                    "From",
                    selection: $startDate,
                    displayedComponents: .date
                )
                DatePicker(
                    "To",
                    selection: $endDate,
                    in: startDate...,
                    displayedComponents: .date
                )
            }
        } header: {
            Text("Date Range")
        } footer: {
            if useDateRange {
                Text("Only scans created between the selected dates will be included.")
            }
        }
    }

    @ViewBuilder
    private var summarySection: some View {
        Section("Report Preview") {
            LabeledContent("Scans included") {
                Text("\(matchingSpots.count)")
                    .fontWeight(.semibold)
                    .foregroundStyle(matchingSpots.isEmpty ? .red : .primary)
            }
            LabeledContent("Total photos") {
                Text("\(totalPhotos)")
                    .fontWeight(.semibold)
            }
        }
    }

    @ViewBuilder
    private var generateButton: some View {
        Button {
            showConfirmation = true
        } label: {
            Label("Save Report to Device", systemImage: "doc.richtext")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    matchingSpots.isEmpty
                        ? Color.secondary.opacity(0.25)
                        : Color.accentColor,
                    in: RoundedRectangle(cornerRadius: 14)
                )
                .foregroundStyle(matchingSpots.isEmpty ? Color.secondary : .white)
        }
        .disabled(matchingSpots.isEmpty)
        .padding()
        .background(.ultraThinMaterial)
    }
}

// MARK: - Report Filter Chip

private struct ReportFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? .white : .secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.accentColor : Color(.tertiarySystemBackground),
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
