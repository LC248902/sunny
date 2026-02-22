//
//  ReportsView.swift
//  Sunny
//
//  Created by Josh Bourke on 21/2/2026.
//

import SwiftUI
import CoreData

struct ReportsView: View {

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.createdDate, order: .reverse)],
        animation: .default
    )
    private var reports: FetchedResults<CDSkinReport>

    var body: some View {
        Group {
            if reports.isEmpty {
                emptyState
            } else {
                reportList
            }
        }
        .backgroundViewModifier()
        .navigationTitle("Exported Reports")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Report List

    @ViewBuilder
    private var reportList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(reports, id: \.objectID) { report in
                    NavigationLink(destination: ReportDetailView(report: report)) {
                        ReportRow(report: report)
                            .contentViewModifier()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyState: some View {
        ContentUnavailableView(
            "No Exported Reports",
            systemImage: "doc.richtext",
            description: Text("Reports you generate from Saved Scans will appear here.")
        )
    }
}

// MARK: - Report Row

private struct ReportRow: View {
    let report: CDSkinReport

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: "doc.richtext.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.accentColor)
            }

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(report.reportId ?? "Unknown")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(subtitleText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var subtitleText: String {
        var parts: [String] = []

        if let date = report.createdDate {
            parts.append(date.formatted(date: .abbreviated, time: .omitted))
        }

        if let filter = report.filterBodyPart {
            parts.append(filter)
        } else {
            parts.append("All areas")
        }

        let scans = Int(report.totalScans)
        parts.append("\(scans) \(scans == 1 ? "scan" : "scans")")

        let photos = Int(report.totalPhotos)
        parts.append("\(photos) \(photos == 1 ? "photo" : "photos")")

        return parts.joined(separator: " · ")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ReportsView()
            .environment(FileManagerService())
            .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
    }
}
