import Observation
import Spezi
import SpeziScheduler
import Foundation

@Observable
final class TreatmentScheduler: Module,
                                DefaultInitializable,
                                EnvironmentAccessible,
                                ObservableObject{
  @Dependency(Scheduler.self) @ObservationIgnored
  private var scheduler: Scheduler
  init() {}

    @MainActor
    func schedule(_ treatment: Treatment) throws {
        for (idx, time) in treatment.timesOfDay.enumerated() {
            guard let hour = time.hour, let minute = time.minute else { continue }
            let id = "treatment-\(treatment.id.uuidString)-\(idx)"

            try scheduler.createOrUpdateTask(
                id: id,
                title: "Treatment: \(treatment.type.displayName)",
                instructions: "Time for your \(treatment.type.displayName)",
                category: .medication,
                schedule: .daily(hour: hour, minute: minute, startingAt: treatment.startDate),
                scheduleNotifications:  true
            ) { context in
                context.treatmentId = treatment.id
            }

            // Pre-treatment reminder 30 min beforehand
            if let reminder = time.subtracting(minutes: 30),
               let rhour = reminder.hour,
               let rmin = reminder.minute {
                let preId = "\(id)-pre-task"
                try scheduler.createOrUpdateTask(
                    id: preId,
                    title: "Pre-treatment task: \(treatment.type.displayName)",
                    instructions: "Time to take your \(treatment.type.displayName) out of the Fridge",
                    category: .medication,
                    schedule: .daily(hour: rhour, minute: rmin, startingAt: treatment.startDate),
                    scheduleNotifications:  true
                ) { context in
                    context.treatmentId = treatment.id
                }
            }
        }
    }

    func remove(_ treatment: Treatment) async {
        for idx in treatment.timesOfDay.indices {
            let id = "treatment-\(treatment.id.uuidString)-\(idx)"
            try? await scheduler.deleteAllVersions(ofTask: id)

            let preId = "\(id)-pre-task"
            try? await scheduler.deleteAllVersions(ofTask: preId)
        }
    }
}
