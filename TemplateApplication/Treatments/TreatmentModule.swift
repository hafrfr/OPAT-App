import Spezi
import Foundation
import Combine
/// Wire everything together: whenever treatments change, re-schedule tasks & notifications.
final class TreatmentModule: Module, DefaultInitializable {
  @Dependency private var model: TreatmentModel
  @Dependency private var scheduler: TreatmentScheduler
  @Dependency private var notifier: TreatmentNotifications

  func configure() {
    // initial pass
    for treatment in model.treatments {
      try? scheduler.schedule(treatment)
      Task { [weak self] in // Add weak self capture for the Task
         try? await self?.notifier.scheduleWithPreReminder(treatment: treatment)
      }
    }
    model.$treatments
      .sink { [weak self] treatments in
        guard let self else { return }
        for treatment in treatments {
           try? self.scheduler.schedule(treatment)
           Task { [weak self] in
              try? await self?.notifier.scheduleWithPreReminder(treatment: treatment)
           }
        }
      }
      .store(in: &cancellables)
  }

  private var cancellables = Set<AnyCancellable>()
}
