//
//  LargeButtonViewModifier.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI

struct LargeButtonViewModifier: ViewModifier {
    
    let bgColor: Color
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding()
            .background(bgColor)
            .foregroundColor(.white)
            .cornerRadius(20)
            .fontWeight(.bold)
    }
}

extension View {
    func largeButtonViewModifier(bgColor: Color = .accentColor) -> some View {
        modifier(LargeButtonViewModifier(bgColor: bgColor))
    }
}

