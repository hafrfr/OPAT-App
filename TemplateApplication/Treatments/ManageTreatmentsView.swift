import Spezi
import SpeziViews
import SwiftUI

struct ManageTreatmentsView: View {
    @Environment(TreatmentModel.self) private var treatmentModel
    @Environment(TreatmentModule.self) private var treatmentModule
    @Environment(\.dismiss) private var dismiss

    @State private var showingAddTreatmentSheet = false
    @State private var deleteState: ViewState = .idle

    var body: some View {
        PrimaryBackgroundView(title: "Manage Treatments") {
            List {
                ForEach(treatmentModel.treatments) { treatment in
                    TreatmentCardView(
                        treatment: treatment,
                        summary: scheduleSummary(for: treatment),
                        onDelete: {
                            deleteTreatmentViaModule(treatment: treatment)
                        }
                    )
                    .listRowInsets(EdgeInsets(
                        top: Layout.Spacing.small,
                        leading: 0,
                        bottom: Layout.Spacing.small,
                        trailing: 0
                    ))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .safeAreaInset(edge: .bottom) {
                Spacer().frame(height: Layout.Spacing.xLarge)
            }
        }
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


    private func deleteTreatmentViaModule(treatment: Treatment) { 
            
            deleteState = .processing // Set state to processing for UI feedback

            Task { @MainActor in // Ensure UI updates happen on the main actor
                let treatmentID = treatment.id // Capture id for logging
                print("ManageTreatmentsView: Requesting module to remove treatment \(treatmentID)...")
                
                // Call the module's method - it handles model removal, Firestore, and scheduling
                await treatmentModule.treatmentRemoved(treatment)
                
                print("ManageTreatmentsView: Module finished removal process for \(treatmentID).")

                await Task.yield()
                deleteState = .idle
                
                // Note: Error handling currently happens within the module (logging).
                // If you needed the View to show specific errors from deletion,
                // treatmentRemoved would need to be modified to throw errors.
            }
        }
    }
    private func scheduleSummary(for treatment: Treatment) -> String {
        let count = treatment.timesOfDay.count
        let times = treatment.timesOfDay
            .compactMap { time -> String? in
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .short
                var components = time
                components.year = 2000
                components.month = 1
                components.day = 1
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

    return NavigationStack {
        ManageTreatmentsView()
            .environment(treatmentModel)
            .environment(treatmentScheduler)
    }
}
#endif
