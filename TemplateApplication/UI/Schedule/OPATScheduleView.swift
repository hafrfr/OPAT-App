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
    @Environment(TemplateApplicationScheduler.self) private var appScheduler: TemplateApplicationScheduler
    @Environment(TreatmentModel.self) private var treatmentModel
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
                    actionButton(for: event)
                }
            }
            .id(treatmentModel.treatments.count)
            .navigationTitle("Schedule")
            .viewStateAlert(state: $appScheduler.viewState)
            .sheet(item: $presentedEvent) { event in
                EventView(event)
            }
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                } else {
                    NavigationLink {
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
    @ViewBuilder private func actionButton(for event: Event) -> some View {
        let isDisabled = event.isCompleted

        if event.task.id.starts(with: "treatment-") {
            HStack {
                EventActionButton(event: event, "Mark Complete", action: {
                    completeTreatmentTask(event)
                })
                .disabled(isDisabled)

                Spacer()
                Button("To Instructions") {
                    // Action for instructions button
                }
                .buttonStyle(.bordered)
                .disabled(isDisabled)
            }
        } else if event.task.id == "opat-checkin" {
            EventActionButton(event: event, "Start", action: {
                presentedEvent = event
            })
            .disabled(isDisabled)
        } else {
            Text("Unknown Task")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
    }

    // MARK: - Private Helper Functions
    /// Marks a treatment-related event as complete.
    private func completeTreatmentTask(_ event: Event) {
        do {
            try event.complete()
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

    OPATScheduleView(presentingAccount: $presentingAccount)
        .previewWith(standard: TemplateApplicationStandard()) {
            Scheduler() // The actual scheduler module
            TemplateApplicationScheduler() // Your app-specific scheduler logic
            TreatmentModel()
            TreatmentScheduler()
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
