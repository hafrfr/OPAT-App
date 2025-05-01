@_spi(TestingSupport) import SpeziAccount
import SpeziScheduler
import SpeziSchedulerUI
import SpeziViews
import SwiftUI


struct OPATScheduleViewStyled: View {
    @Environment(Account.self) private var account: Account?
    @Environment(TemplateApplicationScheduler.self) private var appScheduler: TemplateApplicationScheduler
    @Environment(TreatmentModel.self) private var treatmentModel
    @Environment(TreatmentScheduler.self) private var treatmentScheduler

    @State private var presentedEvent: Event?
    @Binding private var presentingAccount: Bool

    var body: some View {
        @Bindable var appScheduler = appScheduler

        NavigationStack {
            PrimaryBackgroundView(title: "Schedule") {
                VStack(spacing: Layout.Spacing.medium) {
                    EventScheduleList(date: .today) { event in
                        InstructionsTile(event) {
                            actionButton(for: event)
                        }
                        .padding()
                        .background(ColorTheme.listItemBackground)
                        .cornerRadius(Layout.Radius.medium)
                        .shadowStyle(ShadowTheme.card)
                        .listRowInsets(
                            EdgeInsets(
                                top: Layout.Spacing.small,
                                leading: 0,
                                bottom: Layout.Spacing.small,
                                trailing: 0
                            )
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
            .viewStateAlert(state: $appScheduler.viewState)
            .sheet(item: $presentedEvent) { event in
                EventView(event)
            }
            .toolbar {
                toolbarContent
            }
        }
    }

    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if account != nil {
                AccountButton(isPresented: $presentingAccount)
            } else {
                NavigationLink {
                    ManageTreatmentsView()
                } label: {
                    Label("Manage Treatments", systemImage: "list.bullet.clipboard")
                        .font(FontTheme.body)
                        .foregroundColor(ColorTheme.title)
                }
            }
        }
    }

    @ViewBuilder
    private func actionButton(for event: Event) -> some View {
        let isDisabled = event.isCompleted

        if event.task.id.starts(with: "treatment-") {
            HStack(spacing: Layout.Spacing.medium) {
                Button("Mark Complete") {
                    completeTreatmentTask(event)
                }
                .font(FontTheme.button)
                .foregroundColor(.white)
                .padding(.vertical, Layout.Spacing.medium)
                .padding(.horizontal, Layout.Spacing.large)
                .background(ColorTheme.buttonLarge)
                .cornerRadius(Layout.Radius.medium)
                .disabled(isDisabled)

                Spacer()

                Button("To Instructions") {
                    // Placeholder
                }
                .font(FontTheme.button)
                .foregroundColor(.white)
                .padding(.vertical, Layout.Spacing.medium)
                .padding(.horizontal, Layout.Spacing.large)
                .background(ColorTheme.buttonLarge)
                .cornerRadius(Layout.Radius.medium)
                .disabled(isDisabled)
            }
        } else if event.task.id == "opat-checkin" {
            Button("Start") {
                presentedEvent = event
            }
            .font(FontTheme.button)
            .foregroundColor(.white)
            .padding(.vertical, Layout.Spacing.medium)
            .padding(.horizontal, Layout.Spacing.large)
            .background(ColorTheme.buttonLarge)
            .cornerRadius(Layout.Radius.medium)
            .disabled(isDisabled)
        } else {
            Text("Unknown Task")
                .font(FontTheme.body)
                .foregroundColor(.gray)
                .padding(.horizontal, Layout.Spacing.small)
        }
    }

    private func completeTreatmentTask(_ event: Event) {
        do {
            try event.complete()
            print("Marked event \(event.task.id) as complete.")
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
