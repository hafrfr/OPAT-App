import Foundation
import SwiftUI 

// Enum to categorize treatments, helps link to specific instructions later
enum TreatmentType: String, Codable, CaseIterable, Identifiable {
    case opat = "OPAT Antibiotics" // Example specific type
    case painMed = "Pain Medication"
    case other = "Other"
    
    var id: String { self.rawValue }
    var displayName: String {
        switch self {
        case .opat: return "Intravenous Antibiotics"
        case .painMed: return "Pain medication"
        case .other: return "Other"
        }
    }
}
/// A scheduled treatment session.
struct Treatment: Identifiable, Codable, Equatable {
    let id: UUID
    var type: TreatmentType
    var timesOfDay: [DateComponents]
    var startDate: Date
    var endDate: Date?
    init(
      id: UUID = .init(),
      type: TreatmentType,
      timesOfDay: [DateComponents],
      startDate: Date = .today,
      endDate: Date? = nil
    ) {
      self.id = id
      self.type = type
      self.timesOfDay = timesOfDay
      self.startDate = startDate
      self.endDate = endDate
    }
}
