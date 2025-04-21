//
// ShadowTheme.swift
// Part of the OPAT @ Home Design System
//
// Defines reusable shadow styles for card components, buttons, etc.
// Designed to create a soft, approachable interface matching Figma.
//
//  Created by harre on 2025-04-21.
//

import SwiftUI

// MARK: - Shadow Styles

enum ShadowTheme {
    /// Soft shadow used for cards or elevated containers
    static let card = ShadowStyle(
        color: .black.opacity(0.1),
        radius: 8,
        offsetX: 0,
        offsetY: 4
    )

    /// Subtle shadow for buttons or lightweight elements
    static let button = ShadowStyle(
        color: .black.opacity(0.15),
        radius: 4,
        offsetX: 0,
        offsetY: 2
    )
}
// MARK: - Reusable Shadow Style Struct

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let offsetX: CGFloat
    let offsetY: CGFloat
}
// MARK: - View Modifier for Applying Shadows

struct ApplyShadow: ViewModifier {
    let style: ShadowStyle

    func body(content: Content) -> some View {
        content
            .shadow(
                color: style.color,
                radius: style.radius,
                x: style.offsetX,
                y: style.offsetY
            )
    }
}
extension View {
    func shadowStyle(_ style: ShadowStyle) -> some View {
        self.modifier(ApplyShadow(style: style))
    }
}
