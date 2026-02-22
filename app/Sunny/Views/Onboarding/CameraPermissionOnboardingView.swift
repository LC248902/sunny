//
//  CameraPermissionOnboardingView.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI

struct CameraPermissionOnboardingView: View {
    @Environment(OnboardingService.self)
    private var onboardingService
    
    @Environment(\.openURL)
    private var openURL
    
    @State private var iconScale: CGFloat = 0.5
    @State private var iconRotation: Double = 0
    @State private var contentOpacity: Double = 0
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Camera icon with animation
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                            .scaleEffect(iconScale)
                            .rotationEffect(.degrees(iconRotation))
                    }
                    .padding(.top, 16)
                    
                    // Title and subtitle
                    VStack(spacing: 12) {
                        Text("Enable Camera Access")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Sunny needs camera access to photograph your skin spots")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .opacity(contentOpacity)
                    
                    // Camera features we'll use
                    VStack(spacing: 16) {
                        CameraFeatureRow(
                            icon: "camera.viewfinder",
                            iconColor: .blue,
                            title: "Capture Photos",
                            description: "Take clear, high-quality photos of skin spots"
                        )
                        
                        CameraFeatureRow(
                            icon: "photo.on.rectangle.angled",
                            iconColor: .green,
                            title: "Compare Over Time",
                            description: "Track changes by comparing photos side-by-side"
                        )
                        
                        CameraFeatureRow(
                            icon: "ruler.fill",
                            iconColor: .orange,
                            title: "Guided Capture",
                            description: "Get helpful guides for consistent photo angles"
                        )
                    }
                    .contentViewModifier()
                    .padding(.horizontal, 30)
                    .opacity(contentOpacity)
                    
                    // Privacy info
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.accentColor)
                            
                            Text("Your photos stay private and secure")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        
                        Text("All photos are stored securely on your device. Sunny never shares your images without your explicit permission.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.accentColor.opacity(0.1))
                    )
                    .padding(.horizontal, 30)
                    .opacity(contentOpacity)
                    
                    // Links to privacy and terms
                    HStack(spacing: 4) {
                        Button(action: {
                            HapticManager.shared.light()
                            if let url = URL(string: privacyURL) {
                                openURL(url)
                            }
                        }) {
                            Text("Privacy Policy")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.accentColor)
                        }
                        
                        Text("·")
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            HapticManager.shared.light()
                            if let url = URL(string: termsURL) {
                                openURL(url)
                            }
                        }) {
                            Text("Terms of Service")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.accentColor)
                        }
                    }
                    .opacity(contentOpacity)
                    
                    // Bottom padding
                    Color.clear.frame(height: 120)
                }
            }
        }
        .backgroundViewModifier()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
            
            // Icon pulse
            withAnimation(.easeInOut(duration: 0.4).delay(0.6)) {
                iconScale = 1.1
            }
            withAnimation(.easeInOut(duration: 0.3).delay(1.0)) {
                iconScale = 1.0
            }
            
            // Content fade in
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                contentOpacity = 1
            }
        }
    }
}

// Camera feature row component
struct CameraFeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    CameraPermissionOnboardingView()
}
