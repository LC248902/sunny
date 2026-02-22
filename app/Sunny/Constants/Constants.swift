//
//  Constants.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//
import Foundation

// MARK: - App URLs

/// Privacy policy URL
let privacyURL = "https://sunny.app/privacy"

/// Terms of service URL
let termsURL = "https://sunny.app/terms"

// MARK: - UserDefaults Keys

enum UserDefaultsKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let userAge = "userAge"
    static let userSkinType = "userSkinType"
    static let userSunExposure = "userSunExposure"
    static let userReminderFrequency = "userReminderFrequency"
}

// MARK: - App Configuration

enum AppConfig {
    static let appName = "Sunny"
    static let shareableLink = "https://sunny.app/download"
    
    // Notification identifiers
    static let reminderNotificationIdentifier = "skinCheckReminder"
}
