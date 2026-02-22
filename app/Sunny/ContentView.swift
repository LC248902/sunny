//
//  ContentView.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(BiometricService.self)
    private var biometricService
 
    @Environment(\.scenePhase)
    private var scenePhase

    var body: some View {
        ZStack {
            // Main app tabs
            TabView {
                Tab {
                    MainAppView()
                } label: {
                    Label("Overview", systemImage: "figure")
                }
                Tab {
                    SavedScansView()
                } label: {
                    Label("Saved", systemImage: "photo.on.rectangle.angled")
                }
                Tab(role: .search) {
                    AddScanView()
                } label: {
                    Image(systemName: "plus")
                    Text("Add")
                }
                Tab {
                    SettingsView()
                } label: {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            }
            .tabViewStyle(.sidebarAdaptable)

            // Biometric lock overlay
            if biometricService.isLocked {
                LockScreenView()
                    .transition(.opacity)
                    .zIndex(999)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: biometricService.isLocked)
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                biometricService.lock()
            case .active:
                if biometricService.isLocked {
                    Task {
                        await biometricService.authenticate()
                    }
                }
            default:
                break
            }
        }
        .task {
            if biometricService.isLocked {
                await biometricService.authenticate()
            }
        }
    }
}

// MARK: - Lock Screen

struct LockScreenView: View {
    @Environment(BiometricService.self)
    private var biometricService

    @State private var isAuthenticating = false
    @State private var didFail = false
    @State private var logoScale: CGFloat = 0.85

    var body: some View {
        ZStack {
            // Blurred background
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // App icon / logo
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.accentColor.opacity(0.2), Color.accentColor.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)

                        Image("Sunny_Head")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                    }
                    .scaleEffect(logoScale)
                    .onAppear {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                            logoScale = 1.0
                        }
                    }

                    Text("Sunny is Locked")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("Your health data is protected.\nAuthenticate to continue.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Unlock button
                VStack(spacing: 14) {
                    if didFail {
                        Text("Authentication failed. Please try again.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                    }

                    Button(action: {
                        guard !isAuthenticating else { return }
                        HapticManager.shared.medium()
                        isAuthenticating = true
                        didFail = false
                        Task {
                            let success = await biometricService.authenticate()
                            isAuthenticating = false
                            if !success {
                                withAnimation {
                                    didFail = true
                                }
                                HapticManager.shared.error()
                            }
                        }
                    }) {
                        HStack(spacing: 10) {
                            if isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                                    .scaleEffect(0.85)
                            } else {
                                Image(systemName: biometricService.biometricIcon)
                                    .font(.system(size: 20, weight: .semibold))
                            }

                            Text(isAuthenticating ? "Authenticating…" : "Unlock with \(biometricService.biometricName)")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.accentColor)
                        )
                    }
                    .disabled(isAuthenticating)
                    .padding(.horizontal, 40)
                }

                Color.clear.frame(height: 40)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(BiometricService())
}
