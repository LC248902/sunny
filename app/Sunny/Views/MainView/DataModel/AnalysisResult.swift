//
//  AnalysisResult.swift
//  Sunny
//
//  Created by Josh Bourke on 13/2/2026.
//
import Foundation
import SwiftUI

struct AnalysisResult: Identifiable {
    let id = UUID()
    let image: UIImage
    let bodyPart: String
    let record: SkinLesionRecord
    
    var timestamp: Date {
        record.date ?? Date()
    }
    
    var tokensPerSecond: Double? {
        guard let latency = record.latency,
              let latencyDouble = Double(latency),
              latencyDouble > 0 else { return nil }
        // Rough estimate: assume ~500 tokens generated
        return 500.0 / latencyDouble
    }
    
    init(image: UIImage, bodyPart: String, record: SkinLesionRecord) {
        self.image = image
        self.bodyPart = bodyPart
        self.record = record
    }
}
