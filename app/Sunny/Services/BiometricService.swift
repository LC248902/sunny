//
//  BiometricService.swift
//  Sunny
//
//  Created by Josh Bourke on 21/2/2026.
//

import Foundation
import LocalAuthentication
import SwiftUI

@Observable
class BiometricService {

    // MARK: - Properties

    var isLocked: Bool = false
    var biometricType: LABiometryType = .none

    var isAuthEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "biometricLockEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "biometricLockEnabled") }
    }

    // MARK: - Init

    init() {
        let context = LAContext()
        var error: NSError?
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        biometricType = context.biometryType

        // Lock immediately on launch if auth is enabled
        if isAuthEnabled {
            isLocked = true
        }
    }

    // MARK: - Authentication

    /// Prompts the user to authenticate with biometrics or their passcode.
    /// Returns `true` on success.
    @MainActor
    func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            // Device has no passcode / biometrics — just unlock
            isLocked = false
            return true
        }

        let reason = "Unlock Sunny to access your personal skin health data."

        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
            if success {
                isLocked = false
            }
            return success
        } catch {
            // User cancelled or failed — remain locked
            return false
        }
    }

    // MARK: - Lock / Unlock

    func lock() {
        guard isAuthEnabled else { return }
        isLocked = true
    }

    func unlock() {
        isLocked = false
    }

    // MARK: - Biometric Name Helpers

    var biometricName: String {
        switch biometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Passcode"
        }
    }

    var biometricIcon: String {
        switch biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        default: return "lock.fill"
        }
    }
}
