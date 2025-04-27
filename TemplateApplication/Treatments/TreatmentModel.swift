import Spezi
import Foundation
import Observation // Keep Observation for @Observable


@Observable // Use the @Observable macro for the class
final class TreatmentModel: Module,
                            DefaultInitializable,
                            EnvironmentAccessible,
                            ObservableObject{

    // Remove @Published - @Observable handles observation for this property
    var treatments: [Treatment] = []

    init() {}

    func configure() {
        // load from disk or start with samples…
        treatments = [
            Treatment(
                type: .opat,
                timesOfDay: [
                    .init(hour: 8, minute: 0),
                    .init(hour: 14, minute: 0),
                ],
                startDate: .now,
                endDate: Calendar.current.date(byAdding: .day, value: 7, to: .now)
            )
        ]
        print("TreatmentModel configured. Treatments count: \(treatments.count)")
    }
}
