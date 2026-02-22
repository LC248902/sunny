//
//  ModelDownloadOnboardingView.swift
//  Sunny
//
//  Created by Josh Bourke on 21/2/2026.
//

import SwiftUI

struct ModelDownloadOnboardingView: View {
    @Environment(AIModelService.self)
    private var aiModelService

    @State private var iconScale: CGFloat = 0.5
    @State private var contentOpacity: Double = 0
    @State private var hasStartedDownload: Bool = false

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.12))
                            .frame(width: 100, height: 100)

                        Image(systemName: iconName)
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(iconScale)
                    }
                    .padding(.top, 16)

                    // Title and subtitle
                    VStack(spacing: 10) {
                        Text(titleText)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)

                        Text(subtitleText)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .opacity(contentOpacity)

                    // Download progress / already installed state
                    downloadStatusCard
                        .opacity(contentOpacity)

                    // Feature cards
                    VStack(spacing: 14) {
                        ModelFeatureRow(
                            icon: "cpu.fill",
                            iconColor: .purple,
                            title: "Runs On-Device",
                            description: "Your skin photos never leave your phone — all analysis happens locally."
                        )

                        ModelFeatureRow(
                            icon: "arrow.clockwise.icloud",
                            iconColor: .blue,
                            title: "One-Time Install",
                            description: "You only need to download the model once, or again when it's updated."
                        )

                        ModelFeatureRow(
                            icon: "lock.shield.fill",
                            iconColor: .green,
                            title: "Private by Design",
                            description: "No internet connection required after download — your data stays yours."
                        )
                    }
                    .contentViewModifier()
                    .padding(.horizontal, 30)
                    .opacity(contentOpacity)

                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.orange)

                            Text("Not a Diagnostic Tool")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }

                        Text("This AI model is designed to help you track and monitor skin changes over time. It does not diagnose medical conditions. Always consult a qualified healthcare professional for any skin concerns.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange.opacity(0.1))
                    )
                    .padding(.horizontal, 30)
                    .opacity(contentOpacity)

                    Color.clear.frame(height: 120)
                }
            }
        }
        .backgroundViewModifier()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                contentOpacity = 1
            }
        }
    }

    // MARK: - Download Status Card

    @ViewBuilder
    private var downloadStatusCard: some View {
        VStack(spacing: 14) {
            switch aiModelService.modelState {
            case .idle:
                if aiModelService.isModelDownloadedLocally {
                    alreadyInstalledContent
                } else {
                    idleContent
                }

            case .downloading(let progress):
                downloadingContent(progress: progress)

            case .loading:
                loadingContent

            case .ready:
                successContent

            case .failed(let message):
                failedContent(message: message)

            case .generating:
                EmptyView()
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 30)
    }

    private var idleContent: some View {
        VStack(spacing: 8) {
            Image(systemName: "icloud.and.arrow.down")
                .font(.system(size: 32))
                .foregroundColor(.blue)

            Text("Sunny-MedGemma Model")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)

            Text("~2.5 GB · Requires Wi-Fi recommended")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
    }

    private func downloadingContent(progress: Double) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.purple)
                    .scaleEffect(0.9)

                Text("Downloading Model…")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(.purple)
                .frame(maxWidth: .infinity)

            Text("\(Int(progress * 100))% complete")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
    }

    private var loadingContent: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.blue)
                    .scaleEffect(0.9)

                Text("Loading into memory…")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
    }

    private var successContent: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.green)

            Text("Model Ready")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("The AI model is installed and ready to use.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var alreadyInstalledContent: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.green)

            Text("Already Installed")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("The AI model is already on your device and ready to go.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func failedContent(message: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)

            Text("Download Failed")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text(message)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
    }

    // MARK: - Dynamic Text

    private var titleText: String {
        switch aiModelService.modelState {
        case .ready: return "Model Installed"
        case .downloading: return "Downloading Model"
        case .loading: return "Almost Ready"
        case .failed: return "Download Failed"
        default:
            return aiModelService.isModelDownloadedLocally ? "Model Installed" : "Download the AI Model"
        }
    }

    private var subtitleText: String {
        switch aiModelService.modelState {
        case .ready:
            return "You're all set — the AI model is ready to analyse your skin."
        case .downloading:
            return "This may take a few minutes. Please keep the app open."
        case .loading:
            return "Preparing the model for first use."
        case .failed:
            return "Something went wrong. You can retry or continue and download later."
        default:
            return aiModelService.isModelDownloadedLocally
                ? "You're all set — the AI model is ready to analyse your skin."
                : "Sunny uses an on-device AI model to help monitor your skin. Download it once and it's yours forever."
        }
    }

    private var iconName: String {
        switch aiModelService.modelState {
        case .ready: return "checkmark.seal.fill"
        case .downloading, .loading: return "arrow.down.circle.fill"
        case .failed: return "exclamationmark.circle.fill"
        default:
            return aiModelService.isModelDownloadedLocally ? "checkmark.seal.fill" : "brain.head.profile"
        }
    }
}

// MARK: - Feature Row

struct ModelFeatureRow: View {
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
    ModelDownloadOnboardingView()
        .environment(AIModelService())
}
