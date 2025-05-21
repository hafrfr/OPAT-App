//
// This source file is part of the OPAT-App open-source project
// (The header should be updated according to your project's standards)
//
// SPDX-FileCopyrightText: 2023 Stanford University (or your name/entity)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import Foundation
import SwiftUI // Required for AppStorage

/// Manages the scheduling, persistence (via Standard), and local state of `Treatment` objects.
///
/// This module coordinates fetching treatments from Firestore, provisioning default treatments
/// on first launch (post-onboarding), updating the local `TreatmentModel`, and
/// scheduling/unscheduling local notifications via the `TreatmentScheduler`.
final class TreatmentModule: Module, DefaultInitializable, EnvironmentAccessible {
    // MARK: Dependencies & Properties
    
    /// Access to the Spezi Standard for interacting with shared application logic and persistence (e.g., Firebase).
    @StandardActor private var standard: TemplateApplicationStandard
    
    /// Dependency on the observable model holding the array of current treatments for the UI.
    @Dependency private var model: TreatmentModel
    
    /// Dependency on the scheduler responsible for handling local notifications for treatments.
    @Dependency private var scheduler: TreatmentScheduler
    
    /// AppStorage flag to track if default treatments have been provisioned to Firestore ONCE.
    /// Prevents re-creation of defaults if the user clears all their treatments later.
    @AppStorage("defaultTreatmentsProvisionedToFirestore") private var defaultTreatmentsProvisionedToFirestore: Bool = false
    
    /// AppStorage flag to indicate if the `configure` logic has run and attempted initial sync/scheduling
    /// in the current app session. Can be useful for debugging or UI state.
    @AppStorage("initialTreatmentsConfiguredThisSession") private var initialTreatmentsConfiguredThisSession: Bool = false

    // Optional: Flag to gate configuration until onboarding is complete.
    // @AppStorage("completedOnboardingFlow") private var completedOnboardingFlow: Bool = false

    /// Default initializer required by `DefaultInitializable`.
    public init() {}
    
    // MARK: - Spezi Module Configuration
    
    /// Called by Spezi during the application setup phase.
    /// Kicks off the asynchronous process to configure treatments.
    @MainActor
    func configure() {
        // Optional: Check if onboarding must be completed first.
        // guard completedOnboardingFlow else {
        //     print("TreatmentModule: Onboarding not completed. Skipping treatment configuration.")
        //     return
        // }

        print("TreatmentModule: Configuring treatments...")
        // Launch the asynchronous configuration task.
        Task {
            await performTreatmentConfiguration()
        }
    }

    // MARK: - Asynchronous Configuration Logic (Called from configure)

    /// Performs the main asynchronous steps for treatment configuration:
    /// Clears local state, fetches from Firestore, provisions defaults if needed,
    /// updates the local model, and schedules local notifications.
    @MainActor
    private func performTreatmentConfiguration() async {
        initialTreatmentsConfiguredThisSession = false
        await clearLocalTreatmentState()

        // 2. Fetch current treatments from Firestore (via Standard).

        let fetchedTreatments = await standard.fetchTreatments()
        print(fetchedTreatments)
        print("fetchedTreatments.count: \(fetchedTreatments.count)")
        var treatmentsToProcessLocally: [Treatment] = []

        if fetchedTreatments.isEmpty {
            treatmentsToProcessLocally = await handleEmptyFirestore()
        } else {
            treatmentsToProcessLocally = handleFetchedTreatments(fetchedTreatments)
        }
        
        // 4. Schedule all treatments that are now in the local model.
        await scheduleTreatmentsLocally(treatmentsToProcessLocally)
        
        // 5. Mark configuration as complete for this session.
        initialTreatmentsConfiguredThisSession = true
        print("TreatmentModule: Configuration and initial sync complete for this session.")
    }

    // MARK: - Configuration Helper Functions

    /// Clears the local `TreatmentModel` and unschedules associated tasks via the `TreatmentScheduler`.
    @MainActor
    private func clearLocalTreatmentState() async {
        guard !model.treatments.isEmpty else { return } // Nothing to clear

        print("TreatmentModule: Clearing \(model.treatments.count) existing local treatments and unscheduling them before sync.")
        
        // Create a copy to iterate over while modifying the original array safely
        let treatmentsToRemove = model.treatments
        model.treatments.removeAll() // Clear the model

        for treatment in treatmentsToRemove {
                     await self.scheduler.remove(treatment)
                }
        print("TreatmentModule: Local treatment state cleared.")
    }

    /// Handles the scenario where Firestore contains no treatments.
    /// If defaults haven't been provisioned yet, it creates, saves, and returns the default treatment.
    /// - Returns: An array containing the default treatment if created, otherwise empty.
    @MainActor
    private func handleEmptyFirestore() async -> [Treatment] {
        guard !defaultTreatmentsProvisionedToFirestore else {
            // Defaults were already created in the past, or the user intentionally has no treatments.
            print("TreatmentModule: No treatments in Firestore, and defaults were already provisioned (or user cleared all data).")
            return [] // No new treatments to schedule
        }

        // Defaults need to be provisioned for the first time.
        print("TreatmentModule: No treatments in Firestore and defaults not provisioned. Creating default OPAT treatment.")
        let defaultOpatTreatment = Treatment(
            id: UUID(), // Generate a unique ID
            type: .opat,
            timesOfDay: [
                .init(hour: 10, minute: 0),
                .init(hour: 14, minute: 0)
            ],
            startDate: .now, // Start today
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: .now) // Example: 1 week duration
        )
        
        // Persist to Firestore via the Standard
        await standard.add(treatment: defaultOpatTreatment)
        // Add to the local model
        model.treatments.append(defaultOpatTreatment)
        // Mark defaults as provisioned so this doesn't run again
        defaultTreatmentsProvisionedToFirestore = true
        
        print("TreatmentModule: Default OPAT treatment created, saved to Firestore (ID: \(defaultOpatTreatment.id)), added locally. Marked as provisioned.")
        // Return the newly created treatment so it can be scheduled
        return [defaultOpatTreatment]
    }

    /// Handles the scenario where treatments were successfully fetched from Firestore.
    /// Adds the fetched treatments to the local `TreatmentModel`.
    /// - Parameter fetchedTreatments: The treatments retrieved from Firestore.
    /// - Returns: The fetched treatments, ready to be scheduled locally.
    @MainActor
    private func handleFetchedTreatments(_ fetchedTreatments: [Treatment]) -> [Treatment] {
         print("TreatmentModule: Found \(fetchedTreatments.count) treatments in Firestore. Adding to local model.")
         // Add fetched treatments to the (now empty) local model
         model.treatments.append(contentsOf: fetchedTreatments)
         return fetchedTreatments // Return these treatments for scheduling
    }

    /// Schedules the provided list of treatments using the `TreatmentScheduler`.
    /// Handles errors gracefully, logging them but continuing with other treatments.
    /// - Parameter treatments: The treatments to schedule locally.
    @MainActor
    private func scheduleTreatmentsLocally(_ treatments: [Treatment]) async {
        guard !treatments.isEmpty else {
             print("TreatmentModule: No treatments to schedule locally.")
             return
        }

        print("TreatmentModule: Scheduling \(treatments.count) treatments locally.")
        for treatment in treatments {
            do {
                // Ask the scheduler to set up local notifications for this treatment
                try scheduler.schedule(treatment)
                print("TreatmentModule: Successfully scheduled treatment: \(treatment.id)")
            } catch {
                // Log error but continue trying to schedule others
                print("TreatmentModule: Error scheduling treatment \(treatment.id): \(error)")
            }
        }
    }

    // MARK: - Public Methods for UI Interaction

    /// Handles the addition (or update) of a treatment, triggered by UI actions.
    /// Ensures the treatment is saved to Firestore, updated in the local model, and scheduled locally.
    /// - Parameter treatment: The `Treatment` object to add or update.
    
    @MainActor
    // Make the function async and throw errors
    func treatmentAdded(_ treatment: Treatment) async throws {
        print("TreatmentModule.treatmentAdded: Processing add/update for treatment \(treatment.id).")
        
        // Store the index in case it's an update, for potential rollback or final update
        let existingIndex = model.treatments.firstIndex(where: { $0.id == treatment.id })

        // --- Perform potentially failing operations FIRST ---
        do {
            // 1. Save/Update in Firestore via the Standard (await directly)

            await standard.add(treatment: treatment)
            print("TreatmentModule.treatmentAdded: Saved/Updated treatment \(treatment.id) in Firestore.")
            
            // 2. Schedule/Re-schedule local notifications (try directly)
            // This can throw an error if scheduling fails.
            try scheduler.schedule(treatment)
            print("TreatmentModule.treatmentAdded: Scheduled/Re-scheduled treatment: \(treatment.id)")

            // --- If BOTH Firestore save and local scheduling succeeded, THEN update the local model ---
            if let index = existingIndex {
                // It was an update, update the item in the array
                model.treatments[index] = treatment
                print("TreatmentModule.treatmentAdded: Updated treatment \(treatment.id) in local model.")
            } else {
                // It was a new item, append it
                model.treatments.append(treatment)
                print("TreatmentModule.treatmentAdded: Added new treatment \(treatment.id) to local model.")
            }
            
        } catch {
            // If Firestore save OR local scheduling failed:
            print("TreatmentModule.treatmentAdded: Error during Firestore save or local schedule for \(treatment.id): \(error). Local model NOT updated.")
            // Do NOT update the local model if there was an error.
            // Rethrow the error so the calling View knows about the failure.
            throw error
        }
    }

    /// Handles the removal of a treatment, triggered by UI actions.
    /// Ensures the treatment is deleted from Firestore, removed from the local model, and unscheduled locally.
    /// - Parameter treatment: The `Treatment` object to remove.
    // In: TreatmentModule.swift

    @MainActor
    func treatmentRemoved(_ treatment: Treatment) async {
        print("TreatmentModule.treatmentRemoved: Processing removal for treatment \(treatment.id).")
        
        let treatmentID = treatment.id

        // 1. Remove from local model FIRST
        let initialCount = model.treatments.count
        model.treatments.removeAll(where: { $0.id == treatmentID })
        // ... (logging about model removal) ...

        print("TreatmentModule.treatmentRemoved: Initiating Firestore delete and local unscheduling for \(treatmentID)...")
        
        // Call Firestore delete first
        await standard.removeTreatment(withId: treatmentID)
        print("TreatmentModule.treatmentRemoved: Completed Firestore deletion for \(treatmentID).")
        
        // Then call scheduler remove
        await scheduler.remove(treatment) // Ensure scheduler.remove is @MainActor
        print("TreatmentModule.treatmentRemoved: Completed local unscheduling for \(treatmentID).")

        print("TreatmentModule.treatmentRemoved: Completed sequential cleanup attempts for \(treatmentID).")
    }
   
}
