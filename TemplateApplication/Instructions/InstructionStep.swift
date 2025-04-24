// SpeziTemplateApplication/TemplateApplication/Instructions/InstructionStep.swift
// (Corrected for Initialization Error)

import SwiftUI


struct InstructionStep: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let substeps: [SubStep] // SubStep is now Hashable
    let overallImageName: String?

    init(title: String, substeps: [SubStep], overallImageName: String? = nil) {
        self.title = title
        self.substeps = substeps
        self.overallImageName = overallImageName
    }


}
