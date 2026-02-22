//
//  BodyCoverageView.swift
//  Sunny
//
//  Created by Josh Bourke on 5/2/2026.
//

import SwiftUI

struct BodyCoverageView: View {
    @Environment(SkinSpotService.self)
    private var skinSpotService
    
    var body: some View {
        // Progress bar
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Body Coverage")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                
                Spacer()
                
                Text("\(Int(skinSpotService.completionPercentage))%")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange)
                        .frame(
                            width: geometry.size.width * (skinSpotService.completionPercentage / 100),
                            height: 12
                        )
                }
            }
            .frame(height: 12)
        }
        .frame(maxWidth: .infinity)
        .contentViewModifier()
    }
}

#Preview {
    BodyCoverageView()
}
