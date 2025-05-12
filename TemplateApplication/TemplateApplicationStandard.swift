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
    
    //Treament
    /// - Parameter treatment: The `Treatment` object to be saved.
        func add(treatment: Treatment) async {
            if FeatureFlags.disableFirebase {
                logger.debug("Firebase is disabled. Received treatment: \(treatment.id.uuidString)")
              
                return
            }

            do {
                // Construct the path: users/{userID}/treatments/{treatmentID}
                // The document ID will be the UUID string of the treatment.
                try await configuration.userDocumentReference // This gives you /users/{userID}
                    .collection("treatments")                         // This appends /treatments
                    .document(treatment.id.uuidString)                // This sets the document ID
                    .setData(from: treatment) // Encodes the Treatment object and saves it
                logger.debug("Successfully added/updated treatment: \(treatment.id.uuidString)")
            } catch {
                logger.error("Could not store treatment \(treatment.id.uuidString): \(error.localizedDescription)")
            }
        }

        /// Removes a specific treatment from the user's Firestore collection.
        ///
        /// - Parameter treatmentId: The UUID of the `Treatment` to be removed.
        func removeTreatment(withId treatmentId: UUID) async {
            if FeatureFlags.disableFirebase {
                logger.debug("Firebase is disabled. Received request to remove treatment: \(treatmentId.uuidString)")
                return
            }

            do {
                try await configuration.userDocumentReference
                    .collection("treatments")
                    .document(treatmentId.uuidString)
                    .delete()
                 logger.debug("Successfully removed treatment: \(treatmentId.uuidString)")
            } catch {
                 logger.error("Could not remove treatment \(treatmentId.uuidString): \(error.localizedDescription)")
            }
        }
        
        /// Fetches all treatments for the current user.
        /// - Returns: An array of `Treatment` objects or an empty array if none are found or an error occurs.
        func fetchTreatments() async -> [Treatment] {
            if FeatureFlags.disableFirebase {
                logger.debug("Firebase is disabled. Skipping fetch treatments.")
                return [] // Return empty or potentially mock data for debugging
            }

            do {
                let snapshot = try await configuration.userDocumentReference
                    .collection("treatments")
                    .getDocuments()
                
                // Attempt to decode each document into a Treatment object
                // compactMap will ignore documents that fail to decode
                let treatments = snapshot.documents.compactMap { document -> Treatment? in
                    do {
                        return try document.data(as: Treatment.self)
                    } catch {
                        // Log individual decoding errors if needed
                        logger.error("Failed to decode treatment document \(document.documentID): \(error.localizedDescription)")
                        return nil
                    }
                }
                logger.debug("Successfully fetched \(treatments.count) treatments.")
                return treatments
            } catch {
                logger.error("Could not fetch treatments: \(error.localizedDescription)")
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
