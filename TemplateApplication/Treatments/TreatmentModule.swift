import Spezi
import Foundation
import SpeziNotifications


/// Coordinates scheduling and notifications based on TreatmentModel changes.
final class TreatmentModule: Module, DefaultInitializable {
    // Dependencies injected by Spezi
    @Dependency private var model: TreatmentModel
    @Dependency private var scheduler: TreatmentScheduler
 
    func configure() {
        let initialTreatments = model.treatments
        let capturedScheduler = self.scheduler
        Task { @MainActor in // Run the loop on the MainActor
            for treatment in initialTreatments { // Use captured array
                do {

                    try await self.scheduleInitial(
                        treatment: treatment,
                        using: capturedScheduler) // Pass captured scheduler                    )
                } catch {
                    print("Error during initial scheduling for \(treatment.id): \(error)")
                    // Consider logging this error more formally
                }
            }
        }
    }

    @MainActor
    private func scheduleInitial(
        treatment: Treatment,
        using scheduler: TreatmentScheduler // Accept scheduler instance

    ) async throws {
        // Use the passed-in (captured) instances
        try scheduler.schedule(treatment) // This is @MainActor, safe here
    }

    @MainActor
    func treatmentAdded(_ treatment: Treatment) {
        // --- FIX: Capture dependencies ---
        let capturedScheduler = self.scheduler

        Task {
            do {
                try await self.scheduleInitial(
                    treatment: treatment,
                    using: capturedScheduler
                )
                print("Scheduled new treatment: \(treatment.id)")
            } catch {
                print("Error scheduling added treatment \(treatment.id): \(error)")
            }
        }
    }

    /// Called when a treatment is removed (e.g., from ManageTreatmentsView).
    @MainActor // Ensure this is called on the main actor
    func treatmentRemoved(_ treatment: Treatment) {
        // --- FIX: Capture dependencies ---
        let capturedScheduler = self.scheduler
        // let capturedNotifier = self.notifier // Uncomment if notifier needs removal logic
        // --- End FIX ---

        // Task can run off the main actor
        Task {
            // Use captured scheduler
            // Note: `remove` doesn't throw, it uses try? internally.
            await capturedScheduler.remove(treatment)

            // If notifier needs removal logic:
            // await capturedNotifier.remove(treatment) // Implement if needed

            print("Removed schedules/notifications for treatment: \(treatment.id)")
            // No catch needed as `remove` doesn't throw
        }
    }
}
