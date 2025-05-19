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

    @State private var presentedEvent: Event?
    @Binding private var presentingAccount: Bool
    @State private var eventToProcess: Event?

    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }

    var body: some View {
        @Bindable var appScheduler = appScheduler

        NavigationStack {
            PrimaryBackgroundView(title: "Schedule") {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: Layout.Spacing.medium, pinnedViews: []) {
                        TreatmentProgressBar()
                            .padding(.horizontal)
                            .onTapGesture(count: 3) {
                                UserDefaults.standard.set(false, forKey: StorageKeys.onboardingFlowComplete)
                            }

                        if todaysEvents.isEmpty {
                            Text("No events scheduled for today.")
                                .foregroundColor(.secondary)
                                .padding(.top, Layout.Spacing.xLarge)
                                .frame(maxWidth: .infinity)
                        } else {
                            ForEach(todaysEvents) { event in
                                eventRow(event)
                            }
                        }
                    }
                    .padding(.top, Layout.Spacing.large)
                    .padding(.horizontal, Layout.Spacing.large)
                    .padding(.bottom, Layout.Spacing.xLarge + 15) // For extra breathing room
                }
                .scrollDismissesKeyboard(.interactively)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: Layout.Spacing.xLarge) // Prevents tab bar overlap
                }
            }
        }
        .toolbar { toolbarContent }
        .sheet(item: $presentedEvent) { EventView($0) }
        .viewStateAlert(state: $appScheduler.viewState)
        .task(id: appScheduler.viewState) {
            if case .processing = appScheduler.viewState, let event = self.eventToProcess {
                await completeAndLogEvent(event)
            } else if appScheduler.viewState != .processing && self.eventToProcess != nil {
                self.eventToProcess = nil
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
        .background(ColorTheme.listItemBackground)
        .cornerRadius(Layout.Radius.medium)
        .shadowStyle(ShadowTheme.card)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if account != nil {
                AccountButton(isPresented: $presentingAccount)
            } else {
                NavigationLink(destination: ManageTreatmentsView()) {
                    Label("Manage Treatments", systemImage: "list.bullet.clipboard")
                        .font(FontTheme.body)
                        .foregroundColor(ColorTheme.title)
                }
            }
        }
    }

    @ViewBuilder
    private func actionButton(for event: Event) -> some View {
        let isDisabledByCompletion = event.isCompleted
        let isDisabledByProcessing = (self.eventToProcess?.id == event.id && appScheduler.viewState == .processing)
        let finalDisabledState = isDisabledByCompletion || isDisabledByProcessing

        if event.task.id.starts(with: "treatment-") {
            VStack(spacing: Layout.Spacing.small) {
                markCompleteButton(for: event, disabled: finalDisabledState)
                instructionsButton(disabled: isDisabledByCompletion)
            }
            .padding(.top, Layout.Spacing.small)
        } else if event.task.id == "opatfollowup" || event.task.id == "opat-checkin" {
            Button {
                if !finalDisabledState {
                    presentedEvent = event
                }
            } label: {
                Text("Start Check-In")
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(finalDisabledState)
        } else {
            Text("Task: \(event.task.title.key)")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
    }

    private func markCompleteButton(for event: Event, disabled: Bool) -> some View {
        Button {
            if !disabled {
                self.eventToProcess = event
                self.appScheduler.viewState = .processing
            }
        } label: {
            Label("Mark Complete", systemImage: "checkmark.circle")
        }
        .buttonStyle(PrimaryActionButtonStyle())
        .disabled(disabled)
    }

    private func instructionsButton(disabled: Bool) -> some View {
        Button {
            print("Instructions button tapped.")
        } label: {
            Label("To Instructions", systemImage: "book")
        }
        .buttonStyle(PrimaryActionButtonStyle())
        .disabled(disabled)
    }

    @MainActor
    private func completeAndLogEvent(_ event: Event) async {
        do {
            _ = try event.complete()
            do {
                let eventLogEntry = try EventLog(from: event, completionTime: Date())
                await standard.logCompletedEvent(eventLogEntry)
                self.appScheduler.viewState = .idle
            } catch {
                self.appScheduler.viewState = .error(
                    AnyLocalizedError(error: error, defaultErrorDescription: "Could not.")
                )
            }
        } catch {
            self.appScheduler.viewState = .error(
                AnyLocalizedError(error: error, defaultErrorDescription: "Failed.")
            )
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
