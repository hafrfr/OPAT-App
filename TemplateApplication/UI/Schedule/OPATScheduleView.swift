
@_spi(TestingSupport) import SpeziAccount
import SpeziScheduler    // Ensure Scheduler is available for event completion
import SpeziSchedulerUI
import SwiftUI
import SpeziViews

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FontTheme.button)
            .foregroundColor(.white) // Ensures white text
            .frame(maxWidth: .infinity)
            .padding(.vertical, Layout.Spacing.medium)
            .background(ColorTheme.buttonLarge) // Your custom background
            .cornerRadius(Layout.Radius.medium)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
// --- END Placeholder Themes/Layout & Custom Button Style ---


struct OPATScheduleView: View {
    // MARK: - Static Date Range Helper
    private static var todayRange: Range<Date> {
        let start = Calendar.current.startOfDay(for: .now)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        return start..<end
    }
    
    // MARK: - Environment Modules
    @Environment(Account.self) private var account: Account?
    @Environment(TemplateApplicationScheduler.self) private var appScheduler: TemplateApplicationScheduler
    @Environment(TemplateApplicationStandard.self) private var standard
    
    @EventQuery(in: Self.todayRange) private var todaysEvents: [Event]
    
    // MARK: - View State
    @State private var presentedEvent: Event?
    @Binding private var presentingAccount: Bool

    @State private var eventToProcess: Event? = nil // Holds the event targeted for completion
    
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }

    var body: some View {
        // Use @Bindable if you are modifying appScheduler.viewState directly
        // and appScheduler is an ObservableObject.
        // If appScheduler is a class and you are modifying its properties that
        // are @Published, the @Environment object itself will trigger view updates.
        // For ViewState in Spezi, it's often part of an ObservableObject.
        @Bindable var appScheduler = appScheduler

        NavigationStack {
            PrimaryBackgroundView(title: "Schedule") {
                VStack(spacing: Layout.Spacing.medium) {
                    TreatmentProgressBar()
                        .padding(.horizontal)
                        .onTapGesture(count: 3) {
                            UserDefaults.standard.set(false, forKey: StorageKeys.onboardingFlowComplete)
                            print("🔄 Developer triggered: Onboarding reset via progress bar")
                        }

                    if todaysEvents.isEmpty {
                        Spacer()
                        Text("No events scheduled for today.").foregroundColor(.secondary).padding()
                        Spacer()
                    } else {
                        EventScheduleList(date: .now) { event in
                            eventRow(event)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        // ID to help SwiftUI redraw when event completion or viewState changes
                        .id(todaysEvents.map { "\($0.id)-\($0.isCompleted)" }.joined() + "\(appScheduler.viewState)")
                    }
                }
            }
            .toolbar { toolbarContent }
            .sheet(item: $presentedEvent) { EventView($0) }
            .viewStateAlert(state: $appScheduler.viewState)
            // --- Task Modifier to Handle Async Work, triggered by viewState ---
            .task(id: appScheduler.viewState) { // Re-evaluates when viewState changes
                // Only act if viewState is .processing AND we have an event targeted
                if case .processing = appScheduler.viewState, let event = self.eventToProcess {
                    print("OPATScheduleView: .task triggered by .processing state for event \(event.id)")
                    await completeAndLogEvent(event)
                   
                } else if appScheduler.viewState != .processing && self.eventToProcess != nil {
                    self.eventToProcess = nil
                    print("OPATScheduleView: .task detected viewState no longer .processing, cleared eventToProcess.")
                }
            }
            // --- End Task Modifier ---
        }
    }

    @ViewBuilder
    private func eventRow(_ event: Event) -> some View {
        InstructionsTile(event) {
            actionButton(for: event)
        }
        .padding().background(ColorTheme.listItemBackground).cornerRadius(Layout.Radius.medium)
        .shadowStyle(ShadowTheme.card)
        .listRowInsets(EdgeInsets(top: Layout.Spacing.small, leading: 0, bottom: Layout.Spacing.small, trailing: 0))
        .listRowSeparator(.hidden).listRowBackground(Color.clear)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if account != nil { AccountButton(isPresented: $presentingAccount) }
            else {
                NavigationLink(destination: ManageTreatmentsView()) {
                    Label("Manage Treatments", systemImage: "list.bullet.clipboard").font(FontTheme.body).foregroundColor(ColorTheme.title)
                }
            }
        }
    }
    
    @ViewBuilder
    private func actionButton(for event: Event) -> some View {
        let isDisabledByCompletion = event.isCompleted
        // Disable the button if this specific event is being processed
        let isDisabledByProcessing = (self.eventToProcess?.id == event.id && appScheduler.viewState == .processing)
        let finalDisabledState = isDisabledByCompletion || isDisabledByProcessing

        if event.task.id.starts(with: "treatment-") {
            VStack(spacing: Layout.Spacing.small) {
                markCompleteButton(for: event, disabled: finalDisabledState)
                instructionsButton(disabled: isDisabledByCompletion)
            }.padding(.top, Layout.Spacing.small)
        } else if event.task.id == "opatfollowup" || event.task.id == "opat-checkin" {
            SwiftUI.Button {
                if !finalDisabledState { 
                    presentedEvent = event
                }
            } label: { Text("Start Check-In") }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(finalDisabledState)
        } else {
            Text("Task: \(event.task.title.key)").font(.caption).foregroundColor(.gray).padding(.horizontal)
        }
    }
    
    private func markCompleteButton(for event: Event, disabled: Bool) -> some View {
        SwiftUI.Button {
            // SYNCHRONOUS action: Set eventToProcess and change appScheduler.viewState
            if !disabled {
                print("OPATScheduleView: Mark Complete button tapped for \(event.id). Setting state to .processing.")
                self.eventToProcess = event       // Target this event
                self.appScheduler.viewState = .processing // Trigger the .task and indicate processing
            }
        } label: {
            Label("Mark Complete", systemImage: "checkmark.circle")
        }
        .buttonStyle(PrimaryActionButtonStyle())
        .disabled(disabled)
    }
    
    private func instructionsButton(disabled: Bool) -> some View {
        SwiftUI.Button {
            print("Instructions button tapped.")
            // TODO: Navigate to instruction view
        } label: { Label("To Instructions", systemImage: "book") }
        .buttonStyle(PrimaryActionButtonStyle())
        .disabled(disabled)
    }
    
    @MainActor
    private func completeAndLogEvent(_ event: Event) async {
        // viewState should already be .processing, set by the button action.
        
        do {
            _ = try event.complete()
            print("OPATScheduleView: Successfully completed SpeziScheduler event \(event.task.id) / \(event.id)")
            do {
                let eventLogEntry = try EventLog(from: event, completionTime: Date()) // Ensure EventLog init uses event.start
                await standard.logCompletedEvent(eventLogEntry)
                print("OPATScheduleView: Logged completion for SpeziScheduler event \(event.id)")
                self.appScheduler.viewState = .idle // Set to .idle on full success
            } catch {
                print("OPATScheduleView: fail; event \(event.id): \(error.localizedDescription)")
                // Ensure the error passed to ViewState.error conforms to LocalizedError
                self.appScheduler.viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Could not."))
            }
        } catch {
            print("OPATScheduleView: Error completingt \(event.task.id) / \(event.id): \(error.localizedDescription)")
            self.appScheduler.viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Failed ."))
        }
    }
}


#if DEBUG
#Preview {
    @Previewable @State var presentingAccount = false
    OPATScheduleView(presentingAccount: $presentingAccount)
        .previewWith(standard: TemplateApplicationStandard()) {
            Scheduler()
            TemplateApplicationScheduler()
            TreatmentModel()
            TreatmentScheduler()
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
