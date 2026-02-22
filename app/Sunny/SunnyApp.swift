//
//  SunnyApp.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//
//  Main app entry point with onboarding integration

import SwiftUI
import AVFoundation
import CoreData

@main
struct SunnyApp: App {

    // MARK: - Persistence

    private let persistenceController = PersistenceController.shared

    // MARK: - Services

    @State private var fileManagerService: FileManagerService
    @State private var skinSpotService: SkinSpotService
    @State private var onboardingService: OnboardingService
    @State private var cameraService: CameraService
    @State private var aiModelService: AIModelService
    @State private var biometricService: BiometricService

    // MARK: - Onboarding

    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

    // MARK: - Init

    init() {
        let fmService = FileManagerService()
        _fileManagerService = State(initialValue: fmService)
        _skinSpotService = State(initialValue: SkinSpotService(
            context: PersistenceController.shared.viewContext,
            fileManager: fmService
        ))
        _onboardingService = State(initialValue: OnboardingService())
        _cameraService = State(initialValue: CameraService())
        _aiModelService = State(initialValue: AIModelService())
        _biometricService = State(initialValue: BiometricService())
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environment(aiModelService)
                    .environment(cameraService)
                    .environment(skinSpotService)
                    .environment(fileManagerService)
                    .environment(biometricService)
                    .environment(\.managedObjectContext, persistenceController.viewContext)
            } else {
                OnboardingContainerView {
                    hasCompletedOnboarding = true
                    // Sync biometric lock state from what the user chose in onboarding
                    if UserDefaults.standard.bool(forKey: "biometricLockEnabled") {
                        biometricService.isLocked = false // Already unlocked — they just set it up
                    }
                }
                .environment(onboardingService)
                .environment(cameraService)
                .environment(aiModelService)
                .environment(biometricService)
            }
        }
    }
}
