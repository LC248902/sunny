//
//  CameraService.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import AVFoundation
import UIKit

@Observable
class CameraService {
    
    // MARK: - Properties
    
    var authorizationStatus: AVAuthorizationStatus = .notDetermined
    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }
    
    // MARK: - Initialization
    
    init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization Methods
    
    /// Check the current camera authorization status
    func checkAuthorizationStatus() {
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    /// Request camera authorization from the user (async version)
    @MainActor
    func requestAuthorization() async -> Bool {
        checkAuthorizationStatus()
        
        switch authorizationStatus {
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            authorizationStatus = granted ? .authorized : .denied
            return granted
            
        case .restricted, .denied:
            print("Camera access denied or restricted. User must enable in Settings.")
            return false
            
        case .authorized:
            // Already authorized
            return true
            
        @unknown default:
            print("Unknown authorization status")
            return false
        }
    }
    
    /// Request camera authorization with completion handler (for backwards compatibility)
    func requestPermission(completion: @escaping (Bool) -> Void) {
        Task { @MainActor in
            let granted = await requestAuthorization()
            completion(granted)
        }
    }
    
    /// Open the app settings so user can enable camera manually
    func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
    
    // MARK: - Camera Availability
    
    /// Check if the device has a camera
    func isCameraAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    /// Get available camera positions
    func getAvailableCameraPositions() -> [AVCaptureDevice.Position] {
        var positions: [AVCaptureDevice.Position] = []
        
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        
        for device in discoverySession.devices {
            if !positions.contains(device.position) {
                positions.append(device.position)
            }
        }
        
        return positions
    }
    
    // MARK: - Status Description
    
    var statusDescription: String {
        switch authorizationStatus {
        case .notDetermined:
            return "Camera permission not requested yet"
        case .restricted:
            return "Camera access is restricted"
        case .denied:
            return "Camera access denied. Enable in Settings."
        case .authorized:
            return "Camera access granted"
        @unknown default:
            return "Unknown camera status"
        }
    }
}
