//
//  MainStep.swift
//  OPATApp
//
//  Created by Jacob Justad on 2025-04-29.
//
import Foundation

struct MainStep: Codable, Identifiable, Hashable {
    enum CodingKeys: String, CodingKey {
        case title, substeps
    }
    
    let id = UUID()
    let title: String
    let substeps: [SubStep]   
}
