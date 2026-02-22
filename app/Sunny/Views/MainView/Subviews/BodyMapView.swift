//
//  BodyMapView.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SVGView
import SwiftUI

struct BodyMapView: View {
    @Environment(SkinSpotService.self)
    private var skinSpotService
    
    @Environment(\.colorScheme)
    var colorScheme
    
    @State private var selectedBodyPart: BodyPart?
    @State private var selectedSubPart: BodySubPart?
    @State private var selectedOrientation: BodyOrientation = .front
    @State private var showingCamera = false
    @State private var frontSVGView: SVGView?
    @State private var backSVGView: SVGView?
    
    // Track spot counts per body part
    @State private var bodyPartCounts: [String: Int] = [:]
    
    var body: some View {
        VStack(spacing: 16) {
            // Orientation Toggle
            orientationPicker
            
            ZStack {
                // Show front or back view based on selection
                if selectedOrientation == .front {
                    frontBodyView
                        .transition(.opacity)
                } else {
                    backBodyView
                        .transition(.opacity)
                }
            }
            .frame(height: 220)
            .padding()
        }
        .onAppear {
            setupBodyMaps()
            updateBodyPartCounts()
        }
        .onChange(of: colorScheme) { _, _ in
            updateAllBodyPartColors()
        }
        .sheet(item: $selectedBodyPart) { bodyPart in
            BodyPartDetailView(bodyPart: bodyPart)
        }
    }
    
    private var orientationPicker: some View {
        Picker("View", selection: $selectedOrientation.animation()) {
            Text("Front").tag(BodyOrientation.front)
            Text("Back").tag(BodyOrientation.back)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var frontBodyView: some View {
        frontSVGView
    }
    
    private var backBodyView: some View {
        backSVGView
    }
    
    
    private func setupBodyMaps() {
        // Load front SVG
        if let frontURL = Bundle.main.url(forResource: "Human_Body_Front", withExtension: "svg") {
            frontSVGView = SVGView(contentsOf: frontURL)
            setupInteractions(for: frontSVGView, orientation: .front)
        }
        
        // Load back SVG
        if let backURL = Bundle.main.url(forResource: "Human_Body_Back", withExtension: "svg") {
            backSVGView = SVGView(contentsOf: backURL)
            setupInteractions(for: backSVGView, orientation: .back)
        }
    }
    
    private func setupInteractions(for svgView: SVGView?, orientation: BodyOrientation) {
        guard let svgView = svgView else { return }
        
        for part in BodyPart.allCases {
            for subPart in part.subParts {
                if let svgId = subPart.svgId(for: part, orientation: orientation),
                   let shape = svgView.getNode(byId: svgId) as? SVGShape {
                    
                    shape.onTapGesture {
                        handleBodyPartTap(part, subPart: subPart)
                    }
                    
                    updateSubPartColor(part, subPart: subPart, shape: shape, orientation: orientation)
                }
            }
        }
    }
    
    private func updateBodyPartCounts() {
        for part in BodyPart.allCases {
            for subPart in part.subParts {
                let key = makeKey(bodyPart: part, subPart: subPart)
                bodyPartCounts[key] = skinSpotService.getSpotsCount(for: part, subPart: subPart)
            }
        }
        
        updateAllBodyPartColors()
    }
    
    private func updateAllBodyPartColors() {
        updateBodyPartColors(for: frontSVGView, orientation: .front)
        updateBodyPartColors(for: backSVGView, orientation: .back)
    }
    
    private func updateBodyPartColors(for svgView: SVGView?, orientation: BodyOrientation) {
        guard let svgView = svgView else { return }
        
        for part in BodyPart.allCases {
            for subPart in part.subParts {
                if let svgId = subPart.svgId(for: part, orientation: orientation),
                   let shape = svgView.getNode(byId: svgId) as? SVGShape {
                    updateSubPartColor(part, subPart: subPart, shape: shape, orientation: orientation)
                }
            }
        }
    }
    
    private func updateSubPartColor(_ part: BodyPart, subPart: BodySubPart, shape: SVGShape, orientation: BodyOrientation) {
        let key = makeKey(bodyPart: part, subPart: subPart)
        let count = bodyPartCounts[key] ?? 0
        let color = getHeatmapColor(for: count)
        shape.fill = color
    }
    
    private func getHeatmapColor(for count: Int) -> SVGColor {
        switch count {
        case 0:
            return colorScheme == .dark ? SVGColor(hex: "4A5060") : SVGColor(hex: "C2C7D0")
        case 1...2:
            return SVGColor(hex: "FFB300") // Amber — clearly scanned
        case 3...5:
            return SVGColor(hex: "FB8C00") // Orange
        case 6...9:
            return SVGColor(hex: "F4511E") // Deep orange
        default:
            return SVGColor(hex: "C62828") // Deep red — heavily scanned
        }
    }
    
    private func handleBodyPartTap(_ part: BodyPart, subPart: BodySubPart) {
        selectedBodyPart = part
        selectedSubPart = subPart
    }
    
    private func makeKey(bodyPart: BodyPart, subPart: BodySubPart) -> String {
        return "\(bodyPart.rawValue)-\(subPart.rawValue)"
    }
}

#Preview {
    let fmService = FileManagerService()
    return BodyMapView()
        .environment(SkinSpotService(
            context: PersistenceController.preview.viewContext,
            fileManager: fmService
        ))
}


struct BodyPartConfig: Hashable {
    var bodyPart: BodyPart
    var bodyShape: SVGShape
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.bodyPart == rhs.bodyPart
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bodyPart)
    }
}
