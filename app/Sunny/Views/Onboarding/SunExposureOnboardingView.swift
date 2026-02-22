//
//  SunExposureOnboardingView.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI

struct SunExposureOnboardingView: View {
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
                        Text("How much sun exposure do you get?")
                            .font(.title2)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Understanding your sun habits helps me tailor recommendations")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer(minLength: 0)
                    
                    // Sun exposure options
                    VStack(spacing: 16) {
                        ForEach(OnboardingService.SunExposure.allCases, id: \.id) { exposure in
                            Button(action: {
                                HapticManager.shared.selection()
                                onboardingService.sunExposure = exposure
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(exposure.rawValue)
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        Text(exposure.description)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .stroke(onboardingService.sunExposure == exposure ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                        
                                        if onboardingService.sunExposure == exposure {
                                            Circle()
                                                .fill(Color.accentColor)
                                                .frame(width: 14, height: 14)
                                        }
                                    }
                                }
                                .contentViewModifier()
                                .overlay {
                                    if onboardingService.sunExposure == exposure {
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(style: StrokeStyle(lineWidth: 2))
                                            .foregroundStyle(.accent.opacity(0.5))
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Color.clear.frame(height: 120)
                }
            }//: SCROLL
        }//: ZSTACK
        .backgroundViewModifier()
    }
}

#Preview {
    SunExposureOnboardingView()
}

