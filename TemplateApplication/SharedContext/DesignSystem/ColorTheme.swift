//
//  ColorTheme.swift
// Defines a central color palette for the OPAT app.
//
//  Created by harre on 2025-04-21.
//


import SwiftUI
/// Centralized color palette for the OPAT app, based on Figma design by Sogeta<3
/// Easy to maintain - just update hex values here to apply globally throughout our app :D
enum ColorTheme {
    // MARK: - Text & Backgrounds
    static let title = Color(hex: "#03045E")
    static let mainBackground = Color.white
    static let contentContainerBackground = Color.white

    // MARK: - Header Gradient
    static let headerGradientStart = Color(hex: "#CAF0F8")
    static let headerGradientEnd = Color(hex: "#00A2B1")

    // MARK: - Buttons
    static let buttonLarge = Color(hex: "#005B8A")

    // MARK: - List Items
    static let listItemBackground = Color.white

    // MARK: - Tab Bar
    static let tabBarItemInactive = Color.black.opacity(0.25)
    static let tabBarItemActive = Color(hex: "#005B8A")
    static let tabBarBackground = Color.white

    // MARK: - Progress Bar
    static let progressInactive = Color(hex: "#C7D3EB")
    static let progressActive = Color(hex: "#219EBC")

    // MARK: - FAQ Highlight
    static let openFAQBorderGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "#00A2B1"), Color(hex: "#005B8A")]),
        startPoint: .leading,
        endPoint: .trailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)

        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }

        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let red = Double((rgbValue >> 16) & 0xFF) / 255
        let green = Double((rgbValue >> 8) & 0xFF) / 255
        let blue = Double(rgbValue & 0xFF) / 255

        self.init(red: red, green: green, blue: blue)
    }
}
