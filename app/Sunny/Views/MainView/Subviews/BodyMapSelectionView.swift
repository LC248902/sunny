//
//  BodyMapSelectionView.swift
//  Sunny
//
//  Created by Josh Bourke on 5/2/2026.
//

import SwiftUI

struct BodyMapSelection: View {
    @State private var selectedPart: String = "Select a part"
    
    func colorForPart(_ part: String) -> Color {
        return selectedPart == part ? .red : .blue.opacity(0.3)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(selectedPart)
                .font(.headline)
                .padding()
                .background(Capsule().fill(Color.secondary.opacity(0.2)))

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                ZStack {
                    // 1. The Base Figure
                    Image(systemName: "figure")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray.opacity(0.3))
                    
                    // 2. Interactive Zones (Buttons)
                    Group {
                        bodyPartButton("Head", size: CGSize(width: w * 0.2, height: h * 0.15))
                            .position(x: w * 0.5, y: h * 0.1)

                        bodyPartButton("Torso", size: CGSize(width: w * 0.25, height: h * 0.3))
                            .position(x: w * 0.5, y: h * 0.38)

                        bodyPartButton("Arm Left", size: CGSize(width: w * 0.2, height: h * 0.15))
                            .position(x: w * 0.28, y: h * 0.25)

                        bodyPartButton("Arm Right", size: CGSize(width: w * 0.2, height: h * 0.15))
                            .position(x: w * 0.72, y: h * 0.25)

                        bodyPartButton("Leg Left", size: CGSize(width: w * 0.15, height: h * 0.35))
                            .position(x: w * 0.4, y: h * 0.75)

                        bodyPartButton("Leg Right", size: CGSize(width: w * 0.15, height: h * 0.35))
                            .position(x: w * 0.6, y: h * 0.75)
                    }
                }
            }
            .frame(width: 200, height: 400) // Adjust base size as needed
            .padding()
        }
    }

    // Helper to create buttons
    @ViewBuilder
    func bodyPartButton(_ name: String, size: CGSize) -> some View {
        Button(action: {
            selectedPart = name
        }) {
            RoundedRectangle(cornerRadius: 10)
                .fill(colorForPart(name)) // This acts as your heatmap/selector
        }
        .frame(width: size.width, height: size.height)
    }
}

#Preview {
    BodyMapSelection()
}
