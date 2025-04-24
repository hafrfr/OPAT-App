import Spezi
import SpeziNotifications      // make sure this is imported
import UserNotifications

final class TreatmentNotifications: Module, DefaultInitializable {
  @Dependency private var notifications: Notifications

  /// Schedules each treatment slot + a “30-min-before” reminder.
  func scheduleWithPreReminder(
    treatment: Treatment,
    reminderMinutesBefore: Int = 30,
    endDate: Date? = nil
  ) async throws {
    //let prefix = "treatment-\(treatment.id.uuidString)"
    //  Schedule the main + pre-reminders
    for (idx, time) in treatment.timesOfDay.enumerated() {
      // main alarm
      try await scheduleOne(
        treatment: treatment,
        at: time,
        identifierSuffix: "\(idx)",
        titleSuffix: "",
        repeatsForever: endDate == nil
      )

      // 30-min reminder
      if let early = time.subtracting(minutes: reminderMinutesBefore) {
        try await scheduleOne(
          treatment: treatment,
          at: early,
          identifierSuffix: "\(idx)-reminder",
          titleSuffix: " Take Medication out of Freezer ",
          repeatsForever: endDate == nil
        )
      }
    }
  }

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

    try await notifications.add(request: request)
  }
}
