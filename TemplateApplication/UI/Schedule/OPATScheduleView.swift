// TemplateApplication/UI/Schedule/OPATScheduleView.swift
// Refactored to use a helper function for the completion logic.
// Added explicit 'action:' label for EventActionButton calls.

@_spi(TestingSupport) import SpeziAccount
import SpeziScheduler // Ensure Scheduler is available for event completion
import SpeziSchedulerUI
import SpeziViews
import SwiftUI


struct OPATScheduleView: View {
    // MARK: Environment Variables
    @Environment(Account.self) private var account: Account?
    @Environment(TemplateApplicationScheduler.self) private var appScheduler: TemplateApplicationScheduler // App-specific scheduler for viewState
    @Environment(TreatmentModel.self) private var treatmentModel
    //@Environment(TreatmentNotifications.self) private var treatmentNotifier
    @Environment(TreatmentScheduler.self) private var treatmentScheduler
    
    
    // MARK: State Variables

    @State private var presentedEvent: Event? // For presenting questionnaires via sheet
    @Binding private var presentingAccount: Bool // For presenting account sheet

    // MARK: - Body
    var body: some View {
        @Bindable var appScheduler = appScheduler

        NavigationStack {
            EventScheduleList(date: .today) { event in
                InstructionsTile(event) {
                    // Call the helper function to get the appropriate action button
                    actionButton(for: event)
                }
            }.id(treatmentModel.treatments.count)
            .navigationTitle("Schedule")
            .viewStateAlert(state: $appScheduler.viewState)
            .sheet(item: $presentedEvent) { event in
                EventView(event)
            }
            .toolbar {
                // Add account button to toolbar if account is available
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }else {
                    NavigationLink{
                        ManageTreatmentsView()
                    } label: {
                        Label("Manage Treatments", systemImage: "list.bullet.clipboard")
                    }
                    
                }
            }
        }
    }

    // MARK: - Initialization
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }

    // MARK: - Private Helper Views
    /// Creates the appropriate action button based on the event's task ID.
    @ViewBuilder private func actionButton(for event: Event) -> some View {
        // Determine if the button should be disabled
        let isDisabled = event.isCompleted

        // Conditional logic based on task ID
        if event.task.id.hasPrefix("treatment-") {
            // --- Button for Treatment Tasks (Main and Reminder) ---
            // Use explicit 'action:' label for the closure
            EventActionButton(event: event, "Mark Complete", action: {
                // Action: Call the helper function to mark the event complete
                completeTreatmentTask(event)
            })
            .disabled(isDisabled) // Disable if complete or past due

        } else if event.task.id == "opat-followup" {
            // --- Button for Questionnaire Tasks ---
            // Use explicit 'action:' label for the closure
            EventActionButton(event: event, "Start", action: {
                // Action: Set the state variable to present the EventView sheet
                presentedEvent = event
            })
            .disabled(isDisabled) // Disable if complete or past due

        } else {
             Text("Unknown Task") // Simplified fallback
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal) // Add some padding if needed
        }
    }

    // MARK: - Private Helper Functions
    /// Marks a treatment-related event as complete.
    private func completeTreatmentTask(_ event: Event) {
            do {
                try  event.complete()
                print("Marked event \(event.task.id) as complete.")
            } catch {
                print("Error completing event \(event.task.id): \(error)")
            }
        }
}

// MARK: - Preview
#if DEBUG
#Preview {
    @Previewable @State var presentingAccount = false

    // Mock data setup for preview might be needed to show both button types
    // This requires creating mock Tasks and Events if not already done by Spezi previews

    OPATScheduleView(presentingAccount: $presentingAccount)
        .previewWith(standard: TemplateApplicationStandard()) {

            Scheduler() // The actual scheduler module
            TemplateApplicationScheduler() // Your app-specific scheduler logic
            
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
