//
//  Guide.swift
//  OPATApp
//
//  Created by harre on 2025-04-28.
//


// Guide.swift
// Represents a complete instructional guide loaded from JSON

import Foundation

struct Guide: Codable, Identifiable {
    let id = UUID() 
    let title: String
    let steps: [InstructionStep]

    struct InstructionStep: Codable, Identifiable {
        var id: Int { stepNumber }
        let stepNumber: Int
        let description: String
        let moreInfo: String
        let imageName: String
    }
}
