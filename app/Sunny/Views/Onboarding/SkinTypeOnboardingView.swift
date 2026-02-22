//
//  SkinTypeOnboardingView.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI

struct SkinTypeOnboardingView: View {
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
                        Text("What's your skin type?")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("This helps me personalize your skin health journey")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer(minLength: 0)
                    
                    // Skin type options
                    VStack(spacing: 16) {
                        ForEach(OnboardingService.SkinType.allCases, id: \.id) { skinType in
                            Button(action: {
                                HapticManager.shared.selection()
                                onboardingService.selectedSkinType = skinType
                            }) {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(skinType.color)
                                            .frame(width: 44, height: 44)
                                        
                                        Circle()
                                            .strokeBorder(Color.black.opacity(0.1), lineWidth: 1)
                                            .frame(width: 44, height: 44)
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(skinType.rawValue)
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        Text(skinType.description)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .stroke(onboardingService.selectedSkinType == skinType ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                        
                                        if onboardingService.selectedSkinType == skinType {
                                            Circle()
                                                .fill(Color.accentColor)
                                                .frame(width: 14, height: 14)
                                        }
                                    }
                                }
                                .contentViewModifier()
                                .overlay {
                                    if onboardingService.selectedSkinType == skinType {
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
                }//: VSTACK
            }//: SCROLL
        }
        .backgroundViewModifier()
    }
}

#Preview {
    SkinTypeOnboardingView()
}

