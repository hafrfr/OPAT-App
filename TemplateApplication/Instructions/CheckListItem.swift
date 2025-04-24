// SpeziTemplateApplication/TemplateApplication/Instructions/ChecklistItem.swift
// (Corrected for Equatable/Hashable Conformance)

import SwiftUI

// Add Equatable and Hashable conformance
struct ChecklistItem: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let iconName: String // Name of the image in Assets
    var isChecked: Bool = false // State for the checkbox

    // Compiler can synthesize Equatable and Hashable requirements
    // because all stored properties conform.
}
