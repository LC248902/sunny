//
//  ModelState.swift
//  Sunny
//
//  Created by Josh Bourke on 13/2/2026.
//

import Foundation


enum ModelState: Equatable {
    case idle
    case downloading(progress: Double)
    case loading
    case ready
    case generating
    case failed(String)
}
