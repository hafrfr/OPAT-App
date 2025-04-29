// FAQModule.swift
// Updated to load all FAQs from a single Resources/FAQS.json file.

import Spezi
import Observation
import Foundation

@Observable
final class FAQModule: Module, DefaultInitializable, EnvironmentAccessible {
    var faqItems: [FAQItem] = []

    required init() {} 

    func configure() {
        self.faqItems = FAQModule.loadFAQsFromSingleFile() // Call the new function
        print("✅ FAQModule configured. Loaded \(faqItems.count) FAQ items from FAQS.json.")
        if faqItems.isEmpty {
             print("⚠️ FAQS.json might be missing, empty, incorrectly formatted, or not included in the target.")
        }
    }

  
    private static func loadFAQsFromSingleFile() -> [FAQItem] {
        // Attempt to find FAQS.json at the top-level bundle resources
        guard let url = Bundle.main.url(forResource: "FAQS", withExtension: "json") else {
            print("❌ FAQ Loader: Could not find FAQS.json in the bundle resources. Check filename and Target Membership.")
            return []
        }

        print("ℹ️ FAQ Loader: Found FAQS.json at URL: \(url.path)")

        do {
        
            let data = try Data(contentsOf: url)
            let loadedFAQs = try JSONDecoder().decode([FAQItem].self, from: data) // <-- Decode [FAQItem]

            print("✅ FAQ Loader: Successfully decoded \(loadedFAQs.count) FAQs from FAQS.json")

            return loadedFAQs.sorted { $0.question < $1.question }

        } catch let decodingError as DecodingError {
            print("❌ FAQ Loader: Error decoding FAQS.json: \(decodingError). Check JSON structure and FAQItem definition.")

            // }
            return []
        } catch {
            print("❌ FAQ Loader: Error reading data from FAQS.json: \(error)")
            return []
        }
    }
}
