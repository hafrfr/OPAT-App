// TemplateApplication/SharedContext/Helpers/GuideLoader.swift
// Handles loading Guides from the app bundle.
// Updated loadAllGuides to search the top-level resource directory.

import Foundation

enum GuideLoader {
    static func loadGuide(named filename: String) -> Guide? {
        // Looks directly in the main bundle resources (no subdirectory)
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("❌ Could not find JSON file named \(filename).json in top-level resources.")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let guide = try JSONDecoder().decode(Guide.self, from: data)
            return guide
        } catch {
            print("❌ Error decoding guide \(filename).json: \(error)")
            return nil
        }
    }

    static func loadAllGuides() -> [Guide] {
        guard let resourceUrl = Bundle.main.resourceURL else {
            print("❌ Could not get the main bundle resource URL.")
             return []
        }

        // Print the path being searched
        print("✅ Searching for guides in top-level resource directory: \(resourceUrl.path)")

        var allGuides: [Guide] = []
        let fileManager = FileManager.default

        do {
            // Get URLs for all files in the main resource directory
            let fileURLs = try fileManager.contentsOfDirectory(
                at: resourceUrl,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles] // Skip hidden files like .DS_Store
            )

            // Filter for JSON files directly within this directory
            let jsonFileURLs = fileURLs.filter { $0.pathExtension.lowercased() == "json" }

            if jsonFileURLs.isEmpty {
                print("ℹ️ No guide (.json) files were found in the top-level resource directory.")
                return []
            }

            print("ℹ️ Found JSON files: \(jsonFileURLs.map { $0.lastPathComponent })")

            // Attempt to load and decode each JSON file
            for url in jsonFileURLs {
                 guard !url.lastPathComponent.contains("Questionnaire") && !url.lastPathComponent.contains("OPATFollowUp") else {
                     print("ℹ️ Skipping non-guide JSON file: \(url.lastPathComponent)")
                     continue
                 }

                do {
                    let data = try Data(contentsOf: url)
                    let guide = try JSONDecoder().decode(Guide.self, from: data)
                    allGuides.append(guide)
                    print("✅ Successfully loaded guide: \(guide.title)")
                } catch {
                    print("❌ Error processing guide file \(url.lastPathComponent): \(error). Skipping this file.")
                }
            }

            // Sort guides alphabetically by title for consistent order (optional)
            allGuides.sort { $0.title < $1.title }

            return allGuides
        } catch {
            print("❌ Error accessing top-level resource directory \(resourceUrl.path): \(error)")
            return []
        }
    }
}
