//
//  TreatmentScheduler.swift
//  TemplateApplication
//
//  Created by Jacob Justad on 2025-04-23.
//

import Spezi
import SpeziScheduler

/// Purely handles scheduling/removing the Spezi background tasks.
final class TreatmentScheduler: Module, DefaultInitializable {
  @Dependency private var scheduler: Scheduler
    @MainActor func schedule(_ treatment: Treatment) throws {
    // add new for each time:
    for (idx, time) in treatment.timesOfDay.enumerated() {
      guard let hour = time.hour, let min = time.minute else { continue }
      let id = "treatment-\(treatment.id.uuidString)-\(idx)"
      try scheduler.createOrUpdateTask(
        id: id,
        title: "Treatment: \(treatment.type.displayName)",
        instructions: "Time for your \(treatment.type.displayName)",
        category: .medication,
        schedule: .daily(hour: hour, minute: min, startingAt: treatment.startDate)
      ) { context in
        context.treatmentId = treatment.id
      }
    }
  }

  func remove(_ treatment: Treatment) async {
    for idx in treatment.timesOfDay.indices {
      let id = "treatment-\(treatment.id.uuidString)-\(idx)"
      try? await scheduler.deleteAllVersions(ofTask: id)
    }
  }
}
