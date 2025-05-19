import SwiftUI
import SpeziScheduler

struct EventSummaryView: View {
    // Query events internally WITHOUT sorting during initialization
    @EventQuery private var events: [Event]

    private let date: Date
    private let title: String // Pass title for the section

    // Formatter for time display (keep as before)
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short // e.g., "7:30 PM" or "19:30" depending on locale
        return formatter
    }()

    // Initialize the view and its internal EventQuery (without sort)
    init(date: Date, title: String = "Events") {
        self.date = date
        self.title = title
        // Initialize the @EventQuery with ONLY the range
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
             _events = EventQuery(in: startOfDay..<startOfDay) // Fallback empty range
             print("Error: Could not calculate end of day for \(startOfDay). Summary view might show no events.")
             return
        }
        // Initialize WITHOUT the sort parameter
        _events = EventQuery(in: startOfDay..<endOfDay)
    }

    // Computed property to sort the events fetched by the query
    private var sortedEvents: [Event] {
        events.sorted { $0.occurrence.start < $1.occurrence.start }
    }

    var body: some View {
        Section(title) { // Use the passed title
            // Use the computed sortedEvents property here
            if sortedEvents.isEmpty {
                Text("No events scheduled for this day.")
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else {
                VStack(alignment: .leading) {
                    ForEach(sortedEvents) { event in
                        HStack(spacing: 8) {
                            // Completion Status Icon
                            Image(systemName: event.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(event.isCompleted ? .green : .gray)
                                .frame(width: 20) // Align icons

                            // Event Time
                            Text(event.occurrence.start, formatter: Self.timeFormatter)
                                .font(.subheadline.monospacedDigit()) // Monospaced for alignment
                                .frame(width: 70, alignment: .leading) // Allocate space for time

                            // Event Title
                            Text(event.task.title)
                                .font(.subheadline)
                                .strikethrough(event.isCompleted, color: .gray) // Add strikethrough if completed
                                .opacity(event.isCompleted ? 0.7 : 1.0) // Slightly dim completed tasks

                            Spacer() // Pushes content to the left
                        }
                        .padding(.bottom, 3) // Reduced padding between items
                    }
                }
                .padding(.vertical)
            }
        }
    }
}
