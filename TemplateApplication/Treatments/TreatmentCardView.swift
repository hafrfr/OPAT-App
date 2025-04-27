import SwiftUI

// Spezi view killed me
/// A view that displays the details of a single treatment in a standard card-like format.
struct TreatmentCardView: View {
    let treatment: Treatment
    let summary: String // Pre-formatted summary string

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {

            Text(treatment.type.displayName)
                .font(.headline) // Make the type stand out
                .foregroundColor(.primary) // Use primary color for main info
            Text(summary)
                .font(.subheadline)
                .foregroundColor(.secondary) // Keep secondary for less emphasis

        }
        // Add padding *inside* the VStack to space content from row edges
        .padding(.vertical, 8)
    }
}

#if DEBUG
// Preview for the TreatmentCardView itself
#Preview("Treatment Card View Preview (Standard)") {
    // Sample data for the card preview
    let sampleTreatment = Treatment(
        type: .opat,
        timesOfDay: [
            .init(hour: 9, minute: 0),
            .init(hour: 17, minute: 30)
        ],
        startDate: .now,
        endDate: Calendar.current.date(byAdding: .day, value: 14, to: .now)
    )
    let sampleSummary = "2 times per day (9:00 AM, 5:30 PM)" // Example formatted summary

    return List {
         // Use the new name TreatmentCardView
         TreatmentCardView(treatment: sampleTreatment, summary: sampleSummary)

         // Add another card for comparison
         TreatmentCardView(
             treatment: Treatment(type: .painMed, timesOfDay: [.init(hour: 12, minute: 0)], startDate: .now),
             summary: "1 time per day (12:00 PM)"
         )
    }
    // Apply a list style for better preview
    .listStyle(.plain) // or .insetGrouped
}
#endif
