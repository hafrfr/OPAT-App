// OPAT-App/TemplateApplication/Treatments/TreatmentModule.swift
import Spezi
import Foundation
import SwiftUI // Required for AppStorage

final class TreatmentModule: Module, DefaultInitializable, EnvironmentAccessible {
    @Dependency private var model: TreatmentModel
    @Dependency private var scheduler: TreatmentScheduler
     
    // AppStorage to track if initial setup has been performed
    @AppStorage("initialTreatmentsScheduled") private var initialTreatmentsScheduled: Bool = false
    // AppStorage to check if onboarding has been completed

    @MainActor
       func configure() {
           // This configure method is called when the Spezi app sets up modules.
           // We want to create and schedule the defined initial treatments locally ONCE after onboarding is complete.

           // Note: The original code had 'if !initialTreatmentsScheduled'
           // It also needs to check 'completedOnboardingFlow' to ensure it only runs after onboarding.
           if !initialTreatmentsScheduled || model.treatments == [] {
               Task {
                   print("TreatmentModule (Local): scheduled yet. Proceeding with local setup.")
                   
                   let defaultOpatTreatment = Treatment(
                       id: UUID(),
                       type: .opat,
                       timesOfDay: [
                           .init(hour: 8, minute: 0),
                           .init(hour: 14, minute: 0),
                       ],
                       startDate: .now,
                       endDate: Calendar.current.date(byAdding: .day, value: 7, to: .now)
                   )

                   // Add the defined treatment to the in-memory TreatmentModel
                   if !model.treatments.contains(where: { $0.id == defaultOpatTreatment.id }) {
                       model.treatments.append(defaultOpatTreatment)
                       print("TreatmentModule (Local): Added initial OPAT treatment to in-memory TreatmentModel: \(defaultOpatTreatment.id)")
                   } else {
                       print("TreatmentModule (Local): Initial OPAT treatment already found in in-memory TreatmentModel. Skipping add.")
                   }

                   // Persistence to Firebase via 'standard.save(treatment: defaultOpatTreatment)' is REMOVED.

                   // Schedule the tasks for this initial treatment locally
                   do {
                       try scheduler.schedule(defaultOpatTreatment)
                       print("TreatmentModule (Local): Successfully scheduled tasks for initial treatment: \(defaultOpatTreatment.id)")
                       
                       initialTreatmentsScheduled = true
                       print("TreatmentModule (Local): Marked 'initialTreatmentsScheduled' as true.")
                   } catch {
                       print("TreatmentModule (Local): Error scheduling initial treatment \(defaultOpatTreatment.id): \(error). Will attempt again on next configure if conditions met.")
                   }
               }
           } else {
               
               if initialTreatmentsScheduled {
                   print("TreatmentModule (Local): Initial treatments already locally setup and scheduled. Skipping.")
                   // If you had a way to load treatments *locally* (e.g., from UserDefaults or Core Data,
                   // which is not currently implemented), you might do that here.
                   // The `loadTreatmentsFromFirestore()` method is no longer viable in this module.
               }
           }
       }

       // This was a helper in the original code, still useful for local scheduling.
       @MainActor
       private func scheduleInitial(
           treatment: Treatment,
           using scheduler: TreatmentScheduler
       ) async throws {
           try scheduler.schedule(treatment)
       }
       
       // The 'loadTreatmentsFromFirestore()' method is removed as 'standard' is removed.
       // If you need to load treatments, it would have to be from a local source or
       // another module would be responsible for fetching from Firestore and updating TreatmentModel.

       // 'treatmentAdded' now only handles local scheduling if a treatment is added to the model
       // by some other mechanism (e.g. AddTreatmentSheet adding to model.treatments).
       // It will NOT save to Firebase via this module.
       @MainActor
       func treatmentAdded(_ treatment: Treatment) {
           // This method implies that 'treatment' was already added to 'model.treatments' by the caller.
           // Its main job here would be to ensure it's scheduled.
           let capturedScheduler = self.scheduler
           Task {
               do {
                   try capturedScheduler.schedule(treatment)
                   print("TreatmentModule (Local).treatmentAdded: Scheduled treatment: \(treatment.id)")
                   // Persistence to Firebase (await capturedStandard.save(treatment: treatment)) is REMOVED.
               } catch {
                   print("TreatmentModule (Local).treatmentAdded: Error scheduling treatment \(treatment.id): \(error)")
               }
           }
       }

       // 'treatmentRemoved' now only handles local unscheduling.
       // It will NOT delete from Firebase via this module.
       @MainActor
       func treatmentRemoved(_ treatment: Treatment) {
           // This method implies 'treatment' was already removed from 'model.treatments' by the caller.
           // Its main job here is to ensure its scheduled tasks are removed.
           let capturedScheduler = self.scheduler
           Task {
               await capturedScheduler.remove(treatment) // Unschedules local tasks
               print("TreatmentModule (Local).treatmentRemoved: Removed schedules for treatment: \(treatment.id)")
               // Deletion from Firebase (await capturedStandard.delete(treatment: treatment)) is REMOVED.
           }
       }
   }
