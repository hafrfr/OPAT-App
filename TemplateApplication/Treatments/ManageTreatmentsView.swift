import SwiftUI
import Spezi
import SpeziViews


struct ManageTreatmentsView: View {
    @Environment(TreatmentModel.self) private var treatmentModel
    @Environment(TreatmentScheduler.self) private var treatmentScheduler
    //@Environment(TreatmentNotifications.self) private var treatmentNotifier
    
    // Controls the "Add Treatment" sheet presentation
    @State private var showingAddTreatmentSheet = false
 
    @State private var deleteState: ViewState = .idle

    var body: some View {
        NavigationStack {
            List {
                ForEach(treatmentModel.treatments) { treatment in
                    TreatmentCardView(treatment: treatment, summary: scheduleSummary(for: treatment))
                }
                .onDelete(perform: deleteTreatments)
            }
            .navigationTitle("Manage Treatments")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTreatmentSheet = true
                    } label: {
                        Label("Add Treatment", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTreatmentSheet) {
                AddTreatmentSheet()

                    
            }
            .viewStateAlert(state: $deleteState)
        }
    }

    /// Deletes selected treatments: removes scheduled tasks then updates the model
    private func deleteTreatments(at offsets: IndexSet) {
        let scheduler = self.treatmentScheduler
        let model = self.treatmentModel
        Task { @MainActor in
                    deleteState = .processing
                    for index in offsets {

                        guard index < model.treatments.endIndex else { continue }
                        let treatment = model.treatments[index]

                        await scheduler.remove(treatment)

                        model.treatments.removeAll { $0.id == treatment.id }

                    }
                    deleteState = .idle
        }
    }

    private func scheduleSummary(for treatment: Treatment) -> String {
        let count = treatment.timesOfDay.count
        let times = treatment.timesOfDay
            .compactMap { time in
                guard let hour = time.hour, let min = time.minute else { return nil }
                return String(format: "%02d:%02d", hour, min)
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
            // 2. Inject the environment objects
            .environment(treatmentModel)
            .environment(treatmentScheduler)
    }
}
#endif
