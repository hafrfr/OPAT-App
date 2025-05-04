import Spezi
import Foundation
import Observation
@Observable
final class TreatmentModel: Module,
                            DefaultInitializable,
                            EnvironmentAccessible,
                            ObservableObject{
    var treatments: [Treatment] = []
    init() {}
    func configure() {
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
