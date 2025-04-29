@_spi(TestingSupport) import SpeziAccount
import SpeziScheduler // Ensure Scheduler is available for event completion
import SpeziSchedulerUI
import SpeziViews
import SwiftUI


struct OPATScheduleViewStyled: View {
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

            // --- Add NavigationStack back ---
            NavigationStack { // <-- ADDED: Provides context for the 
                PrimaryBackgroundView(title: "Schedule") { // Title
                    VStack {
                        EventScheduleList(date: .today) { event in
                            InstructionsTile(event) {
                                actionButton(for: event)
                            }
                            // --- Row Styling & Modifiers ---
                            .padding()
                            .background(ColorTheme.listItemBackground)
                            .cornerRadius(Layout.Radius.medium)
                            .shadowStyle(ShadowTheme.card)
                            .listRowInsets(EdgeInsets(top: Layout.Spacing.small, leading: 0, bottom: Layout.Spacing.small, trailing: 0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            // -----------------------------
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    }
                     // .padding(.horizontal) // Optional padding for VStack content
                }
                // Apply modifiers to the content INSIDE NavigationStack but OUTSIDE PrimaryBackgroundView
                .viewStateAlert(state: $appScheduler.viewState)
                .sheet(item: $presentedEvent) { event in EventView(event) }
                .toolbar { toolbarContent } // Toolbar attached here works because of NavigationStack

                // Note: .navigationTitle is NOT needed here as PrimaryBackgroundView shows title
            } // --- End NavigationStack ---
        }

    // MARK: - Initialization
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
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
                        }
                        .buttonStyle(.bordered).disabled(isDisabled)

                    }
        } else if event.task.id == "opat-followup" {
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


    OPATScheduleViewStyled(presentingAccount: $presentingAccount)
        .previewWith(standard: TemplateApplicationStandard()) {
            Scheduler() // The actual scheduler module
            TemplateApplicationScheduler() // Your app-specific scheduler logic
            TreatmentModel()
            TreatmentScheduler()
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
