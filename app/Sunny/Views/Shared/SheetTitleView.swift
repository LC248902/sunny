//
//  SheetTitleView.swift
//  Sunny
//
//  Created by Josh Bourke on 6/2/2026.
//

import SwiftUI

struct SheetTitleView: View {
    let title: String
    var subtitle: String? = nil
    let action: (() -> Void)?
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                if let subtitle {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                }
            }//: VSTACK
            Spacer(minLength: 0)
            if action != nil {
                Button {
                    action?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(Color.gray, Color.primary.opacity(0.1))
                }
            }
        }//: HSTACK
        .padding(.bottom, 10)
    }
}

#Preview {
    SheetTitleView(title: "Example", subtitle: nil, action: nil)
}
