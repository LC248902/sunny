//
//  ReminderFrequencyOnboardingView.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI

struct ReminderFrequencyOnboardingView: View {
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
                        Text("Set your check-in reminder")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Regular monitoring helps catch changes early")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer(minLength: 0)
                    
                    // Reminder frequency options
                    VStack(spacing: 16) {
                        ForEach(OnboardingService.ReminderFrequency.allCases, id: \.id) { frequency in
                            Button(action: {
                                HapticManager.shared.selection()
                                onboardingService.reminderFrequency = frequency
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(frequency.rawValue)
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        if let desc = frequency.description {
                                            Text(desc)
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .stroke(onboardingService.reminderFrequency == frequency ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                        
                                        if onboardingService.reminderFrequency == frequency {
                                            Circle()
                                                .fill(Color.accentColor)
                                                .frame(width: 14, height: 14)
                                        }
                                    }
                                }
                                .contentViewModifier()
                                .overlay {
                                    if onboardingService.reminderFrequency == frequency {
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
                    
                    // Helpful tip
                    HStack(spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                        
                        Text("Medical experts recommend checking your skin spots monthly for any changes")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.yellow.opacity(0.1))
                    )
                    .padding(.horizontal, 30)
                    
                    Color.clear.frame(height: 120)
                }//: VSTACK
            }//: SCROLL
        }//: ZSTACK
        .backgroundViewModifier()
    }
}

#Preview {
    ReminderFrequencyOnboardingView()
}
