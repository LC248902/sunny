//
//  BenefitsOnboardingView.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI

struct BenefitsOnboardingView: View {
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
                    
                    // Title
                    Text("The power of regular skin monitoring")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer(minLength: 0)
                    
                    // Benefits list
                    VStack(spacing: 16) {
                        BenefitRow(
                            icon: "eye.fill",
                            iconColor: .blue,
                            title: "Early detection",
                            description: "Regular monitoring helps you notice changes in your skin spots early"
                        )
                        .contentViewModifier()
                        
                        BenefitRow(
                            icon: "doc.text.fill",
                            iconColor: .green,
                            title: "Doctor-ready reports",
                            description: "Generate comprehensive reports with photo timelines for your healthcare provider"
                        )
                        .contentViewModifier()
                        
                        BenefitRow(
                            icon: "calendar.badge.clock",
                            iconColor: .orange,
                            title: "Track over time",
                            description: "Monitor how your skin spots change with organized photo history"
                        )
                        .contentViewModifier()
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer(minLength: 0)
                }//: VSTACK
            }//: SCROLL
        }//: ZSTACK
        .backgroundViewModifier()
    }
}

struct BenefitRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(iconColor)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    BenefitsOnboardingView()
}
