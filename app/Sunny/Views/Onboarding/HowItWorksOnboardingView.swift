//
//  HowItWorksOnboardingView.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI

struct HowItWorksOnboardingView: View {
    @Environment(OnboardingService.self)
    private var onboardingService
    
    @State private var step1Opacity: Double = 0
    @State private var step2Opacity: Double = 0
    @State private var step3Opacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var hasAnimated: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
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
                        Text("How Sunny Works")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Three simple steps to better skin health")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    .opacity(textOpacity)
                    
                    // Important disclaimer
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                            
                            Text("Not a medical diagnostic tool")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.1))
                    )
                    .padding(.horizontal, 30)
                    .opacity(textOpacity)
                    
                    VStack(spacing: 20) {
                        ProcessStep(
                            number: "1",
                            icon: "camera.fill",
                            iconColor: .blue,
                            title: "Capture Photos",
                            description: "Take clear photos of your skin spots with guided camera assistance"
                        )
                        .opacity(step1Opacity)
                        
                        ProcessStep(
                            number: "2",
                            icon: "chart.line.uptrend.xyaxis",
                            iconColor: .green,
                            title: "Track Changes",
                            description: "Monitor how your spots evolve over time with organized photo timelines"
                        )
                        .opacity(step2Opacity)
                        
                        ProcessStep(
                            number: "3",
                            icon: "doc.text.fill",
                            iconColor: .orange,
                            title: "Generate Reports",
                            description: "Create professional reports to share with your doctor during checkups"
                        )
                        .opacity(step3Opacity)
                    }
                    .padding(.horizontal, 30)
                
                    // Bottom padding
                    Color.clear.frame(height: 120)
                }
            }
        }
        .backgroundViewModifier()
        .onAppear {
            guard !hasAnimated else { return }
            hasAnimated = true
            
            // Fade in text elements
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                textOpacity = 1
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                step1Opacity = 1
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(0.7)) {
                step2Opacity = 1
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(1.0)) {
                step3Opacity = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                HapticManager.shared.light()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                HapticManager.shared.light()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                HapticManager.shared.light()
            }
        }
    }
}

struct ProcessStep: View {
    let number: String
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                VStack(spacing: 2) {
                    Text(number)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(iconColor)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                }
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .contentViewModifier()
    }
}

#Preview {
    HowItWorksOnboardingView()
}
