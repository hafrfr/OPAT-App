import Observation
import Spezi
import SpeziNotifications
import UserNotifications
import Foundation

@Observable
final class TreatmentNotifications: Module,
                                    DefaultInitializable,
                                    ObservableObject{

    @Dependency(Notifications.self) @ObservationIgnored
    private var notifications: Notifications
    
    init() {}

    @MainActor
    func scheduleWithPreReminder(
        treatment: Treatment,
        reminderMinutesBefore: Int = 30,
        endDate: Date? = nil
    ) async throws {
        // (Keep the rest of the function body the same)
        //let prefix = "treatment-\(treatment.id.uuidString)"
        // Schedule the main + pre-reminders
        for (idx, time) in treatment.timesOfDay.enumerated() {
            // main alarm
            try await scheduleOne( // Make sure scheduleOne is also MainActor or called correctly
                treatment: treatment,
                at: time,
                identifierSuffix: "\(idx)",
                titleSuffix: "",
                repeatsForever: endDate == nil
            )

            // 30-min reminder
            if let early = time.subtracting(minutes: reminderMinutesBefore) {
                try await scheduleOne( // Make sure scheduleOne is also MainActor or called correctly
                    treatment: treatment,
                    at: early,
                    identifierSuffix: "\(idx)-reminder",
                    titleSuffix: " Take Medication out of Freezer ",
                    repeatsForever: endDate == nil
                )
            }
        }
    }

    // --- ALSO FIX: Add @MainActor here ---
    // If scheduleOne is called from a @MainActor func, it should also be on MainActor
    // or handle its concurrency appropriately (e.g., if notifications.add needs main actor)
    @MainActor
    private func scheduleOne(
        treatment: Treatment,
        at time: DateComponents,
        identifierSuffix: String,
        titleSuffix: String = "",
        repeatsForever: Bool
    ) async throws {
        let id = "treatment-\(treatment.id.uuidString)-\(identifierSuffix)"
        let content = UNMutableNotificationContent()
        content.title = treatment.type.displayName + titleSuffix
        content.body  = "Time for your \(treatment.type.displayName) treatment."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: time,
            repeats: repeatsForever
        )

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        // This call likely requires the Main Actor
        try await notifications.add(request: request)
    }
}
