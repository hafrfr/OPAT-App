// SpeziTemplateApplication/TemplateApplication/Instructions/InstructionGuideInfo.swift
// (Should now compile correctly)

import SwiftUI
struct InstructionGuideInfo: Identifiable, Hashable {
    let id = UUID()
    let title: String // Overall guide title
    let iconName: String
    let checklistItems: [ChecklistItem]
    let steps: [InstructionStep]
}
