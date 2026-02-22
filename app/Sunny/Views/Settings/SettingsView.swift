//
//  SettingsView.swift
//  Sunny
//
//  Created by Josh Bourke on 21/2/2026.
//

import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    @Environment(BiometricService.self)
    private var biometricService

    @State private var isEnablingBiometrics = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - Privacy & Security
                    VStack(alignment: .leading, spacing: 6) {
                        sectionHeader("Privacy & Security")

                        VStack(spacing: 0) {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.accentColor)
                                        .frame(width: 34, height: 34)
                                    Image(systemName: biometricService.biometricIcon)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(biometricService.biometricName) Lock")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("Require \(biometricService.biometricName) to open Sunny")
                                        .font(.system(size: 13, weight: .regular, design: .rounded))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if isEnablingBiometrics {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .scaleEffect(0.8)
                                } else {
                                    Toggle("", isOn: Binding(
                                        get: { biometricService.isAuthEnabled },
                                        set: { newValue in
                                            handleBiometricToggle(newValue)
                                        }
                                    ))
                                    .labelsHidden()
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .contentViewModifier()

                        Text("When enabled, you will need to authenticate with \(biometricService.biometricName) or your passcode each time you open Sunny. Your skin health data never leaves your device.")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                    }

                    // MARK: - Reports
                    VStack(alignment: .leading, spacing: 6) {
                        sectionHeader("Reports")

                        NavigationLink(destination: ReportsView()) {
                            HStack {
                                Label("Exported Reports", systemImage: "doc.richtext")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .contentViewModifier()
                        }
                        .buttonStyle(.plain)
                    }

                    // MARK: - About
                    VStack(alignment: .leading, spacing: 6) {
                        sectionHeader("About")

                        VStack(spacing: 0) {
                            HStack {
                                Label("Version", systemImage: "info.circle")
                                Spacer()
                                Text("\(appVersion) (\(buildNumber))")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 15, design: .rounded))
                            }

                            Divider()
                                .padding(.vertical, 8)

                            HStack {
                                Label("AI Model", systemImage: "brain.head.profile")
                                Spacer()
                                Text("Sunny-MedGemma")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 15, design: .rounded))
                            }
                        }
                        .contentViewModifier()
                    }

                    // MARK: - Disclaimer
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 13))
                                .foregroundColor(.orange)
                            Text("Medical Disclaimer")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        Text("Sunny is a skin tracking tool only. It does not provide medical diagnoses or advice. Always consult a qualified healthcare professional for any skin concerns.")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .contentViewModifier()

                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .backgroundViewModifier()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 4)
    }

    // MARK: - Toggle Handler

    private func handleBiometricToggle(_ enable: Bool) {
        HapticManager.shared.light()

        if enable {
            isEnablingBiometrics = true
            Task {
                let success = await biometricService.authenticate()
                isEnablingBiometrics = false
                if success {
                    biometricService.isAuthEnabled = true
                }
            }
        } else {
            biometricService.isAuthEnabled = false
        }
    }
}

#Preview {
    SettingsView()
        .environment(BiometricService())
}
