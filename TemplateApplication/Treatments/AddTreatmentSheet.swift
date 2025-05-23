import SwiftUI
import Spezi
import SpeziViews
import SpeziScheduler
import SpeziNotifications

struct AddTreatmentSheet: View {
    // MARK: Environment
    @Environment(TreatmentModel.self) private var treatmentModel
    @Environment(TreatmentScheduler.self) private var treatmentScheduler
    @Environment(\.dismiss) var dismiss
    @Environment(TreatmentModule.self) private var treatmentModule

    // MARK: State Variables for Form Input
    @State private var selectedType: TreatmentType = .opat
    @State private var times: [Date] = [
        Calendar.current.date(
            bySettingHour: 8, minute: 0, second: 0, of: .now
        )!
    ]
    @State private var startDate: Date = .now
    @State private var endDateEnabled = false
    @State private var endDate: Date = Calendar.current.date(
        byAdding: .day, value: 7, to: .now
    )!
    // MARK: – Save flow
    @State private var saveState: ViewState = .idle
    @State private var triggerSave = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                treatmentDetailsSection
                scheduledTimesSection
                durationSection
            }
            .navigationTitle("Add Treatment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .viewStateAlert(state: $saveState)
            // --- Attach .task modifier here ---
            // This task runs whenever 'triggerSave' becomes true.
            .task(id: triggerSave) { // Use the boolean state as the ID
                 // Only proceed if triggerSave was set to true
                 guard triggerSave else { return }

                 // Perform the save operation
                await saveTreatmentViaModule()
                 // Reset the trigger AFTER the task is done or has failed
                 // This prevents the task from restarting immediately.
                 // Important: Do this regardless of success/failure of the save operation.
                 triggerSave = false
             }
             // --- End .task modifier ---
        }
    }

    // MARK: – Form sections

    private var treatmentDetailsSection: some View {
        Section("Treatment Details") {
            Picker("Type", selection: $selectedType) {
                ForEach(TreatmentType.allCases) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var scheduledTimesSection: some View {
        Section("Scheduled Times") {
            // Using enumerated() requires careful index management if elements are removed.
            // Using $times.indices is often safer with onDelete. Let's revert if needed.
            ForEach($times.indices, id: \.self) { index in
                 DatePicker("Treatment time:  \(index + 1)", selection: $times[index], displayedComponents: .hourAndMinute)
                     .datePickerStyle(.compact)
            }
            .onDelete { offsets in
                times.remove(atOffsets: offsets)
            }

            Button {
                let next = Calendar.current.date(
                    bySettingHour: 12, minute: 0, second: 0, of: .now
                )!
                times.append(next)
                times.sort()
            } label: {
                Label("Add Time", systemImage: "plus.circle.fill")
            }
        }
    }

    private var durationSection: some View {
        Section("Duration") {
            DatePicker(
                "Start Date",
                selection: $startDate,
                displayedComponents: .date
            )

            Toggle("Set End Date", isOn: $endDateEnabled.animation())

            if endDateEnabled {
                DatePicker(
                    "End Date",
                    selection: $endDate,
                    in: startDate...,
                    displayedComponents: .date
                )
            }
        }
    }

    // MARK: – Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            DismissButton()
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Save") {
                // --- Action now just sets the trigger state ---
                // Set processing state immediately for UI feedback
                saveState = .processing
                // Trigger the .task modifier
                triggerSave = true
                // --- End Change ---
            }
            // Disable button if saving is in progress (via saveState) OR if task is triggered
            .disabled(saveState == .processing || triggerSave || times.isEmpty)
        }
    }

    // MARK: – Save & Schedule

    @MainActor
       private func saveTreatmentViaModule() async { // <<< RENAMED FUNCTION
           // 1. Create the treatment object from state
           // Ensure times are not empty before proceeding (button disable helps, but double-check)
           guard !times.isEmpty else {
                print("AddTreatmentSheet: Cannot save treatment with no scheduled times.")
                // triggerSave is reset by the .task modifier
                return
           }

           let comps = times.map {
               Calendar.current.dateComponents([.hour, .minute], from: $0)
           }
           // Create with a unique ID
           let newTreatment = Treatment(
               id: UUID(),
               type: selectedType,
               timesOfDay: comps,
               startDate: startDate,
               endDate: endDateEnabled ? endDate : nil
           )
           print("AddTreatmentSheet: Created new treatment object: \(newTreatment.id)")

           do {               try await treatmentModule.treatmentAdded(newTreatment)
               print("AddTreatmentSheet: TreatmentModule successfully processed treatment \(newTreatment.id).")
               
               saveState = .idle
               dismiss()

           } catch {
               print("AddTreatmentSheet: Error adding treatment via module \(newTreatment.id): \(error)")
 
               saveState = .error(
                   AnyLocalizedError(
                       error: error,
                       defaultErrorDescription: "Failed to save or schedule the new treatment. Please try again."
                   )
               )
               // triggerSave is reset by the .task modifier closure itself
           }
       }
   }



#if DEBUG
#Preview {
    // 1. Create instances
    let treatmentModel = TreatmentModel()
    let treatmentScheduler = TreatmentScheduler()


    treatmentModel.configure()

    treatmentModel.treatments.append(
         Treatment(
             type: .painMed,
             timesOfDay: [.init(hour: 20, minute: 0)],
             startDate: .now.addingTimeInterval(-86400 * 3)
         )
    )
     treatmentModel.treatments.append(
         Treatment(
             type: .other,
             timesOfDay: [.init(hour: 6, minute: 15), .init(hour: 12, minute: 15), .init(hour: 18, minute: 15), .init(hour: 23, minute: 55)],
             startDate: .now.addingTimeInterval(86400 * 2)
         )
    )

    return NavigationStack { // Wrap preview in NavigationStack if ManageTreatmentsView is typically used within one
        ManageTreatmentsView()
            .environment(treatmentModel)
            .environment(treatmentScheduler)
    }
}
#endif
