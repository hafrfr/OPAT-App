// TemplateApplication/UI/Schedule/TreatmentProgressCalenderView.swift
import SwiftUI
import SpeziScheduler
import SpeziSchedulerUI
// Remove SpeziScheduler import if not needed elsewhere in this file

struct TreatmentProgressCalendarView: View {
    // Environment objects
    @Environment(TreatmentModel.self) private var treatmentModel
    @Environment(TemplateApplicationScheduler.self) private var appScheduler: TemplateApplicationScheduler
    @Environment(TreatmentScheduler.self) private var treatmentScheduler
    // State variables for calculated progress and dates
    @State private var totalTreatmentDays: Int = 0
    @State private var daysCompleted: Int = 0
    @State private var overallDateRange: (start: Date, end: Date)? = nil
    // State variable for the set of ALL dates within the treatment range
    @State private var treatmentDatesList: [DateComponents] = []
    @State private var selectedDay: Date? = Calendar.current.startOfDay(for: Date())

    // Calendar instance
    private let calendar = Calendar.current

    // MARK: - Body
    var body: some View {
        //ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // --- Progress Section ---
                    if overallDateRange != nil && totalTreatmentDays > 0 {
                        progressSection.padding()
                        Divider()
                    }

                    // --- Calendar Section ---
                    calendarSection


                    if var day = selectedDay {
                            EventScheduleList(date: day) { event in
                               InstructionsTile(event)
                                 .id(event.id)
                            }
                        .padding(.horizontal) // Add padding to the Section

                    } else {
                        // Optional: View when no date is selected
                        Section("Events") {
                             Text("Tap on a date in the calendar to view events.")
                                .foregroundColor(.secondary)
                                .padding(.vertical)
                        }
                        .padding(.horizontal)
                    }

                }
                .padding(.vertical)
                .onAppear { // Keep existing onAppear logic
                    calculateProgressAndDates()
                    
                }
                .onChange(of: treatmentModel.treatments) {
                    calculateProgressAndDates()
                }
                .navigationTitle("Care Plan")
                .navigationBarTitleDisplayMode(.inline)
            }


    // MARK: - Calculation Functions

    // Function to find the min start date and max end date across all treatments
    // (Keep this function as it was)
     func calculateOverallDateRange(for treatments: [Treatment]) -> (start: Date, end: Date)? {
         guard !treatments.isEmpty else { return nil }
         let validTreatments = treatments
         guard !validTreatments.isEmpty else { return nil }
          let latestDatesPerTreatment = validTreatments.compactMap { treatment -> Date? in
              if let endDate = treatment.endDate {
                  return endDate >= treatment.startDate ? endDate : treatment.startDate
              } else {
                  return treatment.startDate
              }
          }
          guard let earliestStartDate = validTreatments.map({ $0.startDate }).min(),
                let latestOverallEndDate = latestDatesPerTreatment.max() else {
              return nil
          }
          guard latestOverallEndDate >= earliestStartDate else {
              print("Warning: Calculated latest end date is before earliest start date. Returning nil.")
              return nil
          }
          return (start: earliestStartDate, end: latestOverallEndDate)
     }

    // Function called on appear and when treatments change
    // Calculates progress AND the set of all dates in the range
    private func calculateProgressAndDates() {
        print("Attempting to calculate progress and dates...")
        guard let range = calculateOverallDateRange(for: treatmentModel.treatments) else {
            self.treatmentDatesList = []
                       print("Calculation skipped: No treatments or invalid range.")
                       return
                   }
        self.overallDateRange = range
        let startDay = calendar.startOfDay(for: range.start)
        let endDay = calendar.startOfDay(for: range.end)
        let today = calendar.startOfDay(for: Date())

        guard endDay >= startDay else { return } // Basic validation

        // Calculate Total Days & Completed Days (remains the same)
        let totalDaysDifference = calendar.dateComponents([.day], from: startDay, to: endDay).day ?? 0
        self.totalTreatmentDays = max(0, totalDaysDifference + 1)
        let completedDifference = calendar.dateComponents([.day], from: startDay, to: today).day ?? -1
        self.daysCompleted = max(0, min(completedDifference + 1, self.totalTreatmentDays))

        // --- CHANGE 3: Calculate List of ALL Dates in Range ---
        var dateList: [DateComponents] = [] // Create a local list
        var currentDate = startDay
        let components: Set<Calendar.Component> = [.year, .month, .day]
        var loopCount = 0
        while currentDate <= endDay && loopCount < 1000 {
            // Append components to the list
            dateList.append(calendar.dateComponents(components, from: currentDate))
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
             if nextDay <= currentDate { print("Date calculation error in loop"); break }
            currentDate = nextDay
            loopCount += 1
        }
         if loopCount >= 1000 { print("Warning: Date list calculation loop limit reached.")}

        self.treatmentDatesList = dateList
        // print(self.treatmentDatesList) // Keep for debugging if needed

        print("--- Calculated Progress & Dates ---")
        print("Overall Range: \(startDay) to \(endDay)")
        print("Total Treatment Days: \(self.totalTreatmentDays)")
        print("Days Completed: \(self.daysCompleted)")
        print("Treatment Dates List Count: \(self.treatmentDatesList.count)") // Verify count
    }

    // MARK: - Subviews
    

    // Progress calculation for the bar
    private var progress: Double {
        guard totalTreatmentDays > 0 else { return 0.0 }
        return min(1.0, max(0.0, Double(daysCompleted) / Double(totalTreatmentDays)))
    }

    // progressSection uses the calculated state variables
    private var progressSection: some View {
         VStack(alignment: .leading, spacing: 8) {
             Text("Overall Treatment Progress").font(.title2).fontWeight(.semibold)
             ProgressView(value: progress) {
                 Text("Day \(daysCompleted) of \(totalTreatmentDays)").font(.caption)
             } currentValueLabel: {
                 Text("\(Int((progress * 100).rounded()))%").font(.caption)
             }
             .progressViewStyle(.linear)
             let daysLeft = max(0, totalTreatmentDays - daysCompleted)
             Text("\(daysLeft) days remaining")
                 .font(.subheadline).foregroundColor(.secondary)
         }
         .padding(.horizontal)
     }

    // calendarSection passes the calculated treatmentDatesSet
    private var calendarSection: some View {
            VStack {
                CalendarViewRepresentable(treatmentDates: treatmentDatesList, selectedDate: $selectedDay)
                    .frame(height: 350)
            }
        }
    
    
    }
// MARK: - Preview
#Preview {
    // --- Create Sample Data (Necessary for this preview) ---
    let calendar = Calendar.current
    let today = Date()
    // Example: Treatment started 5 days ago, ends in 10 days
    let startDate = calendar.date(byAdding: .day, value: -5, to: today)!
    let endDate = calendar.date(byAdding: .day, value: 10, to: today)!

    let configuredTreatmentModel = TreatmentModel() // Create instance
    configuredTreatmentModel.treatments = [ // Configure with sample data
        Treatment(type: .opat,
                  timesOfDay: [
            .init(hour: 8, minute: 0),
            .init(hour: 14, minute: 0),
                  ], startDate: startDate, endDate: endDate)
    ]
    
    

    return NavigationView { // Use NavigationView if appropriate
        TreatmentProgressCalendarView()
            .environment(configuredTreatmentModel)
            .previewWith(standard: TemplateApplicationStandard()) {
                TemplateApplicationScheduler()
                TreatmentScheduler()
                Scheduler() // The actual scheduler module
                TemplateApplicationScheduler() // Your app-specific scheduler logic
            }
    }
}

 
