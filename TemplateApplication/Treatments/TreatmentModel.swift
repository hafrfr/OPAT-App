import Combine // Needed for @Published
import Foundation
import Spezi


final class TreatmentModel: Module, DefaultInitializable, ObservableObject { // Add ObservableObject conformance for @Published
  @Published var treatments: [Treatment] = []
  // Required initializer for DefaultInitializable
  required init() {}

  func configure() {
    // load from disk or start with samples…
    treatments = [
      Treatment(
        type: .opat,
        timesOfDay: [
          .init(hour: 8, minute: 0),
          .init(hour: 14, minute: 0),
          .init(hour: 20, minute: 0)
        ],
        startDate: .now,
        endDate: Calendar.current.date(byAdding: .day, value: 7, to: .now)
      )
    ]
    print("TreatmentModel configured. Treatments count: \(treatments.count)")
  }
}
