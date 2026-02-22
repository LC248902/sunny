//
//  AgeSelectionOnboardingView.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI

struct AgeSelectionOnboardingView: View {
    
    @Environment(OnboardingService.self)
    private var onboardingService
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Mascot icon area
                    ZStack {
                        Image("Sunny_Head")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    }
                    .padding(.top, 16)
                    
                    // Title and subtitle
                    VStack(spacing: 12) {
                        Text("How old are you?")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Age helps me understand your skin health needs")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer(minLength: 0)
                    
                    // Age range options
                    VStack(spacing: 16) {
                        ForEach(OnboardingService.AgeRange.allCases, id: \.id) { range in
                            Button(action: {
                                HapticManager.shared.selection()
                                onboardingService.selectedAge = range
                                
                            }) {
                                HStack {
                                    Text(range.rawValue)
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .stroke(onboardingService.selectedAge == range ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                        
                                        if onboardingService.selectedAge == range {
                                            Circle()
                                                .fill(Color.accentColor)
                                                .frame(width: 14, height: 14)
                                        }
                                    }
                                }
                                .contentViewModifier()
                                .overlay {
                                    if onboardingService.selectedAge == range {
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(style: StrokeStyle(lineWidth: 2))
                                            .foregroundStyle(Color.accentColor.opacity(0.5))
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Color.clear.frame(height: 120)
                }//: VSTACK
            }//: SCROLL VIEW
        }
        .backgroundViewModifier()
    }
}

#Preview {
    AgeSelectionOnboardingView()
}

