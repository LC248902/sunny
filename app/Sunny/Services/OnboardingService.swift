//
//  OnboardingService.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import Foundation
import SwiftUI

@Observable
class OnboardingService {
    
    // MARK: - User Selections
    var selectedAge: AgeRange?
    var selectedSkinType: SkinType?
    var sunExposure: SunExposure?
    var reminderFrequency: ReminderFrequency?
    var hasRequestedCamera: Bool = false
    var wantsBiometricLock: Bool = false
    var hasSetBiometricPreference: Bool = false
    
    // MARK: - Navigation
    var currentStep: Int = 0
    var transitionDirection: TransitionDirection = .forward
    
    // MARK: - Enums
    
    enum AgeRange: String, CaseIterable, Identifiable {
        case under18 = "Under 18"
        case age18to29 = "18-29"
        case age30to49 = "30-49"
        case age50to64 = "50-64"
        case age65plus = "65+"
        
        var id: String { rawValue }
    }
    
    enum SkinType: String, CaseIterable, Identifiable {
        case type1 = "Type I - Very Fair"
        case type2 = "Type II - Fair"
        case type3 = "Type III - Medium"
        case type4 = "Type IV - Olive"
        case type5 = "Type V - Brown"
        case type6 = "Type VI - Dark Brown/Black"
        
        var id: String { rawValue }
        
        var description: String {
            switch self {
            case .type1:
                return "Always burns, never tans"
            case .type2:
                return "Usually burns, tans minimally"
            case .type3:
                return "Sometimes burns, tans uniformly"
            case .type4:
                return "Burns minimally, tans easily"
            case .type5:
                return "Rarely burns, tans darkly"
            case .type6:
                return "Never burns, deeply pigmented"
            }
        }
        
        /// Representative color for each Fitzpatrick skin type
        var color: Color {
            switch self {
            case .type1:
                return Color(red: 0.98, green: 0.89, blue: 0.84) // Very pale/porcelain
            case .type2:
                return Color(red: 0.96, green: 0.85, blue: 0.75) // Fair/light beige
            case .type3:
                return Color(red: 0.91, green: 0.76, blue: 0.62) // Medium beige
            case .type4:
                return Color(red: 0.80, green: 0.63, blue: 0.48) // Olive/moderate brown
            case .type5:
                return Color(red: 0.63, green: 0.46, blue: 0.33) // Brown
            case .type6:
                return Color(red: 0.38, green: 0.25, blue: 0.18) // Dark brown/black
            }
        }
    }
    
    enum SunExposure: String, CaseIterable, Identifiable {
        case minimal = "Minimal"
        case moderate = "Moderate"
        case frequent = "Frequent"
        case extensive = "Extensive"
        
        var id: String { rawValue }
        
        var description: String {
            switch self {
            case .minimal:
                return "Mostly indoors, limited sun"
            case .moderate:
                return "Some outdoor activities"
            case .frequent:
                return "Regular outdoor exposure"
            case .extensive:
                return "Work or play outdoors daily"
            }
        }
    }
    
    enum ReminderFrequency: String, CaseIterable, Identifiable {
        case weekly = "Weekly"
        case biweekly = "Every 2 Weeks"
        case monthly = "Monthly"
        case quarterly = "Every 3 Months"
        case never = "No Reminders"
        
        var id: String { rawValue }
        
        var description: String? {
            switch self {
            case .weekly:
                return "Check your skin every week"
            case .biweekly:
                return "Check twice per month"
            case .monthly:
                return "Recommended by dermatologists"
            case .quarterly:
                return "Check seasonally"
            case .never:
                return "I'll remember on my own"
            }
        }
    }
    
    enum TransitionDirection {
        case forward
        case backward
    }
    
    // MARK: - Navigation Methods
    
    func nextStep() {
        transitionDirection = .forward
        withAnimation {
            currentStep += 1
        }
    }
    
    func previousStep() {
        transitionDirection = .backward
        withAnimation {
            currentStep = max(0, currentStep - 1)
        }
    }
    
    // MARK: - Save Onboarding Completion
    
    func saveOnboardingCompletion() {
        // Save to UserDefaults
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Save user selections
        if let age = selectedAge {
            UserDefaults.standard.set(age.rawValue, forKey: "userAge")
        }
        
        if let skinType = selectedSkinType {
            UserDefaults.standard.set(skinType.rawValue, forKey: "userSkinType")
        }
        
        if let exposure = sunExposure {
            UserDefaults.standard.set(exposure.rawValue, forKey: "userSunExposure")
        }
        
        if let frequency = reminderFrequency {
            UserDefaults.standard.set(frequency.rawValue, forKey: "userReminderFrequency")
            
            // Schedule notifications based on frequency
            scheduleReminders(frequency: frequency)
        }

        // Save biometric lock preference
        UserDefaults.standard.set(wantsBiometricLock, forKey: "biometricLockEnabled")
    }
    
    // MARK: - Notification Scheduling
    
    private func scheduleReminders(frequency: ReminderFrequency) {
        print("Scheduling reminders with frequency: \(frequency.rawValue)")
        
        switch frequency {
        case .weekly:
            // Schedule weekly notifications
            break
        case .biweekly:
            // Schedule bi-weekly notifications
            break
        case .monthly:
            // Schedule monthly notifications
            break
        case .quarterly:
            // Schedule quarterly notifications
            break
        case .never:
            // Cancel all notifications
            break
        }
    }
    
    // MARK: - Reset (for testing)
    
    func reset() {
        currentStep = 0
        selectedAge = nil
        selectedSkinType = nil
        sunExposure = nil
        reminderFrequency = nil
        hasRequestedCamera = false
        transitionDirection = .forward
        
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(false, forKey: "biometricLockEnabled")
        wantsBiometricLock = false
        hasSetBiometricPreference = false
    }
}
