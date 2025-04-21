//
// Layout.swift
// Part of the OPAT @ Home Design System
//
// Centralized layout tokens for spacing, corner radius, and standard sizes.
// Uses adaptive scaling to stay visually consistent across iPhone sizes. (not iPa d right now!!)
//  Created by harre on 2025-04-21.
//

import SwiftUI

enum Layout {
    static let scaleFactor: CGFloat = 1.0
    // MARK: - Spacing
    enum Spacing {
        static var xSmall: CGFloat { 4 * scaleFactor }
        static var small: CGFloat { 8 * scaleFactor }
        static var medium: CGFloat { 16 * scaleFactor }
        static var large: CGFloat { 24 * scaleFactor }
        static var xLarge: CGFloat { 32 * scaleFactor }
    }
    // MARK: - Corner Radius
    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }

    // MARK: - Component Sizing
    static var buttonHeight: CGFloat { 56 * scaleFactor }
    static var cardPadding: CGFloat { 20 * scaleFactor }
}
