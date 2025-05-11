// OPAT-App/TemplateApplication/Treatments/TreatmentModel.swift
import Spezi
import Foundation
import Observation

@Observable
final class TreatmentModel: Module,
                            DefaultInitializable,
                            EnvironmentAccessible,
                            ObservableObject{
        
    var treatments: [Treatment] = [] // Starts empty
    
    init() {}

    func configure() {
        print("TreatmentModel configured. Initial treatments count: \(treatments.count)")
    }
}
