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
    
    @Environment(GuideModule.self) private var guideModule

    @EventQuery(in: Self.todayRange) private var todaysEvents: [Event]
    
    // MARK: - View State
    @Binding private var presentingAccount: Bool // For account sheet

    // State for managing the presentation of VitalsPreambleView and then EventView (Questionnaire)
    @State private var eventForVitalsPreamble: Event? = nil
    @State private var eventForQuestionnaireSheet: Event? = nil // Renamed from presentedEvent for clarity
    @State private var healthKitSnapshotForQuestionnaire: HealthKitSnapshot? = nil
    @State private var showInstructionsView = false
    // State for managing completion of non-questionnaire tasks
    @State private var eventToProcessForCompletion: Event? = nil
    @State private var showWelcomeGreeting = true // welcome flag for presentation, but maybe applying later!
    
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }

    var body: some View {
        NavigationStack {
            mainContent
        }
    }

    private var mainContent: some View {
        @Bindable var appScheduler = appScheduler

        return PrimaryBackgroundView(title: "Schedule") {
            VStack(spacing: 16) {
                welcomeBannerIfNeeded 
                TreatmentProgressBar()
                    .padding(.horizontal)
                    .onTapGesture(count: 3) {
                        UserDefaults.standard.set(false, forKey: StorageKeys.onboardingFlowComplete)
                    }

                if todaysEvents.isEmpty {
                    Spacer()
                    Text("No events scheduled for today.")
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                } else {
                    EventScheduleList(date: .now) { event in
                        eventRow(event)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    // Taking the .id from a9f7aa1 as it explicitly includes appScheduler.viewState
                    .id(todaysEvents.map { "\($0.id)-\($0.isCompleted)" }.joined() + "\(appScheduler.viewState)")
                }
            }
        }
        .toolbar { toolbarContent }
        .sheet(item: $eventForVitalsPreamble) { eventToPreamble in // Using HEAD's explicit parameter names
            VitalsPreambleView(event: eventToPreamble) { snapshot in
                self.healthKitSnapshotForQuestionnaire = snapshot
                self.eventForQuestionnaireSheet = eventToPreamble
                self.eventForVitalsPreamble = nil
            }
        }
        .sheet(item: $eventForQuestionnaireSheet) { eventForSheet in // Using HEAD's explicit parameter names
            EventView(eventForSheet, healthKitSnapshotFromPreamble: healthKitSnapshotForQuestionnaire)
        }
        .navigationDestination(isPresented: $showInstructionsView) {
            InstructionsListView(presentingAccount: $presentingAccount)
        }
        .viewStateAlert(state: $appScheduler.viewState) // From HEAD
        .task(id: appScheduler.viewState) { // From HEAD
            if case .processing = appScheduler.viewState, let event = self.eventToProcessForCompletion {
                print("OPATScheduleView: .task triggered by .processing state for event \(String(describing: event.id))")
                await completeAndLogRegularEvent(event)
            } else if appScheduler.viewState != .processing && self.eventToProcessForCompletion != nil {
                self.eventToProcessForCompletion = nil
                print("OPATScheduleView: .task detected viewState no longer .processing, cleared eventToProcessForCompletion.")
            }
        }
    }

    private var welcomeBannerIfNeeded: some View {
        Group {
            if showWelcomeGreeting {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back 👋")
                        .font(FontTheme.title) // use bodyBold for when we have names intentionally light/subdued
                        .foregroundColor(ColorTheme.title.opacity(0.8)) // subtle, not dominant
                    // Text("Richard 👋") // Assuming "Richard 👋" example patient for presentation
                        // .font(FontTheme.title)
                        // .foregroundColor(ColorTheme.title) // strong, bold primary
                }
                .padding(.horizontal)
                .padding(.top, Layout.Spacing.medium)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showWelcomeGreeting = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6.5) {
                        withAnimation {
                            showWelcomeGreeting = false
                        }
                    }
                }
            }
        }
    }


    // MARK: - Components

    @ViewBuilder
    private func eventRow(_ event: Event) -> some View {
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
        let isDisabledByProcessing = (self.eventToProcessForCompletion?.id == event.id && appScheduler.viewState == .processing)
        let finalDisabledState = isDisabledByCompletion || isDisabledByProcessing

        if event.task.id == "opatfollowup" || event.task.id == "opat-checkin" { // Specific handling for daily check-in
            Button(action: {
                if !isDisabledByCompletion {
                    print("OPATScheduleView: 'Start Check-In' tapped for \(String(describing: event.id)). Presenting Vitals Preamble.")
                    self.eventForVitalsPreamble = event
                }
            }, label: {
                 Text("Start Check-In")
            })
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(isDisabledByCompletion)
        } else if event.task.id.starts(with: "treatment-") { // For other treatment tasks
            VStack(spacing: 8) { // Assuming Layout.Spacing.small
                markCompleteButton(for: event, disabled: finalDisabledState)
                instructionsButton(disabled: isDisabledByCompletion)
            }.padding(.top, 8) // Assuming Layout.Spacing.small
        } else {
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
    
    private func instructionsButton(disabled: Bool) -> some View {
        Button(action: {
            if !disabled {
                self.showInstructionsView = true // Set state to trigger navigation
            }
        }) {
            Label("To Instructions", systemImage: "book")
        }
        .buttonStyle(PrimaryActionButtonStyle()) // Apply the same style as Mark Complete
        .disabled(disabled)
        .opacity(disabled ? 0.6 : 1.0) // Adjusted opacity slightly for disabled state
    }
    
    
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
