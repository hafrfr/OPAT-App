@_spi(TestingSupport) import SpeziAccount
import SpeziScheduler
import SpeziSchedulerUI
import SpeziViews
import SwiftUI

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FontTheme.button)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Layout.Spacing.medium)
            .background(ColorTheme.buttonLarge)
            .cornerRadius(Layout.Radius.medium)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct OPATScheduleView: View {
    private static var todayRange: Range<Date> {
        let start = Calendar.current.startOfDay(for: .now)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        return start..<end
    }

    @Environment(Account.self) private var account: Account?
    @Environment(TemplateApplicationScheduler.self) private var appScheduler: TemplateApplicationScheduler
    @Environment(TemplateApplicationStandard.self) private var standard

    @EventQuery(in: Self.todayRange) private var todaysEvents: [Event]
    
    // MARK: - View State
    @Binding private var presentingAccount: Bool // For account sheet

    // State for managing the presentation of VitalsPreambleView and then EventView (Questionnaire)
    @State private var eventForVitalsPreamble: Event? = nil
    @State private var eventForQuestionnaireSheet: Event? = nil // Renamed from presentedEvent for clarity
    @State private var healthKitSnapshotForQuestionnaire: HealthKitSnapshot? = nil

    // State for managing completion of non-questionnaire tasks
    @State private var eventToProcessForCompletion: Event? = nil
    
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }

    var body: some View {
        // Use @Bindable if appScheduler is an ObservableObject and you're modifying its ViewState
        @Bindable var appScheduler = appScheduler

        NavigationStack {
            PrimaryBackgroundView(title: "Schedule") {
                VStack(spacing: 16) { TreatmentProgressBar().padding(.horizontal)
                    if todaysEvents.isEmpty {
                        Spacer()
                        Text("No events scheduled for today.").foregroundColor(.secondary).padding()
                        Spacer()
                    } else {
                        EventScheduleList(date: .now) { event in eventRow(event) }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .id(todaysEvents.map { "\($0.id)-\($0.isCompleted)" }.joined() + "\(appScheduler.viewState)")
                    }
                }
            }
            .toolbar { toolbarContent }
            // Sheet for Vitals Preamble
            .sheet(item: $eventForVitalsPreamble) { eventToPreamble in
                // Ensure VitalsPreambleView is correctly defined and accepts these parameters
                VitalsPreambleView(event: eventToPreamble) { snapshot in
                    // This callback is triggered from VitalsPreambleView
                    self.healthKitSnapshotForQuestionnaire = snapshot
                    self.eventForQuestionnaireSheet = eventToPreamble // Trigger questionnaire sheet
                    self.eventForVitalsPreamble = nil // Dismiss VitalsPreambleView sheet
                }
            }
            // Sheet for Questionnaire (EventView) - triggered after preamble
            .sheet(item: $eventForQuestionnaireSheet) { eventForSheet in
                // Ensure EventView is correctly defined and accepts these parameters
                EventView(eventForSheet, healthKitSnapshotFromPreamble: healthKitSnapshotForQuestionnaire)
            }
            .viewStateAlert(state: $appScheduler.viewState) // For general errors from appScheduler
            // Task Modifier for completing non-questionnaire events
            .task(id: appScheduler.viewState) {
                if case .processing = appScheduler.viewState, let event = self.eventToProcessForCompletion {
                    // Use String(describing:) for logging Event.ID if it's not directly a String or UUID
                    print("OPATScheduleView: .task triggered by .processing state for event \(String(describing: event.id))")
                    await completeAndLogRegularEvent(event) // Use a specific function for regular events
                } else if appScheduler.viewState != .processing && self.eventToProcessForCompletion != nil {
                    self.eventToProcessForCompletion = nil
                    print("OPATScheduleView: .task detected viewState no longer .processing, cleared eventToProcessForCompletion.")
                }
            }
        }
    }

    // MARK: - Components

    @ViewBuilder
    private func eventRow(_ event: Event) -> some View {
        // Assuming InstructionsTile is defined and handles event display
        InstructionsTile(event) {
            actionButton(for: event)
        }
        .padding()
        .background(Color.white) // Example, use your ColorTheme.listItemBackground
        .cornerRadius(12) // Example, use your Layout.Radius.medium
        // .shadowStyle(ShadowTheme.card) // Assuming ShadowTheme is defined
        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)) // Example spacing
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if account != nil {
                AccountButton(isPresented: $presentingAccount) // Assuming AccountButton is defined
            } else {
                // Link to ManageTreatmentsView if no account button shown
                NavigationLink(destination: ManageTreatmentsView()) { // Assuming ManageTreatmentsView is defined
                    Label("Manage Treatments", systemImage: "list.bullet.clipboard")
                        // .font(FontTheme.body) // Assuming FontTheme is defined
                        // .foregroundColor(ColorTheme.title) // Assuming ColorTheme is defined
                }
            }
        }
    }

    @ViewBuilder
    private func actionButton(for event: Event) -> some View {
        let isDisabledByCompletion = event.isCompleted
        // Disable button if this specific event is being processed (for non-questionnaire tasks)
        let isDisabledByProcessing = (self.eventToProcessForCompletion?.id == event.id && appScheduler.viewState == .processing)
        let finalDisabledState = isDisabledByCompletion || isDisabledByProcessing

        if event.task.id == "opatfollowup" || event.task.id == "opat-checkin" { // Specific handling for daily check-in
            Button(action: {
                if !isDisabledByCompletion { // Allow re-opening if needed, or keep finalDisabledState
                    // Use String(describing:) for logging Event.ID
                    print("OPATScheduleView: 'Start Check-In' tapped for \(String(describing: event.id)). Presenting Vitals Preamble.")
                    self.eventForVitalsPreamble = event // Trigger VitalsPreambleView
                }
            }, label: {
                 Text("Start Check-In")
            })
            .buttonStyle(PrimaryActionButtonStyle()) // Assuming PrimaryActionButtonStyle is defined
            .disabled(isDisabledByCompletion) // Or finalDisabledState if you don't want re-entry while processing other tasks
        
        } else if event.task.id.starts(with: "treatment-") { // For other treatment tasks
            VStack(spacing: 8) { // Assuming Layout.Spacing.small
                markCompleteButton(for: event, disabled: finalDisabledState)
                // instructionsButton(disabled: isDisabledByCompletion) // Assuming instructionsButton defined
            }.padding(.top, 8) // Assuming Layout.Spacing.small
        } else {
            // Fallback for other task types
            // Assuming event.task.title is LocalizedStringResource or similar that can be directly used in Text
            Text("Task: \(event.task.title)")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
    }

    private func markCompleteButton(for event: Event, disabled: Bool) -> some View {
        Button(action: {
            if !disabled {
                // Use String(describing:) for logging Event.ID
                print("OPATScheduleView: Mark Complete button tapped for \(String(describing: event.id)). Setting state to .processing.")
                self.eventToProcessForCompletion = event // Target this event for completion
                self.appScheduler.viewState = .processing // Trigger the .task for regular event completion
            }
        }, label: {
            Label("Mark Complete", systemImage: "checkmark.circle")
        })
        .buttonStyle(PrimaryActionButtonStyle())
        .disabled(disabled)
    }
    
    // Removed instructionsButton for brevity, add back if needed
    // private func instructionsButton(disabled: Bool) -> some View { ... }
    
    @MainActor
    private func completeAndLogRegularEvent(_ event: Event) async {
        // This function is for non-questionnaire events that are simply marked complete.
        do {
            _ = try event.complete()
            // Use String(describing:) for logging Event.ID
            print("OPATScheduleView: Successfully completed SpeziScheduler event \(event.task.id) / \(String(describing: event.id))")
            
            // Create EventLog without questionnaireResponseId or HealthKitSnapshot for regular tasks
            let eventLogEntry = EventLog(from: event, completionTime: Date())
            await standard.logCompletedEvent(eventLogEntry)
            print("OPATScheduleView: Logged completion for regular event \(String(describing: event.id))")
            
            self.appScheduler.viewState = .idle // Set to .idle on full success
        } catch {
            // Use String(describing:) for logging Event.ID
            print("OPATScheduleView: Error completing regular event \(event.task.id) / \(String(describing: event.id)): \(error.localizedDescription)")
            self.appScheduler.viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Failed to complete event."))
        }
    }
}

// NOTE: The #if DEBUG preview block is removed as per user request.
// To add it back, ensure all mock data (mockTask, mockEvent) and
// Spezi environment setup (.previewWith) are correctly implemented.
// Also, ensure helper structs like PrimaryActionButtonStyle, FontTheme, ColorTheme,
// Layout, InstructionsTile, AccountButton, ManageTreatmentsView, TreatmentProgressBar
// are available or mocked for the preview.
