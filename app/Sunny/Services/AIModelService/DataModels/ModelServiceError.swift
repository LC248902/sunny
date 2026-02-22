//
//  ModelServiceError.swift
//  Sunny
//
//  Created by Josh Bourke on 13/2/2026.
//

import Foundation

// MARK: - Model Service Errors

enum ModelServiceError: LocalizedError {
    case modelNotLoaded
    case vlmRequired
    case parseError(String)
    
    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "Model is not loaded into memory."
        case .vlmRequired:
            return "This operation requires a Vision-Language Model (VLM)."
        case .parseError(let message):
            return "Parse error: \(message)"
        }
    }
}
