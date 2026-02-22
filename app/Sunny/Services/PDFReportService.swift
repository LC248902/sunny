//
//  PDFReportService.swift
//  Sunny
//
//  Created by Josh Bourke on 21/2/2026.
//

import UIKit

final class PDFReportService {

    static let shared = PDFReportService()

    // MARK: - Page Geometry

    private let pageWidth: CGFloat = 595.28
    private let pageHeight: CGFloat = 841.89
    private let margin: CGFloat = 48
    private var contentWidth: CGFloat { pageWidth - margin * 2 }
    private let bottomPadding: CGFloat = 56

    // MARK: - Report ID

    func makeReportId() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyyMMdd"
        let dateStr = fmt.string(from: Date())
        let hex = String(format: "%04X", Int.random(in: 0...0xFFFF))
        return "SUN-\(dateStr)-\(hex)"
    }

    // MARK: - Grouping

    private struct ReportGroup {
        let title: String
        let spots: [SkinSpot]
    }

    private func grouped(_ spots: [SkinSpot]) -> [ReportGroup] {
        [
            ("Head",  [BodyPart.head]),
            ("Arms",  [.leftArm, .rightArm]),
            ("Torso", [.torso]),
            ("Legs",  [.leftLeg, .rightLeg])
        ].compactMap { title, parts in
            let filtered = spots.filter { parts.contains($0.bodyPart) }
            return filtered.isEmpty ? nil : ReportGroup(title: title, spots: filtered)
        }
    }

    // MARK: - Public API

    func generate(spots: [SkinSpot]) -> (data: Data, reportId: String) {
        let reportId = makeReportId()
        let exportDate = Date()
        let totalPhotos = spots.reduce(0) { $0 + $1.photos.count }
        let groups = grouped(spots)

        var y: CGFloat = margin
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = renderer.pdfData { [self] ctx in
            // Page 1: Branded cover / landing page
            ctx.beginPage()
            drawCoverPage(y: &y, exportDate: exportDate, totalPhotos: totalPhotos, reportId: reportId)

            // Subsequent pages: scan content
            for group in groups {
                ctx.beginPage()
                y = margin
                drawHeader(y: &y)
                y += 20
                drawGroupHeader(y: &y, title: group.title)
                y += 16

                for (idx, spot) in group.spots.enumerated() {
                    let needed = spotTotalHeight(spot: spot)
                    // If this spot won't fit on the remaining page, start a fresh page
                    if needed <= pageHeight - margin * 2 {
                        checkPageBreak(y: &y, needed: needed, ctx: ctx, drawHeaderOnBreak: true)
                    }

                    drawSpotDetails(y: &y, ctx: ctx, spot: spot)
                    y += 12

                    for photo in spot.photos {
                        let h = photoHeight(for: photo)
                        checkPageBreak(y: &y, needed: h + 20, ctx: ctx, drawHeaderOnBreak: true)
                        drawPhoto(y: &y, photo: photo)
                        y += 12
                    }

                    if idx < group.spots.count - 1 {
                        y += 8
                        drawSeparator(y: y, alpha: 0.25)
                        y += 20
                    }
                }

                y += 24
            }
        }

        return (data, reportId)
    }

    // MARK: - Page Break

    private func checkPageBreak(
        y: inout CGFloat,
        needed: CGFloat,
        ctx: UIGraphicsPDFRendererContext,
        drawHeaderOnBreak: Bool = false
    ) {
        guard y + needed > pageHeight - bottomPadding else { return }
        ctx.beginPage()
        y = margin
        if drawHeaderOnBreak {
            drawHeader(y: &y)
            y += 20
        }
    }

    // MARK: - Cover Page

    private func drawCoverPage(y: inout CGFloat, exportDate: Date, totalPhotos: Int, reportId: String) {
        y = margin

        // Large centered logo
        let logoSize: CGFloat = 100
        let logoX = (pageWidth - logoSize) / 2
        let logoY = pageHeight * 0.18

        if let logo = UIImage(named: "Sunny_Head") {
            logo.draw(in: CGRect(x: logoX, y: logoY, width: logoSize, height: logoSize))
        }

        y = logoY + logoSize + 24

        // App name
        let nameAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor.black
        ]
        let nameSize = ("Sunny" as NSString).size(withAttributes: nameAttrs)
        ("Sunny" as NSString).draw(
            at: CGPoint(x: (pageWidth - nameSize.width) / 2, y: y),
            withAttributes: nameAttrs
        )
        y += nameSize.height + 10

        // Subtitle
        let subtitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: UIColor(white: 0.5, alpha: 1),
            .kern: NSNumber(value: 1.5)
        ]
        let subtitle = "SKIN EXAMINATION REPORT"
        let subtitleSize = (subtitle as NSString).size(withAttributes: subtitleAttrs)
        (subtitle as NSString).draw(
            at: CGPoint(x: (pageWidth - subtitleSize.width) / 2, y: y),
            withAttributes: subtitleAttrs
        )
        y += subtitleSize.height + 28

        // Horizontal rule
        UIColor(white: 0.78, alpha: 1).setStroke()
        let rulePath = UIBezierPath()
        rulePath.move(to: CGPoint(x: margin, y: y))
        rulePath.addLine(to: CGPoint(x: pageWidth - margin, y: y))
        rulePath.lineWidth = 0.75
        rulePath.stroke()
        y += 36

        // Metadata card
        drawMetadataCard(y: &y, exportDate: exportDate, totalPhotos: totalPhotos, reportId: reportId)
        y += 28

        // Disclaimer
        drawDisclaimer(y: &y)
    }

    // MARK: - Header (compact, used on scan pages)

    private func drawHeader(y: inout CGFloat) {
        let logoSize: CGFloat = 24
        if let logo = UIImage(named: "Sunny_Head") {
            logo.draw(in: CGRect(x: margin, y: y, width: logoSize, height: logoSize))
        }

        let nameAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: UIColor.black
        ]
        ("Sunny" as NSString).draw(at: CGPoint(x: margin + logoSize + 6, y: y + 3), withAttributes: nameAttrs)

        let rightLabel = "SKIN EXAMINATION REPORT"
        let rightAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8, weight: .semibold),
            .foregroundColor: UIColor(white: 0.45, alpha: 1),
            .kern: NSNumber(value: 0.8)
        ]
        let rightW = (rightLabel as NSString).size(withAttributes: rightAttrs).width
        (rightLabel as NSString).draw(
            at: CGPoint(x: pageWidth - margin - rightW, y: y + 7),
            withAttributes: rightAttrs
        )

        y += 30

        UIColor(white: 0.78, alpha: 1).setStroke()
        let rulePath = UIBezierPath()
        rulePath.move(to: CGPoint(x: margin, y: y))
        rulePath.addLine(to: CGPoint(x: pageWidth - margin, y: y))
        rulePath.lineWidth = 0.75
        rulePath.stroke()

        y += 2
    }

    // MARK: - Disclaimer

    private func drawDisclaimer(y: inout CGFloat) {
        let disclaimerBody = "This report is not a medical diagnosis and is intended for personal record-keeping purposes only. Please discuss any concerns with a qualified healthcare professional. Photo descriptions may be AI-generated — please review them carefully for accuracy."

        let hPad: CGFloat = 14
        let vPad: CGFloat = 12
        let iconW: CGFloat = 24
        let gap: CGFloat = 8
        let textW = contentWidth - iconW - gap - hPad * 2

        let boldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .bold),
            .foregroundColor: UIColor(white: 0.15, alpha: 1)
        ]
        let bodyAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: UIColor(white: 0.2, alpha: 1)
        ]

        let combined = NSMutableAttributedString()
        combined.append(NSAttributedString(string: "Important: ", attributes: boldAttrs))
        combined.append(NSAttributedString(string: disclaimerBody, attributes: bodyAttrs))

        let textRect = combined.boundingRect(
            with: CGSize(width: textW, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        let textH = ceil(textRect.height)
        let boxH = vPad * 2 + textH
        let boxRect = CGRect(x: margin, y: y, width: contentWidth, height: boxH)

        UIColor(red: 1.0, green: 0.97, blue: 0.88, alpha: 1).setFill()
        UIBezierPath(roundedRect: boxRect, cornerRadius: 8).fill()

        UIColor(red: 0.88, green: 0.72, blue: 0.18, alpha: 0.7).setStroke()
        let border = UIBezierPath(roundedRect: boxRect.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 8)
        border.lineWidth = 0.75
        border.stroke()

        let iconAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 13)]
        ("⚠" as NSString).draw(at: CGPoint(x: margin + hPad, y: y + vPad + 1), withAttributes: iconAttrs)

        combined.draw(
            with: CGRect(x: margin + hPad + iconW + gap, y: y + vPad, width: textW, height: textH),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        y += boxH
    }

    // MARK: - Metadata Card

    private func drawMetadataCard(y: inout CGFloat, exportDate: Date, totalPhotos: Int, reportId: String) {
        let boxH: CGFloat = 72
        let boxRect = CGRect(x: margin, y: y, width: contentWidth, height: boxH)

        UIColor(white: 0.965, alpha: 1).setFill()
        UIBezierPath(roundedRect: boxRect, cornerRadius: 10).fill()

        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 7.5, weight: .semibold),
            .foregroundColor: UIColor(white: 0.5, alpha: 1),
            .kern: NSNumber(value: 0.5)
        ]
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor.black
        ]

        let fmt = DateFormatter()
        fmt.dateStyle = .long
        fmt.timeStyle = .none

        let cols: [(String, String)] = [
            ("DATE EXPORTED", fmt.string(from: exportDate)),
            ("TOTAL PHOTOS",  "\(totalPhotos)"),
            ("REPORT ID",     reportId)
        ]

        let colW = contentWidth / CGFloat(cols.count)
        let labelY = y + 18
        let valueY = labelY + 14

        for (i, (label, value)) in cols.enumerated() {
            let x = margin + CGFloat(i) * colW + 16
            (label as NSString).draw(at: CGPoint(x: x, y: labelY), withAttributes: labelAttrs)
            (value as NSString).draw(at: CGPoint(x: x, y: valueY), withAttributes: valueAttrs)
        }

        y += boxH
    }

    // MARK: - Group Header

    private func drawGroupHeader(y: inout CGFloat, title: String) {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: UIColor.black
        ]
        let titleH = (title as NSString).size(withAttributes: attrs).height
        (title as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)

        y += titleH + 6

        UIColor(white: 0.82, alpha: 1).setStroke()
        let rule = UIBezierPath()
        rule.move(to: CGPoint(x: margin, y: y))
        rule.addLine(to: CGPoint(x: pageWidth - margin, y: y))
        rule.lineWidth = 0.75
        rule.stroke()

        y += 2
    }

    // MARK: - Spot Height Estimation

    private func spotTotalHeight(spot: SkinSpot) -> CGFloat {
        var total: CGFloat = 0

        // Title
        total += 22
        // Location + date
        total += 18

        // Notes
        if let notes = spot.notes, !notes.isEmpty {
            total += 8 + 14 // header label + gap
            let notesAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10)
            ]
            let rect = (notes as NSString).boundingRect(
                with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin],
                attributes: notesAttrs,
                context: nil
            )
            total += ceil(rect.height) + 4
        }

        // AI Analysis
        if let record = spot.analysisRecord {
            total += 14 + 14 + 10 // section label + separator + gap

            let fieldValueAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10)
            ]
            let fields: [String] = [
                record.analysis.lesionType,
                record.analysis.color,
                record.analysis.symmetry,
                record.analysis.borders,
                record.analysis.texture,
                record.analysis.summary
            ].filter { !$0.isEmpty }

            for (idx, value) in fields.enumerated() {
                if idx > 0 { total += 10 } // separator
                total += 14 // field label
                let rect = (value as NSString).boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin],
                    attributes: fieldValueAttrs,
                    context: nil
                )
                total += ceil(rect.height) + 10
            }
        }

        // Photos
        for photo in spot.photos {
            total += photoHeight(for: photo) + 12
        }

        total += 12 // bottom padding after spot
        return total
    }

    // MARK: - Spot Details

    private func drawSpotDetails(y: inout CGFloat, ctx: UIGraphicsPDFRendererContext, spot: SkinSpot) {
        // Title
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: UIColor.black
        ]
        (spot.title as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttrs)
        y += 22

        // Location + date
        let location: String = {
            if let sub = spot.subPart {
                return "\(spot.bodyPart.displayName) · \(sub.displayName)"
            }
            return spot.bodyPart.displayName
        }()
        let dateStr = spot.createdDate.formatted(date: .abbreviated, time: .omitted)
        let metaText = "\(location)   \(dateStr)"
        let metaAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor(white: 0.45, alpha: 1)
        ]
        (metaText as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: metaAttrs)
        y += 18

        // Notes
        if let notes = spot.notes, !notes.isEmpty {
            y += 8
            checkPageBreak(y: &y, needed: 40, ctx: ctx, drawHeaderOnBreak: true)

            let notesHeaderAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
                .foregroundColor: UIColor(white: 0.5, alpha: 1),
                .kern: NSNumber(value: 0.5)
            ]
            ("NOTES" as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: notesHeaderAttrs)
            y += 14

            let notesAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor(white: 0.2, alpha: 1)
            ]
            let notesRect = (notes as NSString).boundingRect(
                with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin],
                attributes: notesAttrs,
                context: nil
            )
            let notesH = ceil(notesRect.height)
            checkPageBreak(y: &y, needed: notesH + 8, ctx: ctx, drawHeaderOnBreak: true)
            NSAttributedString(string: notes, attributes: notesAttrs).draw(
                with: CGRect(x: margin, y: y, width: contentWidth, height: notesH + 4),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )
            y += notesH + 4
        }

        // AI Analysis
        guard let record = spot.analysisRecord else { return }

        y += 14
        checkPageBreak(y: &y, needed: 60, ctx: ctx, drawHeaderOnBreak: true)

        let sectionAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
            .foregroundColor: UIColor(white: 0.5, alpha: 1),
            .kern: NSNumber(value: 0.5)
        ]
        ("SUNNY ANALYSIS" as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: sectionAttrs)
        y += 14
        drawSeparator(y: y, alpha: 0.4)
        y += 10

        let fieldLabelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
            .foregroundColor: UIColor(white: 0.4, alpha: 1)
        ]
        let fieldValueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor(white: 0.15, alpha: 1)
        ]

        let fields: [(String, String)] = [
            ("Lesion Type", record.analysis.lesionType),
            ("Colour",      record.analysis.color),
            ("Symmetry",    record.analysis.symmetry),
            ("Borders",     record.analysis.borders),
            ("Texture",     record.analysis.texture),
            ("Summary",     record.analysis.summary)
        ].filter { !$0.1.isEmpty }

        for (idx, (label, value)) in fields.enumerated() {
            let valueRect = (value as NSString).boundingRect(
                with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin],
                attributes: fieldValueAttrs,
                context: nil
            )
            let valueH = ceil(valueRect.height)
            checkPageBreak(y: &y, needed: valueH + 28, ctx: ctx, drawHeaderOnBreak: true)

            if idx > 0 {
                drawSeparator(y: y, alpha: 0.2)
                y += 10
            }

            (label as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: fieldLabelAttrs)
            y += 14

            NSAttributedString(string: value, attributes: fieldValueAttrs).draw(
                with: CGRect(x: margin, y: y, width: contentWidth, height: valueH + 4),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )
            y += valueH + 10
        }
    }

    // MARK: - Photo

    private func photoHeight(for photo: SkinSpotPhoto) -> CGFloat {
        guard let data = photo.imageData, let img = UIImage(data: data) else { return 160 }
        let ratio = img.size.height / img.size.width
        return min(contentWidth * ratio, 280)
    }

    private func drawPhoto(y: inout CGFloat, photo: SkinSpotPhoto) {
        let cornerRadius: CGFloat = 10

        if let data = photo.imageData, let img = UIImage(data: data) {
            let ratio = img.size.height / img.size.width
            let imgH = min(contentWidth * ratio, 280)
            let rect = CGRect(x: margin, y: y, width: contentWidth, height: imgH)

            UIGraphicsGetCurrentContext()?.saveGState()
            UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
            img.draw(in: rect)
            UIGraphicsGetCurrentContext()?.restoreGState()

            y += imgH
        } else {
            let phH: CGFloat = 160
            let rect = CGRect(x: margin, y: y, width: contentWidth, height: phH)

            UIColor(white: 0.93, alpha: 1).setFill()
            UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).fill()

            let phAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor(white: 0.65, alpha: 1)
            ]
            let phText = "No image available"
            let phSize = (phText as NSString).size(withAttributes: phAttrs)
            (phText as NSString).draw(
                at: CGPoint(
                    x: margin + (contentWidth - phSize.width) / 2,
                    y: y + (phH - phSize.height) / 2
                ),
                withAttributes: phAttrs
            )

            y += phH
        }
    }

    // MARK: - Separator

    private func drawSeparator(y: CGFloat, alpha: CGFloat = 1) {
        UIColor(white: 0.82, alpha: alpha).setStroke()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: y))
        path.addLine(to: CGPoint(x: pageWidth - margin, y: y))
        path.lineWidth = 0.5
        path.stroke()
    }
}
