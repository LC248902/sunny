//
//  OnboardingButtonOverlayView.swift
//  Steppy
//
//  Created by Josh Bourke on 14/1/2026.
//

import SwiftUI

struct OnboardingButtonOverlay: View {
    let buttonTitle: String
    let isButtonEnabled: Bool
    let onNext: () -> Void
    
    init(
        buttonTitle: String = "Next",
        isButtonEnabled: Bool = true,
        onNext: @escaping () -> Void
    ) {
        self.buttonTitle = buttonTitle
        self.isButtonEnabled = isButtonEnabled
        self.onNext = onNext
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 0) {
                // Button container with background
                Button(action: {
                    HapticManager.shared.medium() // Haptic on button tap
                    onNext()
                }) {
                    Text(buttonTitle)
                        .largeButtonViewModifier(bgColor: isButtonEnabled ? .accentColor : .secondary)
                }
                .disabled(!isButtonEnabled)
                .padding(.bottom)
                .padding(.horizontal)
            }
            .background(
                Rectangle()
                    .fill(.ultraThickMaterial)
                    .opacity(0.3)
                    .blur(radius: 8)
            )
        }
        .allowsHitTesting(isButtonEnabled) // Only allow interaction when enabled
    }
}

#Preview {
    OnboardingButtonOverlay(buttonTitle: "Next", isButtonEnabled: true, onNext: {})
}
