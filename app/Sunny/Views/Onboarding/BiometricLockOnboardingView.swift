//
//  BiometricLockOnboardingView.swift
//  Sunny
//
//  Created by Josh Bourke on 21/2/2026.
//

import SwiftUI
import LocalAuthentication

struct BiometricLockOnboardingView: View {
    @Environment(OnboardingService.self)
    private var onboardingService

    @State private var iconScale: CGFloat = 0.5
    @State private var contentOpacity: Double = 0
    @State private var biometricType: LABiometryType = .none

    private var biometricIcon: String {
        switch biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        default: return "lock.fill"
        }
    }

    private var biometricName: String {
        switch biometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Passcode"
        }
    }

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.12))
                            .frame(width: 100, height: 100)

                        Image(systemName: biometricIcon)
                            .font(.system(size: 52))
                            .foregroundColor(.accentColor)
                            .scaleEffect(iconScale)
                    }
                    .padding(.top, 16)

                    // Title and subtitle
                    VStack(spacing: 10) {
                        Text("Protect Your Health Data")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)

                        Text("Your skin records contain personal medical information. You can require \(biometricName) to open Sunny.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .opacity(contentOpacity)

                    // Selection cards
                    VStack(spacing: 14) {
                        BiometricOptionCard(
                            icon: biometricIcon,
                            iconColor: .accentColor,
                            title: "Enable \(biometricName) Lock",
                            description: "Require \(biometricName) or your passcode every time you open Sunny.",
                            isSelected: onboardingService.wantsBiometricLock
                        ) {
                            HapticManager.shared.light()
                            onboardingService.wantsBiometricLock = true
                            onboardingService.hasSetBiometricPreference = true
                        }

                        BiometricOptionCard(
                            icon: "lock.open.fill",
                            iconColor: .secondary,
                            title: "Skip for Now",
                            description: "You can enable this later in the app's settings.",
                            isSelected: !onboardingService.wantsBiometricLock
                        ) {
                            HapticManager.shared.light()
                            onboardingService.wantsBiometricLock = false
                            onboardingService.hasSetBiometricPreference = true
                        }
                    }
                    .padding(.horizontal, 30)
                    .opacity(contentOpacity)

                    // Privacy info card
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.accentColor)

                            Text("Your Privacy Matters")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }

                        Text("Sunny stores all your health data on-device only. Enabling a lock ensures only you can access your personal skin monitoring records — similar to how a banking app protects your account.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.accentColor.opacity(0.08))
                    )
                    .padding(.horizontal, 30)
                    .opacity(contentOpacity)

                    Color.clear.frame(height: 120)
                }
            }
        }
        .backgroundViewModifier()
        .onAppear {
            // Detect biometric type
            let context = LAContext()
            var error: NSError?
            context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            biometricType = context.biometryType

            // Default to enabled if biometrics are available
            if biometricType != .none && !onboardingService.hasSetBiometricPreference {
                onboardingService.wantsBiometricLock = true
            }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                contentOpacity = 1
            }
        }
    }
}

// MARK: - Option Card

struct BiometricOptionCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)

                    Text(description)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .accentColor : Color(.tertiaryLabel))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: isSelected ? Color.accentColor.opacity(0.15) : .black.opacity(0.06),
                        radius: isSelected ? 10 : 8,
                        x: 0,
                        y: 4
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.accentColor.opacity(0.5) : Color.clear,
                                lineWidth: 1.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    BiometricLockOnboardingView()
        .environment(OnboardingService())
}
