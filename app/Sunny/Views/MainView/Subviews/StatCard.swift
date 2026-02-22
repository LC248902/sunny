//
//  StatCard.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI

// MARK: - Stat Card Component

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .padding(6)
                .background(color.opacity(0.1), in: .rect(cornerRadius: 8))
            
            Text(value)
                .font(.headline)
                .fontDesign(.rounded)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(label)
                .font(.footnote)
                .fontDesign(.rounded)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .contentViewModifier()
    }
}

//#Preview {
//    StatCard()
//}
