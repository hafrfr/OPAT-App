//
// FontTheme.swift
// Part of the OPAT @ Home Design System
//
// Defines standardized font styles for headings, body text, buttons, and other UI elements.
// Based on Sogeta’s Figma design spec for consistency and visual clarity.
//
// Created by harre on 2025-04-21.
//

import SwiftUI

enum FontTheme {
    // MARK: - Headings
    static let title = Font.system(size: 24, weight: .bold) // Title text

    // MARK: - Body
    static let body = Font.system(size: 16, weight: .regular) // Regular body text
    static let bodyBold = Font.system(size: 16, weight: .semibold)
    static let categoryBold = Font.system(size: 18, weight: .semibold)

    // MARK: - Buttons
    static let button = Font.system(size: 16, weight: .semibold) // Button text style

    // MARK: - Progress / Steps
    static let progress = Font.system(size: 14, weight: .regular) // Step or progress text

    // MARK: - FAQ
    static let faqQuestion = Font.system(size: 18, weight: .semibold)
    static let faqAnswer = Font.system(size: 16, weight: .regular)
}
