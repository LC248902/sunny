//
//  ModelInfo.swift
//  Sunny
//
//  Created by Josh Bourke on 13/2/2026.
//

import Foundation
import MLXLMCommon

struct ModelInfo: Identifiable, Hashable {
    let id: String          // HuggingFace model ID e.g. "mlx-community/gemma-3-4b-it-4bit"
    let displayName: String
    let isVLM: Bool         // Vision Language Model (supports images)
    
    var configuration: ModelConfiguration {
        ModelConfiguration(id: id)
    }
}
