//
//  OnboardingContainerView.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI

struct OnboardingContainerView: View {
    @Environment(OnboardingService.self)
    private var onboardingService

    @Environment(CameraService.self)
    private var cameraService

    @Environment(AIModelService.self)
    private var aiModelService

    @Environment(BiometricService.self)
    private var biometricService

    let onOnboardingComplete: () -> Void

    // Animation state for welcome screen button
    @State private var buttonOpacity: Double = 0
    @State private var buttonYOffset: CGFloat = 20

    // Track whether a download task is in flight
    @State private var isDownloading: Bool = false

    var body: some View {
        ZStack {
            // Show the appropriate view based on current step
            Group {
                switch onboardingService.currentStep {
                case 0:
                    WelcomeOnboardingView(buttonOpacity: $buttonOpacity, buttonYOffset: $buttonYOffset)
                case 1:
                    AgeSelectionOnboardingView()
                case 2:
                    SkinTypeOnboardingView()
                case 3:
                    SunExposureOnboardingView()
                case 4:
                    BenefitsOnboardingView()
                case 5:
                    HowItWorksOnboardingView()
                case 6:
                    ReminderFrequencyOnboardingView()
                case 7:
                    CameraPermissionOnboardingView()
                case 8:
                    ModelDownloadOnboardingView()
                case 9:
                    BiometricLockOnboardingView()
                case 10:
                    CompletionOnboardingView()
                default:
                    CompletionOnboardingView()
                }
            }
            .transition(currentTransition)
            .zIndex(onboardingService.transitionDirection == .forward ? 1 : 0)
            .id(onboardingService.currentStep)

            // Back button overlay (show on all screens except welcome and completion)
            if onboardingService.currentStep > 0 && onboardingService.currentStep < 10 {
                OnboardingBackButtonOverlay {
                    onboardingService.previousStep()
                }
                .transition(.opacity)
                .zIndex(2)
            }

            // Button overlay stays in place during transitions
            if onboardingService.currentStep <= 10 {
                OnboardingButtonOverlay(
                    buttonTitle: currentButtonTitle,
                    isButtonEnabled: isNextButtonEnabled,
                    onNext: {
                        handleNextTapped()
                    }
                )
                .opacity(onboardingService.currentStep == 0 ? buttonOpacity : 1.0)
                .offset(y: onboardingService.currentStep == 0 ? buttonYOffset : 0)
                .zIndex(2)
            }
        }
        .animation(.smooth(duration: 0.35), value: onboardingService.currentStep)
        .onAppear {
            if onboardingService.currentStep == 0 {
                withAnimation(.easeOut(duration: 0.6).delay(1.0)) {
                    buttonOpacity = 1
                    buttonYOffset = 0
                }
            } else {
                buttonOpacity = 1
                buttonYOffset = 0
            }
        }
        .onChange(of: onboardingService.currentStep) { oldValue, newValue in
            if newValue == 0 {
                buttonOpacity = 0
                buttonYOffset = 20
                withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
                    buttonOpacity = 1
                    buttonYOffset = 0
                }
            } else if oldValue == 0 {
                buttonOpacity = 1
                buttonYOffset = 0
            }
        }
        .onChange(of: aiModelService.modelState) { _, newState in
            if newState == .ready && onboardingService.currentStep == 8 {
                isDownloading = false
                // Small delay so the user sees the success state
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    onboardingService.nextStep()
                }
            }
            if case .failed = newState {
                isDownloading = false
            }
        }
    }

    // MARK: - Button Title

    private var currentButtonTitle: String {
        switch onboardingService.currentStep {
        case 0: return "Get Started 🌞"
        case 7: return "Enable Camera"
        case 8: return modelDownloadButtonTitle
        case 9: return onboardingService.wantsBiometricLock ? "Enable \(biometricDisplayName)" : "Skip"
        case 10: return "Start Tracking! 📸"
        default: return "Next"
        }
    }

    private var modelDownloadButtonTitle: String {
        switch aiModelService.modelState {
        case .downloading: return "Downloading…"
        case .loading: return "Loading…"
        case .ready: return "Continue"
        default:
            return aiModelService.isModelDownloadedLocally ? "Continue" : "Download Model"
        }
    }

    private var biometricDisplayName: String {
        // Mirrors BiometricService naming without importing LA here
        // The actual permission prompt will use the system name
        "Biometric Lock"
    }

    // MARK: - Button Enabled State

    private var isNextButtonEnabled: Bool {
        switch onboardingService.currentStep {
        case 0: return true
        case 1: return onboardingService.selectedAge != nil
        case 2: return onboardingService.selectedSkinType != nil
        case 3: return onboardingService.sunExposure != nil
        case 4: return true
        case 5: return true
        case 6: return onboardingService.reminderFrequency != nil
        case 7: return true
        case 8: return !isDownloading && modelStep8ButtonEnabled
        case 9: return true
        case 10: return true
        default: return false
        }
    }

    private var modelStep8ButtonEnabled: Bool {
        switch aiModelService.modelState {
        case .downloading, .loading: return false
        default: return true
        }
    }

    // MARK: - Next Handler

    private func handleNextTapped() {
        HapticManager.shared.medium()

        switch onboardingService.currentStep {
        case 7:
            // Camera permission
            Task {
                await cameraService.requestAuthorization()
                onboardingService.hasRequestedCamera = true
                onboardingService.nextStep()
            }

        case 8:
            // If already downloaded or ready, just advance
            if aiModelService.isModelDownloadedLocally || aiModelService.modelState == .ready {
                onboardingService.nextStep()
                return
            }
            // Otherwise kick off the download; onChange handles the advance
            isDownloading = true
            Task {
                await aiModelService.loadModel(aiModelService.model)
            }

        case 9:
            onboardingService.nextStep()
            if onboardingService.wantsBiometricLock {
                Task { await biometricService.authenticate() }
            }

        case 10:
            // Completion — save and finish onboarding
            HapticManager.shared.success()
            onboardingService.saveOnboardingCompletion()
            onOnboardingComplete()

        default:
            onboardingService.nextStep()
        }
    }

    // MARK: - Transition

    private var currentTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: onboardingService.transitionDirection == .forward ? .trailing : .leading),
            removal: .move(edge: onboardingService.transitionDirection == .forward ? .leading : .trailing)
        )
    }
}

#Preview {
    OnboardingContainerView(onOnboardingComplete: {})
        .environment(OnboardingService())
        .environment(CameraService())
        .environment(AIModelService())
        .environment(BiometricService())
}
