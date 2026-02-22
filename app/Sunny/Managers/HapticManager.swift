//
//  HapticManager.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//
import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // Light impact - for button taps and selections
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    // Medium impact - for transitions and animations
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // Heavy impact - for completion and major events
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    // Success - for positive confirmations
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // Selection changed - for picker-style interactions
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // Error - for failed actions and invalid inputs
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // Sequential taps - for multiple rapid haptics
    func sequence(count: Int, delay: TimeInterval = 0.1, style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + (delay * Double(i))) {
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.impactOccurred()
            }
        }
    }
}
