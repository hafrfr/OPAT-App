//
//  GuideLoader.swift
//  OPATApp
//
//  Created by harre on 2025-04-28.
//


// GuideLoader.swift
// Handles loading Guides from the app bundle

import Foundation

enum GuideLoader {
    static func loadGuide(named filename: String) -> Guide? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("❌ Could not find JSON file named \(filename).json")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let guide = try JSONDecoder().decode(Guide.self, from: data)
            return guide
        } catch {
            print("❌ Error decoding guide \(filename): \(error)")
            return nil
        }
    }
}
