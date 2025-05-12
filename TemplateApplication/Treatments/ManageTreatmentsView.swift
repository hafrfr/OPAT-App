import SwiftUI
import Spezi
import SpeziViews

struct ManageTreatmentsView: View {
    @Environment(TreatmentModel.self) private var treatmentModel
    @Environment(TreatmentModule.self) private var treatmentModule

    @Environment(\.dismiss) private var dismiss // Use dismiss environment action

    @State private var showingAddTreatmentSheet = false
    @State private var deleteState: ViewState = .idle

    var body: some View {
        PrimaryBackgroundView(title: "Manage Treatments") {
            VStack {
                List {

                    ForEach(treatmentModel.treatments) { treatment in
                        TreatmentCardView(
                            treatment: treatment,
                            summary: scheduleSummary(for: treatment),
                            onDelete: {
                            
                                deleteTreatmentViaModule(treatment: treatment)
                            }
                        )
                        
                        .listRowInsets(EdgeInsets(top: Layout.Spacing.small, leading: 0, bottom: Layout.Spacing.small, trailing: 0))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    
                    // .onDelete(perform: deleteTreatments)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            
        }
        .toolbar { // Keep the toolbar attached to ManageTreatmentsView
             ToolbarItem(placement: .navigationBarTrailing) {
                 Button { showingAddTreatmentSheet = true } label: { Label("Add Treatment", systemImage: "plus") }
             }
        }
        .sheet(isPresented: $showingAddTreatmentSheet) {
            AddTreatmentSheet() // Assuming this view exists
        }
        .viewStateAlert(state: $deleteState) // Keep the alert for delete processing
    }

    // --- Function to delete a SINGLE treatment (called by the button's closure) ---
    private func deleteTreatmentViaModule(treatment: Treatment) { // <<< RENAMED FUNCTION
            // Optional: Implement a confirmation dialog here before proceeding.
            
            deleteState = .processing // Set state to processing for UI feedback

            Task { @MainActor in // Ensure UI updates happen on the main actor
                let treatmentID = treatment.id // Capture id for logging
                print("ManageTreatmentsView: Requesting module to remove treatment \(treatmentID)...")
                
                // Call the module's method - it handles model removal, Firestore, and scheduling
                await treatmentModule.treatmentRemoved(treatment)
                
                print("ManageTreatmentsView: Module finished removal process for \(treatmentID).")

                // Reset UI state after the module's async operations complete
                // Yielding might help ensure UI updates fully reflect the change
                await Task.yield()
                deleteState = .idle
                
                // Note: Error handling currently happens within the module (logging).
                // If you needed the View to show specific errors from deletion,
                // treatmentRemoved would need to be modified to throw errors.
            }
        }
    // --- End deleteTreatment function ---


    // REMOVED: deleteTreatments(at offsets: IndexSet) function is no longer needed

    /// Generates a summary string for the treatment schedule.
    private func scheduleSummary(for treatment: Treatment) -> String {
        let count = treatment.timesOfDay.count
        let times = treatment.timesOfDay
            .compactMap { time -> String? in
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .short
                var components = time
                components.year = 2000; components.month = 1; components.day = 1;
                guard let date = Calendar.current.date(from: components) else { return "??" }
                return dateFormatter.string(from: date)
            }
            .joined(separator: ", ")
        return "\(count) time\(count == 1 ? "" : "s") per day (\(times))"
    }
}

#if DEBUG
#Preview {
    let treatmentModel = TreatmentModel()
    let treatmentScheduler = TreatmentScheduler()
    treatmentModel.configure()

    return NavigationStack { // Wrap in NavigationStack for title/toolbar
        ManageTreatmentsView()
            .environment(treatmentModel)
            .environment(treatmentScheduler)
    }
}
#endif
