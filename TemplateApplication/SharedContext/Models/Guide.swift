//
//  Guide.swift
//  OPATApp
//
//  Created by harre on 2025-04-28.
//
import Foundation

struct Guide: Codable, Identifiable, Hashable {
    // 1. Subtype (enum CodingKeys) comes first
    enum CodingKeys: String, CodingKey {
        case title = "GuideTitle" // Map title (Swift) to "GuideTitle" (JSON)
        case steps
        case category
        // Note: 'id' is often omitted here if not present in JSON
    }

    // 2. Instance properties follow
    let id = UUID() // If id is only used locally, it doesn't need to be in CodingKeys
    let title: String
    let steps: [MainStep] // Assumes MainStep is defined elsewhere (part of the new structure)
    let category: String? // e.g. "Before Infusion", "During Infusion", etc.

}
