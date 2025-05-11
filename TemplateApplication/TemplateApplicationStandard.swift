//
// This source file is part of the Stanford Spezi Template Application open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseStorage
import HealthKitOnFHIR
import OSLog
@preconcurrency import PDFKit.PDFDocument
import Spezi
import SpeziAccount
import SpeziFirebaseAccount
import SpeziFirestore
import SpeziHealthKit
import SpeziOnboarding
import SpeziQuestionnaire
import SwiftUI


actor TemplateApplicationStandard: Standard,
                                   EnvironmentAccessible,
                                   ConsentConstraint,
                                   AccountNotifyConstraint {
    @Application(\.logger) private var logger

    @Dependency(FirebaseConfiguration.self) private var configuration

    init() {}


    func add(sample: HKSample) async {
        if FeatureFlags.disableFirebase {
            logger.debug("Received new HealthKit sample: \(sample)")
            return
        }
        
        do {
            try await healthKitDocument(id: sample.id)
                .setData(from: sample.resource)
        } catch {
            logger.error("Could not store HealthKit sample: \(error)")
        }
    }
    
    func remove(sample: HKDeletedObject) async {
        if FeatureFlags.disableFirebase {
            logger.debug("Received new removed healthkit sample with id \(sample.uuid)")
            return
        }
        
        do {
            try await healthKitDocument(id: sample.uuid).delete()
        } catch {
            logger.error("Could not remove HealthKit sample: \(error)")
        }
    }

    // periphery:ignore:parameters isolation
    func add(response: ModelsR4.QuestionnaireResponse, isolation: isolated (any Actor)? = #isolation) async {
        let id = response.identifier?.value?.value?.string ?? UUID().uuidString
        
        if FeatureFlags.disableFirebase {
            let jsonRepresentation = (try? String(data: JSONEncoder().encode(response), encoding: .utf8)) ?? ""
            await logger.debug("Received questionnaire response: \(jsonRepresentation)")
            return
        }
        
        do {
            try await configuration.userDocumentReference
                .collection("QuestionnaireResponse") // Add all HealthKit sources in a /QuestionnaireResponse collection.
                .document(id) // Set the document identifier to the id of the response.
                .setData(from: response)
        } catch {
            await logger.error("Could not store questionnaire response: \(error)")
        }
    }
    
    
    private func healthKitDocument(id uuid: UUID) async throws -> DocumentReference {
        try await configuration.userDocumentReference
            .collection("HealthKit") // Add all HealthKit sources in a /HealthKit collection.
            .document(uuid.uuidString) // Set the document identifier to the UUID of the document.
    }

    func respondToEvent(_ event: AccountNotifications.Event) async {
        if case let .deletingAccount(accountId) = event {
            do {
                try await configuration.userDocumentReference(for: accountId).delete()
            } catch {
                logger.error("Could not delete user document: \(error)")
            }
        }
    }
    
    
    func save(treatment: Treatment) async {
            if FeatureFlags.disableFirebase {
                // Log locally or handle differently if Firebase is off
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted // For readable log output
                if let jsonData = try? encoder.encode(treatment),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    logger.debug("Received treatment to save (Firebase disabled): \(jsonString)")
                } else {
                    logger.debug("Received treatment to save (Firebase disabled), but couldn't encode: \(treatment.id)")
                }
                return
            }

            do {
                // Get the reference to the current user's document
                let userDocRef = try await configuration.userDocumentReference

                // Create a reference to a "treatments" subcollection and a document for this specific treatment
                // Using treatment.id.uuidString ensures each treatment has its own document.
                let treatmentDocRef = userDocRef.collection("treatments").document(treatment.id.uuidString)

                // Save the treatment data. Firestore's setData(from:) can take a Codable object.
                try await treatmentDocRef.setData(from: treatment)
                logger.info("Successfully saved treatment \(treatment.id.uuidString) to Firestore.")
            } catch {
                logger.error("Could not store treatment \(treatment.id.uuidString): \(error)")
            }
        }

        // New method to delete a single treatment
        func delete(treatment: Treatment) async {
            if FeatureFlags.disableFirebase {
                logger.debug("Received treatment to delete (Firebase disabled): \(treatment.id)")
                return
            }

            do {
                let userDocRef = try await configuration.userDocumentReference
                let treatmentDocRef = userDocRef.collection("treatments").document(treatment.id.uuidString)
                try await treatmentDocRef.delete()
                logger.info("Successfully deleted treatment \(treatment.id.uuidString) from Firestore.")
            } catch {
                logger.error("Could not delete treatment \(treatment.id.uuidString): \(error)")
            }
        }

        // Optional: Method to fetch all treatments for the current user
        func fetchTreatments() async -> [Treatment] {
            if FeatureFlags.disableFirebase {
                logger.debug("Fetching treatments skipped (Firebase disabled).")
                return [] // Or return locally stored treatments if you implement that
            }

            do {
                let userDocRef = try await configuration.userDocumentReference
                let snapshot = try await userDocRef.collection("treatments").getDocuments()

                let treatments = snapshot.documents.compactMap { document -> Treatment? in
                    try? document.data(as: Treatment.self)
                }
                logger.info("Successfully fetched \(treatments.count) treatments from Firestore.")
                return treatments
            } catch {
                logger.error("Failed to fetch treatments: \(error)")
                return []
            }
        }
    
    
    /// Stores the given consent form in the user's document directory with a unique timestamped filename.
    ///
    /// - Parameter consent: The consent form's data to be stored as a `PDFDocument`.
    @MainActor
    func store(consent: ConsentDocumentExport) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let dateString = formatter.string(from: Date())

        guard !FeatureFlags.disableFirebase else {
            guard let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                await logger.error("Could not create path for writing consent form to user document directory.")
                return
            }
            
            let filePath = basePath.appending(path: "consentForm_\(dateString).pdf")
            await consent.pdf.write(to: filePath)
            
            return
        }
        
        do {
            guard let consentData = await consent.pdf.dataRepresentation() else {
                await logger.error("Could not store consent form.")
                return
            }

            let metadata = StorageMetadata()
            metadata.contentType = "application/pdf"
            _ = try await configuration.userBucketReference
                .child("consent/\(dateString).pdf")
                .putDataAsync(consentData, metadata: metadata) { @Sendable _ in }
        } catch {
            await logger.error("Could not store consent form: \(error)")
        }
    }
}
