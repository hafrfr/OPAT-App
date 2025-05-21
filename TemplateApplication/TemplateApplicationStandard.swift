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
                                   HealthKitConstraint,
                                   EnvironmentAccessible,
                                   ConsentConstraint,
                                   AccountNotifyConstraint {

    @Application(\.logger) private var logger

    @Dependency(FirebaseConfiguration.self) private var configuration

    init() {}


    func handleNewSamples<Sample>(
            _ addedSamples: some Collection<Sample>,
            ofType sampleType: SampleType<Sample> // You get the specific SampleType here
        ) async {
            if FeatureFlags.disableFirebase {
                logger.debug("Received new HealthKit samples of type \(sampleType.hkSampleType). Count: \(addedSamples.count)")
                for sample in addedSamples {
                    if let hkSample = sample as? HKSample { // Cast to HKSample to access common properties
                        logger.debug("  - Sample ID: \(hkSample.uuid)")
                    }
                }
                return
            }

            for individualSample in addedSamples {
                // Important: The `individualSample` here is of the generic type `Sample`.
                // To use it with your existing Firestore logic that expects HKSample,
                // you'll need to cast or ensure it is an HKSample.
                // The SpeziHealthKit framework ensures that `Sample` will be a subtype of `HKSample`.
                guard let hkSample = individualSample as? HKSample else {
                    logger.warning("Could not cast added sample to HKSample. Sample: \(individualSample)")
                    continue
                }

                do {
                    // Use your existing healthKitDocument logic
                    try await healthKitDocument(id: hkSample.uuid)
                        .setData(from: hkSample.resource) // Assuming .resource gives you the FHIR representation
                    logger.debug("Successfully stored new sample \(hkSample.uuid) of type \(sampleType.hkSampleType)")
                } catch {
                    logger.error("Could not store HealthKit sample \(hkSample.uuid): \(error)")
                }
            }
        }

        func handleDeletedObjects<Sample>(
            _ deletedObjects: some Collection<HKDeletedObject>,
            ofType sampleType: SampleType<Sample> // You get the specific SampleType here
        ) async {
            if FeatureFlags.disableFirebase {
                logger.debug("Received deleted HealthKit objects of type \(sampleType.hkSampleType). Count: \(deletedObjects.count)")
                for deletedObject in deletedObjects {
                    logger.debug("  - Deleted Object ID: \(deletedObject.uuid)")
                }
                return
            }

            for deletedObject in deletedObjects {
                do {

                    try await healthKitDocument(id: deletedObject.uuid).delete()
                    logger.debug("Successfully deleted object \(deletedObject.uuid) of type \(sampleType.hkSampleType)")
                } catch {
                    logger.error("Could not remove HealthKit object \(deletedObject.uuid): \(error)")
                }
            }
        }

    
    func logCompletedEvent(_ eventLog: EventLog) async {
            // 1. Handle Firebase Disabled Case
            if FeatureFlags.disableFirebase {
                // Log locally using the injected logger
                await logger.debug("""
                    Firebase disabled. Logging event locally:
                    EventID: \(eventLog.eventID, privacy: .public)
                    TaskID: \(eventLog.taskID, privacy: .public)
                    Scheduled: \(eventLog.scheduledTimestamp.description, privacy: .public)
                    Completed: \(eventLog.completionTimestamp.description, privacy: .public)
                """)
                // If you needed actual local *storage* (e.g., to upload later),
                // you would implement that logic here (e.g., save to UserDefaults, CoreData, file).
                return // Don't proceed to Firestore logic
            }

            // 2. Get Firestore User Reference
            guard let userReference = try? await configuration.userDocumentReference else {
                // Log error if we can't get the user reference (e.g., user not signed in properly)
                await logger.error("Could not log event: User document reference not available. EventID: \(eventLog.eventID)")
                return // Cannot save without user reference
            }
            let userID = userReference.documentID

            // 3. Prepare the log entry with the User ID
            var logToSave = eventLog
            logToSave.userID = userID

            // 4. Attempt to save to Firestore
            do {
                try await userReference
                    .collection("event_logs") // Target collection under the user document
                    .document(logToSave.id.uuidString) // Use the EventLog's own UUID as the document ID
                    .setData(from: logToSave) // Encode and save the EventLog object

                // Log success
                await logger.info("""
                    Successfully logged completed SpeziScheduler Event to Firestore:
                    LogEntryID: \(logToSave.id.uuidString, privacy: .public)
                    EventID: \(logToSave.eventID, privacy: .public)
                    UserID: \(userID, privacy: .private) 
                    TaskID: \(logToSave.taskID, privacy: .public)
                """)
            } catch {
                // Log Firestore errors
                await logger.error("""
                    Could not log completed SpeziScheduler Event \(logToSave.eventID) to Firestore for user \(userID, privacy: .private): 
                    Error: \(error.localizedDescription, privacy: .public)
                """)
                // Consider adding retry logic or caching failed logs locally here if needed.
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
    
        func triggerManualExport() async throws {
            // Implement your manual data export logic if needed.
            // If you don't have specific requirements for manual export via this route,
            // you can leave it empty or log that it was called.
            logger.info("triggerManualExport() called on TemplateApplicationStandard.")
            // If the function is expected to perform an action that can fail,
            // you might need to actually throw an error or handle it appropriately.
            // For now, a simple implementation will satisfy the protocol conformance.
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
    
    
    func storeHealthKitSnapshot(_ snapshot: HealthKitSnapshot, forResponseId responseIdString: String) async {
            if FeatureFlags.disableFirebase {
                logger.debug("Firebase is disabled. Skipping HealthKit snapshot storage.")
                return
            }
        guard let userReference = try? await configuration.userDocumentReference else {
                logger.error("Could not store HealthKit snapshot as the user is not signed in.")
                return
            }

            do {
                // Store the snapshot in a new collection, using the questionnaireResponseId as the document ID.
                try await userReference
                    .collection("healthKitSnapshots") // New collection for snapshots
                    .document(responseIdString)       // Document ID is the QuestionnaireResponse ID
                    .setData(from: snapshot)
                logger.info("HealthKitSnapshot for response \(responseIdString) stored successfully.")
            } catch {
                logger.error("Could not store HealthKitSnapshot for response \(responseIdString): \(error)")
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
