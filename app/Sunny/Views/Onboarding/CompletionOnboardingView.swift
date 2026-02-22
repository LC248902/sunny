//
//  CompletionOnboardingView.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI

struct CompletionOnboardingView: View {
    @Environment(OnboardingService.self)
    private var onboardingService
    
    @Environment(\.dismiss)
    private var dismiss
    
    @State private var mascotScale: CGFloat = 0.5
    @State private var mascotRotation: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleScale: CGFloat = 0.8
    @State private var contentOpacity: Double = 0
    @State private var confettiCounter: Int = 0
    @State private var showShareSheet: Bool = false
    
    // Shareable link
    private let shareableLink = "https://sunny.app/download"
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Animated Sunny mascot with celebration
                    ZStack {
                        // Confetti effect
                        ConfettiView(counter: $confettiCounter)
                        
                        Image("Sunny_Head")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                            .scaleEffect(mascotScale)
                            .rotationEffect(.degrees(mascotRotation))
                    }
                    .frame(height: 200)
                    
                    // Celebration title
                    VStack(spacing: 12) {
                        Text("You're All Set! 🎉")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .opacity(titleOpacity)
                            .scaleEffect(titleScale)
                        
                        Text("Ready to start monitoring your skin health!")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .opacity(contentOpacity)
                    }
                    .padding(.horizontal, 40)
                    
                    // Quick tips card
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            TipItem(
                                icon: "camera.fill",
                                iconColor: .blue,
                                text: "Take clear photos"
                            )
                            
                            Divider()
                                .frame(height: 40)
                            
                            TipItem(
                                icon: "calendar",
                                iconColor: .green,
                                text: "Check monthly"
                            )
                            
                            Divider()
                                .frame(height: 40)
                            
                            TipItem(
                                icon: "stethoscope",
                                iconColor: .red,
                                text: "Share with doctor"
                            )
                        }
                        .padding()
                    }
                    .contentViewModifier()
                    .padding(.horizontal, 30)
                    .opacity(contentOpacity)
                    
                    // Important reminder
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.orange)
                            
                            Text("Remember")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        
                        Text("Sunny is a tracking tool, not a diagnostic tool. Always consult a healthcare professional for medical advice about skin concerns.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange.opacity(0.1))
                    )
                    .padding(.horizontal, 30)
                    .opacity(contentOpacity)
                    
                    // Share section
                    VStack(spacing: 16) {
                        Text("Share Sunny")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Help friends and family stay on top of their skin health")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Secondary style share button
                        Button(action: {
                            HapticManager.shared.light()
                            showShareSheet = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Share Sunny")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.accentColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.accentColor.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1.5)
                            )
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.top, 10)
                    .opacity(contentOpacity)
                    
                    // Bottom padding
                    Color.clear.frame(height: 120)
                }
            }
        }
        .backgroundViewModifier()
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [shareableLink])
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                mascotScale = 1.0
            }
            
            // Mascot wiggle
            withAnimation(.easeInOut(duration: 0.3).delay(0.6)) {
                mascotRotation = -10
            }
            withAnimation(.easeInOut(duration: 0.3).delay(0.9)) {
                mascotRotation = 10
            }
            withAnimation(.easeInOut(duration: 0.3).delay(1.2)) {
                mascotRotation = 0
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4)) {
                titleOpacity = 1
                titleScale = 1.0
            }
            
            // Content fade in
            withAnimation(.easeOut(duration: 0.6).delay(0.8)) {
                contentOpacity = 1
            }
            
            // Trigger confetti
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                confettiCounter += 1
                HapticManager.shared.sequence(count: 3, delay: 0.05, style: .medium)
            }
        }
    }
}

// Tip item component
struct TipItem: View {
    let icon: String
    let iconColor: Color
    let text: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
            
            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// Confetti animation view
struct ConfettiView: View {
    @Binding var counter: Int
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { index in
                ConfettiPiece(counter: counter, index: index)
            }
        }
    }
}

struct ConfettiPiece: View {
    let counter: Int
    let index: Int
    
    @State private var location: CGPoint = .zero
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 1
    
    private var color: Color {
        [Color.red, Color.blue, Color.green, Color.yellow, Color.orange, Color.purple, Color.pink].randomElement() ?? .blue
    }
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .scaleEffect(scale)
            .opacity(opacity)
            .position(location)
            .onChange(of: counter) { oldValue, newValue in
                startAnimation()
            }
    }
    
    private func startAnimation() {
        location = CGPoint(x: UIScreen.main.bounds.width / 2, y: 100)
        opacity = 1
        scale = 1
        
        let angle = Double.random(in: 0...(2 * .pi))
        let radius = CGFloat.random(in: 100...200)
        let endX = UIScreen.main.bounds.width / 2 + cos(angle) * radius
        let endY = 100 + sin(angle) * radius + CGFloat.random(in: 100...300)
        
        withAnimation(.easeOut(duration: Double.random(in: 0.8...1.5))) {
            location = CGPoint(x: endX, y: endY)
            opacity = 0
            scale = CGFloat.random(in: 0.2...0.8)
        }
    }
}

// Share sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    CompletionOnboardingView()
}
