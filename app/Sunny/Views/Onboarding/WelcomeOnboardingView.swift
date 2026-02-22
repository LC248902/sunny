//
//  WelcomeOnboardingView.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI

struct WelcomeOnboardingView: View {
    @Binding var buttonOpacity: Double
    @Binding var buttonYOffset: CGFloat
    
    @State private var mascotYOffset: CGFloat = 500
    @State private var titleOpacity: Double = 0
    @State private var titleYOffset: CGFloat = 20
    @State private var subtitleOpacity: Double = 0
    @State private var subtitleYOffset: CGFloat = 20
    
    var body: some View {
        ZStack {
            Color.accentColor
                .opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                ZStack {
                    Image("Sunny_Head") // Your sun mascot image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240)
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                        .padding(.bottom, 50)
                        .offset(y: mascotYOffset)
                }
                .frame(maxHeight: .infinity)
                
                // The Text and Button Area
                VStack(spacing: 20) {
                    Text("G'day, I'm Sunny!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .opacity(titleOpacity)
                        .offset(y: titleYOffset)
                    
                    Text("I'm here to help you monitor your skin health and prepare for doctor visits.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 40)
                        .fontWeight(.semibold)
                        .opacity(subtitleOpacity)
                        .offset(y: subtitleYOffset)
                    
                    Spacer()
                }//: VSTACK
                .background(Color(UIColor.tertiarySystemBackground), in: .rect(cornerRadius: 30))
                .background(
                    Circle()
                        .fill(Color(UIColor.tertiarySystemBackground))
                        .frame(width: 600, height: 600)
                )
            }
        }
        .clipped()
        .ignoresSafeArea()
        .onAppear {
            // Mascot springs up
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                mascotYOffset = 0
            }
            
            // Title fades in and slides up after mascot
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                titleOpacity = 1
                titleYOffset = 0
            }
            
            // Subtitle fades in and slides up
            withAnimation(.easeOut(duration: 0.6).delay(0.7)) {
                subtitleOpacity = 1
                subtitleYOffset = 0
            }
            
            // Button fades in and slides up last
            withAnimation(.easeOut(duration: 0.6).delay(1.0)) {
                buttonOpacity = 1
                buttonYOffset = 0
            }
        }
    }
}

#Preview {
    WelcomeOnboardingView(buttonOpacity: .constant(0), buttonYOffset: .constant(20))
}
