import SwiftUI
@_spi(TestingSupport) import SpeziAccount
import SpeziScheduler    // Ensure Scheduler is available for event completion
import SpeziSchedulerUI
import SpeziViews

struct OPATScheduleViewStyled: View {
    // MARK: - Static Date Range Helper
    private static var todayRange: Range<Date> {
        let start = Calendar.current.startOfDay(for: .now)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        return start..<end
    }

    // MARK: - Environment Modules
    @Environment(Account.self) private var account: Account?
    @Environment(TemplateApplicationScheduler.self) private var appScheduler: TemplateApplicationScheduler
    @Environment(TreatmentModel.self) private var treatmentModel
    @Environment(TreatmentScheduler.self) private var treatmentScheduler

    // MARK: - Query Today’s Events
    @EventQuery(in: Self.todayRange) private var todaysEvents: [Event]

    // MARK: - View State
    @State private var presentedEvent: Event?    // For presenting questionnaires
    @Binding private var presentingAccount: Bool // For account sheet

    // MARK: - Progress State
    @State private var completedTaskCount: Int = 0
    @State private var totalTaskCount: Int     = 0

    var body: some View {
        NavigationStack {
            // Attach an .id to force view refresh when completedTaskCount changes
            PrimaryBackgroundView(title: "Schedule") {
                VStack(spacing: Layout.Spacing.medium) {
                    if totalTaskCount > 0 {
                        TreatmentProgressBar(
                            completedCount: completedTaskCount,
                            totalCount:     totalTaskCount
                        )
                        .padding(.horizontal)
                        .id(completedTaskCount)
                    }

                    EventScheduleList(date: .today) { event in
                        eventRow(event)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
                .onAppear {
                    // Initialize progress counts
                    totalTaskCount = todaysEvents.count
                    completedTaskCount = todaysEvents.filter { $0.isCompleted }.count
                }
            }
            .id(completedTaskCount) // Ensures PrimaryBackgroundView reloads
            .toolbar { toolbarContent }
            .sheet(item: $presentedEvent) { EventView($0) }
            .viewStateAlert(state: Binding(
                get: { appScheduler.viewState },
                set: { appScheduler.viewState = $0 }
            ))
        }
    }

    // MARK: - Extracted Row Builder
    @ViewBuilder
    private func eventRow(_ event: Event) -> some View {
        InstructionsTile(event) {
            actionButton(for: event)
        }
        .padding()
        .background(ColorTheme.listItemBackground)
        .cornerRadius(Layout.Radius.medium)
        .shadowStyle(ShadowTheme.card)
        .listRowInsets(EdgeInsets(
            top: Layout.Spacing.small,
            leading: 0,
            bottom: Layout.Spacing.small,
            trailing: 0
        ))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }

    // MARK: - Toolbar Content
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if account != nil {
                AccountButton(isPresented: $presentingAccount)
            } else {
                NavigationLink(
                    destination: ManageTreatmentsView()
                ) {
                    Label("Manage Treatments", systemImage: "list.bullet.clipboard")
                        .font(FontTheme.body)
                        .foregroundColor(ColorTheme.title)
                }
            }
        }
    }

    // MARK: - Action Button Builder
    @ViewBuilder
    private func actionButton(for event: Event) -> some View {
        let disabled = event.isCompleted
        if event.task.id.starts(with: "treatment-") {
            HStack {
                EventActionButton(event: event, "Mark Complete") {
                    completeTreatmentTask(event)
                }
                .disabled(disabled)
                Spacer()
                Button("To Instructions") {
                    // TODO: navigate
                }
                .buttonStyle(.bordered)
                .disabled(disabled)
            }
        } else if event.task.id == "opat-followup" {
            EventActionButton(event: event, "Start") {
                presentedEvent = event
            }
            .disabled(disabled)
        } else {
            Text("Unknown Task")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal, Layout.Spacing.small)
        }
    }

    // MARK: - Completion Handler
    private func completeTreatmentTask(_ event: Event) {
        do {
            try event.complete()
            // Manually increment and trigger refresh
            completedTaskCount += 1
        } catch {
            print("Error completing event \(event.task.id): \(error)")
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var presentingAccount = false
    OPATScheduleViewStyled(presentingAccount: $presentingAccount)
        .previewWith(standard: TemplateApplicationStandard()) {
            Scheduler()
            TemplateApplicationScheduler()
            TreatmentModel()
            TreatmentScheduler()
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
