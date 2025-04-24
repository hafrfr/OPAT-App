//
//  SubStep.swift
//  TemplateApplication
//
//  Created by Jacob Justad on 2025-04-18.
//

import SwiftUI

// Define a structure for individual substeps within an InstructionStep
struct SubStep: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String?
    let description: String
    let imageName: String?


}
