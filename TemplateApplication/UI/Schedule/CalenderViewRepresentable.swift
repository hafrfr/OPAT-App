// TemplateApplication/UI/Schedule/CalenderViewRepresentable.swift
import SwiftUI
import UIKit
import Combine

struct CalendarViewRepresentable: UIViewRepresentable {
    var calendar = Calendar.current
    let treatmentDates: [DateComponents]
    let todayStartOfDay: Date

    // Initializer accepts Array
    init(treatmentDates: [DateComponents]) {
        self.treatmentDates = treatmentDates
        self.calendar = Calendar.current
        self.todayStartOfDay = self.calendar.startOfDay(for: Date())
    }

    func makeUIView(context: Context) -> UICalendarView {
        let uiCalendarView = UICalendarView()
        uiCalendarView.calendar = self.calendar
        uiCalendarView.locale = Locale.current
        uiCalendarView.fontDesign = .default
        uiCalendarView.delegate = context.coordinator

        // Pass data to coordinator
        context.coordinator.parentCalendar = self.calendar
        // --- CHANGE 2: Pass the list ---
        context.coordinator.treatmentDates = self.treatmentDates
        context.coordinator.todayStartOfDay = self.todayStartOfDay

        return uiCalendarView
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.parentCalendar = self.calendar
        // --- CHANGE 3: Update the list ---
        context.coordinator.treatmentDates = self.treatmentDates
        context.coordinator.todayStartOfDay = self.calendar.startOfDay(for: Date())

        // Reload decorations needs an Array, which treatmentDates now is
        let allDates = self.treatmentDates
        DispatchQueue.main.async {
             uiView.reloadDecorations(forDateComponents: allDates, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator Class
    class Coordinator: NSObject, UICalendarViewDelegate {
        var parent: CalendarViewRepresentable
        // --- CHANGE 4: Store an Array ---
        var treatmentDates: [DateComponents] = []
        var todayStartOfDay: Date?
        var parentCalendar: Calendar?

        init(_ parent: CalendarViewRepresentable) {
            self.parent = parent
            self.parentCalendar = parent.calendar
            super.init()
        }

        // Method to update list (optional if direct assignment in updateUIView is used)
        // func updateTreatmentDates(_ newList: [DateComponents]) { self.treatmentDates = newList }


        @MainActor
        func calendarView(_ calendarView: UICalendarView,
                          decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {

            guard let calendar = self.parentCalendar else { return nil }

            // Get year/month/day from the components being checked
            guard let year = dateComponents.year,
                  let month = dateComponents.month,
                  let day = dateComponents.day else {
                return nil
            }
            // Create a simple object for comparison (calendar association not strictly needed for manual comparison)
            let componentsToCompare = DateComponents(year: year, month: month, day: day)

            // --- CHANGE 5: Loop through the list instead of Set.contains ---
            var isTreatmentDate = false // Flag to track if we found a match
            for itemInList in self.treatmentDates {
                // Direct comparison of year, month, day
                if itemInList.year == componentsToCompare.year &&
                   itemInList.month == componentsToCompare.month &&
                   itemInList.day == componentsToCompare.day {
                    isTreatmentDate = true
                    break // Found a match, exit the loop
                }
            }
            // --- End of loop ---

            // If no match was found in the loop, return no decoration
            guard isTreatmentDate else {
                // print("-> No match found for \(componentsToCompare)") // Debug log
                return nil
            }

            // --- Match found: Proceed with color logic (same as before) ---
            guard let todayStart = self.todayStartOfDay else {
                print("Warning: todayStartOfDay not set in Coordinator")
                return nil
            }

            // Convert components *being checked* to Date for comparison
            guard let date = calendar.date(from: componentsToCompare) else {
                 print("Warning: Could not convert components to date: \(componentsToCompare)")
                 return nil
            }

            let isPast = date < todayStart
            let color = isPast ? UIColor.systemRed : UIColor.systemGreen

            // print("-> Returning decoration for \(componentsToCompare) - IsPast: \(isPast), Color: \(isPast ? "Red" : "Green")")

            return .image(
                UIImage(systemName: "syringe.fill"),
                color: color,
                size: .small
            )
        }

        func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
             print("Visible dates changed - Coordinator notified") // Keep if needed
        }
    }
}
