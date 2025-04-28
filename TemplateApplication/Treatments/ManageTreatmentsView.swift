import SwiftUI
import Spezi
import SpeziViews

struct ManageTreatmentsView: View {
    @Environment(TreatmentModel.self) private var treatmentModel
    @Environment(TreatmentScheduler.self) private var treatmentScheduler
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
                            
                                deleteTreatment(treatment: treatment)
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
             ToolbarItem(placement: .navigationBarLeading) {
                  Button("Done") { dismiss() } // Assuming this view might be presented modally
             }
        }
        .sheet(isPresented: $showingAddTreatmentSheet) {
            AddTreatmentSheet() // Assuming this view exists
        }
        .viewStateAlert(state: $deleteState) // Keep the alert for delete processing
    }

    // --- Function to delete a SINGLE treatment (called by the button's closure) ---
    private func deleteTreatment(treatment: Treatment) {
        // Capture environment objects safely for the background Task
        let scheduler = self.treatmentScheduler
        let model = self.treatmentModel
        Task { @MainActor in
            guard model.treatments.contains(where: { $0.id == treatment.id }) else {
                 print("Attempted to delete already removed treatment: \(treatment.id)")
                 return
            }

            deleteState = .processing // Show processing state
            print("Attempting to delete treatment via button: \(treatment.id)")

            await scheduler.remove(treatment) // Remove scheduled tasks first

            // Remove the treatment from the @Published array in the model
            // This should automatically trigger a UI update in the List
            model.treatments.removeAll { $0.id == treatment.id }
            print("Removed treatment from model: \(treatment.id)")

            // Yield to allow UI updates if needed, then reset state
            await Task.yield()
            deleteState = .idle // Hide processing state
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
