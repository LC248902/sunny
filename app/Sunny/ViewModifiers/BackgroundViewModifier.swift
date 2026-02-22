//
//  BackgroundViewModifier.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI

struct BackgroundViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThickMaterial)
    }
}

extension View {
    func backgroundViewModifier() -> some View {
        modifier(BackgroundViewModifier())
    }
}
