//
//  PrimaryButton.swift
//  Part of the OPAT @ Home Design System
//
//  Reusable filled button used across the app — e.g. “Get Started”, “Next”
//  Based on Sogeta’s Figma spec: padding, radius, color, typography
//
//  Created by harre on 2025-04-21.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FontTheme.button)
                .foregroundColor(.white)
                .padding(.vertical, 13)
                .padding(.horizontal, 20)
                .frame(minHeight: 48)
                .background(ColorTheme.buttonLarge)
                .cornerRadius(10)
        }
    }
}
