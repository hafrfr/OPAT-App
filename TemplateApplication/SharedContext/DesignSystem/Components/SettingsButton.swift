//
//
// SettingsButton.swift
// Part of the OPAT @ Home application
//
// Reusable, accessible settings button component.
// Designed to match SpeziViews style standards.
// Created by harre on 2025-04-26.
//

import SwiftUI

public struct SettingsButton: View {
    private let action: () -> Void
    private let color: Color
    private let size: Font

    public init(
        color: Color = .primary,
        size: Font = .title3,
        action: @escaping () -> Void
    ) {
        self.color = color
        self.size = size
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "gearshape.fill")
                .font(size)
                .foregroundColor(color)
                .frame(width: 44, height: 44) // Tap target size
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Settings")
    }
}

#if DEBUG
#Preview {
    SettingsButton {
        print("Settings tapped")
    }
}
#endif

