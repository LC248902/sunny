//
//  MainAppView.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI
import AVFoundation

enum CurrentBodyCaptureView {
    case scanOptions
    case bodyPartSelection
    case bodyPartBreakDownSelection
    case cameraOrPhotoLibrarySelection
}

struct MainAppView: View {
    @Environment(CameraService.self)
    private var cameraService
    
    @Environment(SkinSpotService.self)
    private var skinSpotService
    
    @Environment(AIModelService.self)
    private var aiService
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    // Compact header — doubles as model status
                    HStack(spacing: 10) {
                        Image(.sunnyHead)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 45, height: 45)
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sunny")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            headerSubtitle
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        headerStatusIndicator
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 4)
                    
                    BodyMapView()
                    
                    // Quick stats
                    HStack(spacing: 12) {
                        StatCard(
                            icon: "camera.fill",
                            value: "\(skinSpotService.totalPhotoCount)",
                            label: "Photos",
                            color: .blue
                        )
                        
                        StatCard(
                            icon: "checkmark.circle.fill",
                            value: "\(skinSpotService.scannedBodyPartsCount)",
                            label: "Scanned",
                            color: .green
                        )
                        
                        StatCard(
                            icon: "clock.badge.exclamationmark",
                            value: "\(skinSpotService.needsUpdateCount)",
                            label: "Updates",
                            color: .orange
                        )
                    }//: HSTACK
                    
                    // Showing a body coverage percentage.
                    BodyCoverageView()
                    
                    disclaimerView
                }//: VSTACK
                .padding()
            }
            .scrollIndicators(.hidden)
            .toolbarVisibility(.hidden, for: .navigationBar)
            .backgroundViewModifier()
        }
    }
    
    // MARK: - Header Subtitle & Indicator
    
    @ViewBuilder
    private var headerSubtitle: some View {
        switch aiService.modelState {
        case .idle:
            if aiService.isModelDownloadedLocally {
                Text("Track your skin health")
                    .foregroundColor(.secondary)
            } else {
                Text("AI model needs to be downloaded")
                    .foregroundColor(.orange)
            }
        case .downloading(let progress):
            let pct = Int(progress * 100)
            Text(progress < 0.01 ? "Starting download (~2.5 GB)..." : "Downloading AI model... \(pct)%")
                .foregroundColor(.orange)
        case .loading:
            Text("Loading AI model...")
                .foregroundColor(.orange)
        case .generating:
            Text("Analyzing image...")
                .foregroundColor(.orange)
        case .ready:
            Text("Track your skin health")
                .foregroundColor(.secondary)
        case .failed:
            Text("AI model error — tap to retry")
                .foregroundColor(.red)
        }
    }
    
    @ViewBuilder
    private var headerStatusIndicator: some View {
        if case .downloading(let progress) = aiService.modelState {
            ProgressView(value: progress)
                .frame(width: 52)
                .tint(.orange)
        } else if case .generating = aiService.modelState {
            ProgressView()
                .scaleEffect(0.8)
                .tint(.orange)
        } else if case .loading = aiService.modelState {
            ProgressView()
                .scaleEffect(0.8)
                .tint(.orange)
        }
    }

    @ViewBuilder
    private var disclaimerView: some View {
        Text("Sunny is for tracking purposes only and does not provide medical advice or diagnosis. Consult a healthcare professional for medical concerns.")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
    }
}


#Preview {
    MainAppView()
        .environment(CameraService())
}
