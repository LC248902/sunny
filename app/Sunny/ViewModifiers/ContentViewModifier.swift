//
//  ContentViewModifier.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI

struct ContentViewModifier: ViewModifier {
    
    let bgColor: Color
    func body(content: Content) -> some View {
        content
            .padding()
            .background(bgColor)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func contentViewModifier(bgColor: Color = Color(UIColor.tertiarySystemBackground)) -> some View {
        modifier(ContentViewModifier(bgColor: bgColor))
    }
}
