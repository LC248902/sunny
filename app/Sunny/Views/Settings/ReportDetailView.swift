//
//  ReportDetailView.swift
//  Sunny
//
//  Created by Josh Bourke on 22/2/2026.
//

import SwiftUI
import PDFKit
import CoreData

// MARK: - Report Detail View

struct ReportDetailView: View {
    let report: CDSkinReport

    @Environment(FileManagerService.self) private var fileManagerService
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var pdfURL: URL?
    @State private var showShareSheet = false
    @State private var showDeleteAlert = false

    var body: some View {
        Group {
            if let url = pdfURL {
                PDFKitView(url: url)
                    .ignoresSafeArea(edges: .bottom)
            } else {
                ContentUnavailableView(
                    "PDF Not Found",
                    systemImage: "doc.richtext",
                    description: Text("The report file could not be located on this device.")
                )
            }
        }
        .backgroundViewModifier()
        .navigationTitle(report.reportId ?? "Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled(pdfURL == nil)

                Button {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                }
                .tint(.red)
            }
        }
        .alert("Delete Report", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteReport()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove the report file. This cannot be undone.")
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ReportDetailActivitySheet(items: [url])
                    .presentationDetents([.medium, .large])
            }
        }
        .onAppear {
            resolveURL()
        }
    }

    // MARK: - Helpers

    private func resolveURL() {
        guard let path = report.pdfPath else { return }
        let url = fileManagerService.fullURL(for: path)
        if FileManager.default.fileExists(atPath: url.path) {
            pdfURL = url
        }
    }

    private func deleteReport() {
        if let path = report.pdfPath {
            fileManagerService.deletePDF(at: path)
        }
        viewContext.delete(report)
        try? viewContext.save()
        dismiss()
    }
}

// MARK: - PDFKit View

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .clear
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document?.documentURL != url,
           let document = PDFDocument(url: url) {
            uiView.document = document
        }
    }
}

// MARK: - Activity Sheet

private struct ReportDetailActivitySheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
