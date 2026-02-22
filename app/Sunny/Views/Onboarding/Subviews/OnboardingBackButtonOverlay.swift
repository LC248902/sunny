//
//  OnboardingBackButtonOverlayView.swift
//  Steppy
//
//  Created by Josh Bourke on 14/1/2026.
//

import SwiftUI

struct OnboardingBackButtonOverlay: View {
    let onBack: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    HapticManager.shared.light() // Light haptic for back button
                    onBack()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.accentColor)
                        .padding(12)
                }
                .padding(.leading, 16)
                .padding(.top, 50)
                
                Spacer()
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingBackButtonOverlay(onBack: {})
}
