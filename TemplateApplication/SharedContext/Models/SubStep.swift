//
//  SubStep.swift
//  OPATApp
//
//  Created by Jacob Justad on 2025-04-29.
//
import Foundation

struct SubStep: Codable, Identifiable, Hashable {
    enum CodingKeys: String, CodingKey {
        case title, moreInfo, description, imageName
    }
    
    
    let id = UUID()
    let title: String? // Optioneal
    let moreInfo: String? // Optional
    let description: String
    let imageName: String? // Image name is optional

}
