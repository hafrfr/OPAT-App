// File: Modules/GuideModule.swift (Modified to load from TOP-LEVEL Resources)
import Spezi
import SwiftUI
import Foundation

@Observable
final class GuideModule: Module, DefaultInitializable, EnvironmentAccessible {
    var guides: [Guide] = []
    // List of JSON filenames in the TOP-LEVEL Resources directory to explicitly ignore
    private let ignoredJsonFiles = ["FAQS.json", "OPATFollowUp.json", "SocialSupportQuestionnaire.json"] // Add others if needed

    required init() {}

    func configure() {
        // Call the function to load from the top-level Resources directory
        self.guides = loadIndividualGuidesFromTopLevelResources()
        print("✅ GuideModule configured. Loaded \(guides.count) guides from TOP-LEVEL Resources.")
        if guides.isEmpty {
            print("⚠️ No guides loaded.")
        }
    }

    // Function to load individual files from the top-level bundle resources directory
    private func loadIndividualGuidesFromTopLevelResources() -> [Guide] {
        var loadedGuides: [Guide] = []
        let fileManager = FileManager.default

        guard let resourceUrl = Bundle.main.resourceURL else { // Get base Resources URL
            print("❌ GuideModule: Could not get the main bundle resource URL.")
            return []
        }

        print("✅ GuideModule: Searching for guides in top-level resource directory: \(resourceUrl.path)")

        let directoryContents: [URL]
        do {
            // Get contents of the main Resources directory
            directoryContents = try fileManager.contentsOfDirectory(at: resourceUrl, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        } catch {
            print("❌ GuideModule: Could not access top-level resource directory. Error: \(error)")
            return []
        }

        let jsonFileURLs = directoryContents.filter { $0.pathExtension.lowercased() == "json" }

        if jsonFileURLs.isEmpty {
            print("ℹ️ GuideModule: No .json files found in top-level 'Resources/'.")
            return []
        }

        print("ℹ️ GuideModule: Found JSON files in top-level Resources: \(jsonFileURLs.map { $0.lastPathComponent })")

        for url in jsonFileURLs {
            let filename = url.lastPathComponent
            // Skip ignored JSON files
            if ignoredJsonFiles.contains(filename) {
                 print("ℹ️ GuideModule: Skipping ignored JSON file: \(filename)")
                 continue
            }

            // Attempt to decode as a Guide
            do {
                let data = try Data(contentsOf: url)
                let guide = try JSONDecoder().decode(Guide.self, from: data) // Still uses the NEW Guide struct
                loadedGuides.append(guide)
                print("✅ GuideModule: Successfully loaded guide: \(guide.title) from \(filename)")
            } catch let decodingError as DecodingError {
                 print("❌ GuideModule: Error decoding \(filename) as Guide: \(decodingError).")
                 print("   Check JSON structure matches Guide (ensure it's NOT an array). Skipping this file.")
            } catch {
                print("❌ GuideModule: Error reading data from \(filename): \(error). Skipping this file.")
            }
        }

        return loadedGuides.sorted { $0.title < $1.title }
    }
}
