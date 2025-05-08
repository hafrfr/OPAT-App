// TemplateApplication/UI/Schedule/CalenderViewRepresentable.swift
import SwiftUI
import UIKit
import Combine

struct CalendarViewRepresentable: UIViewRepresentable {
    let calendar: Calendar
    let treatmentDates: [DateComponents] // Use Array as decided before
    let todayStartOfDay: Date
    // --- ADD Binding for selected date ---
    @Binding var selectedDate: Date?

    // Initializer accepts Array and Binding
    init(treatmentDates: [DateComponents], selectedDate: Binding<Date?>) {
        self.treatmentDates = treatmentDates
        self._selectedDate = selectedDate // Initialize binding
        self.calendar = Calendar.current
        self.todayStartOfDay = self.calendar.startOfDay(for: Date())
    }

    func makeUIView(context: Context) -> UICalendarView {
        let uiCalendarView = UICalendarView()
        uiCalendarView.calendar = self.calendar
        uiCalendarView.locale = Locale.current
        uiCalendarView.fontDesign = .default
        uiCalendarView.delegate = context.coordinator // For Decorations

        // --- Setup Selection ---
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        uiCalendarView.selectionBehavior = selection
        // Set initial selection if a date is already selected in the state
        if let currentDate = selectedDate {
            let components = calendar.dateComponents([.year, .month, .day], from: currentDate)
            selection.setSelected(components, animated: false)
        }
        // ---------------------

        // Pass data to coordinator
        context.coordinator.parent = self // Pass self to coordinator
        context.coordinator.parentCalendar = self.calendar
        context.coordinator.treatmentDates = self.treatmentDates
        context.coordinator.todayStartOfDay = self.todayStartOfDay
        // context.coordinator.parentBinding = self.$selectedDate // No longer need separate binding var in Coordinator

        return uiCalendarView
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // Update coordinator data (decoration related)
        context.coordinator.parentCalendar = self.calendar
        context.coordinator.treatmentDates = self.treatmentDates
        context.coordinator.todayStartOfDay = self.calendar.startOfDay(for: Date())

        // Update selection state if the binding changed externally (less common)
        // Careful not to cause infinite loops
        if let selection = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
            let boundDateComponents: DateComponents?
            if let boundDate = selectedDate {
                boundDateComponents = calendar.dateComponents([.year, .month, .day], from: boundDate)
            } else {
                boundDateComponents = nil
            }

            // Only update selection if it differs from the binding
            if selection.selectedDate != boundDateComponents {
                 print("Updating selection from binding: \(String(describing: boundDateComponents))")
                 selection.setSelected(boundDateComponents, animated: true)
            }
        }


        // Reload decorations
        let allDates = self.treatmentDates
        DispatchQueue.main.async {
             uiView.reloadDecorations(forDateComponents: allDates, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator Class
    // --- Coordinator now handles BOTH decoration AND selection ---
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarViewRepresentable // Direct reference to parent
        var treatmentDates: [DateComponents] = []
        var todayStartOfDay: Date?
        var parentCalendar: Calendar?

        init(_ parent: CalendarViewRepresentable) {
            self.parent = parent
            self.parentCalendar = parent.calendar
            super.init()
        }

        // --- UICalendarViewDelegate (Decoration) ---
        @MainActor
        func calendarView(_ calendarView: UICalendarView,
                          decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            // ... (Decoration logic using loop as implemented previously) ...
            guard let calendar = self.parentCalendar else { return nil }
            guard let year = dateComponents.year, let month = dateComponents.month, let day = dateComponents.day else { return nil }
            let componentsToCompare = DateComponents(year: year, month: month, day: day)

            var isTreatmentDate = false
            for itemInList in self.treatmentDates {
                if itemInList.year == componentsToCompare.year &&
                   itemInList.month == componentsToCompare.month &&
                   itemInList.day == componentsToCompare.day {
                    isTreatmentDate = true
                    break
                }
            }
            guard isTreatmentDate else { return nil }

            guard let todayStart = self.todayStartOfDay,
                  let date = calendar.date(from: componentsToCompare) else { return nil }

            let isPast = date < todayStart
            let color = isPast ? UIColor.systemRed : UIColor.systemGreen

            return .image(UIImage(systemName: "syringe.fill"), color: color, size: .small)
        }

        // --- UICalendarSelectionSingleDateDelegate (Selection) ---
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
                    guard let components = dateComponents, let calendar = self.parentCalendar else {
                        parent.selectedDate = nil
                        print("Date deselected or calendar missing")
                        return
                    }

                    if let selectedDateObject = calendar.date(from: components) {
                        // --- vvv CORRECTED CODE vvv ---
                        // Calculate the start of the selected day using the calendar
                        let startOfSelectedDay = calendar.startOfDay(for: selectedDateObject)

                        // Updated print statement for clarity
                        print("Date selected: \(selectedDateObject), Storing Start: \(startOfSelectedDay)")

                        // Update the binding with the START OF THE DAY value
                        parent.selectedDate = startOfSelectedDay
                        // --- ^^^ CORRECTED CODE ^^^ ---
                    } else {
                        print("Could not convert selected components to Date: \(components)")
                        parent.selectedDate = nil
                    }
                }

        // Optional: Implement if needed to control which dates are selectable
         func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
             // Allow selection of any date by default
             return true
             // Or, only allow selection of treatment dates:
             /*
             guard let calendar = self.parentCalendar,
                   let year = dateComponents?.year,
                   let month = dateComponents?.month,
                   let day = dateComponents?.day else {
                 return false // Cannot select invalid components
             }
             let componentsToCompare = DateComponents(year: year, month: month, day: day)
             return self.treatmentDates.contains { itemInList in
                 itemInList.year == componentsToCompare.year &&
                 itemInList.month == componentsToCompare.month &&
                 itemInList.day == componentsToCompare.day
             }
             */
         }
    }
}
