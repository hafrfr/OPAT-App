import SwiftUI

struct TreatmentCardView: View {
    let treatment: Treatment
    let summary: String
    var onDelete: () -> Void

    var body: some View {
        HStack { // Use HStack for content + button layout
            // Original content VStack
            VStack(alignment: .leading, spacing: 5) {
                Text(treatment.type.displayName)
                    .font(.headline)
                    .foregroundColor(ColorTheme.title) // Use theme color

                Text(summary)
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.title.opacity(0.8)) //
            }

            Spacer() // Pushes button to the right

            Button(role: .destructive) { // Use destructive role for
                print("Delete tapped for \(treatment.id)")
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red) // Explicit red color
                    .padding(8) // Make tap area slightly larger
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        
        .padding()
        .background(ColorTheme.listItemBackground)
        .cornerRadius(Layout.Radius.medium)
        .shadowStyle(ShadowTheme.card)

    }
}
#if DEBUG
#Preview("Treatment Card View Preview (Standard)") {
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

     List {
         TreatmentCardView(treatment: sampleTreatment, summary: sampleSummary, onDelete: { print("Preview: Delete tapped!") })

         // Add another card for comparison
         TreatmentCardView(
             treatment: Treatment(type: .painMed, timesOfDay: [.init(hour: 12, minute: 0)], startDate: .now),
             summary: "1 time per day (12:00 PM)", onDelete: { print("Preview: Delete tapped!") }
         )
    }
    // Apply a list style for better preview
    .listStyle(.plain) // or .insetGrouped
}
#endif
