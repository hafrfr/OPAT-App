import SwiftUI
import SpeziHealthKit
import SpeziScheduler // For Event, Task, Schedule, EventContext, Occurrence, Outcome
import SpeziViews     // For ViewState
import HealthKit      // For HK Objects

// MARK: - Subviews for VitalsPreambleView

private struct InitialMessageSubView: View {
    var onFetchVitals: () -> Void
    @Binding var viewState: ViewState // To disable button during processing

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundColor(Color("PetroleumBlue")) // Ensure this color is in your assets
            Text("Let's Check Your Vitals")
                .font(.title2).fontWeight(.semibold)
            Text("We'll quickly fetch your latest health data before the questionnaire.")
                .font(.body).multilineTextAlignment(.center).foregroundColor(.secondary)
            Button(action: onFetchVitals, label: {
                Text("Fetch Vitals")
            })
            .buttonStyle(PreviewPrimaryActionButtonStyle())
            .disabled(viewState == .processing)
        }
    }
}

private struct FormatVitalRow: View {
    let label: String
    let data: HealthKitSnapshot.ValueWithUnit?

    var body: some View {
        HStack {
            Text("\(label):").fontWeight(.medium)
            Spacer()
            if let vitalData = data {
                let formatString = (label == "Heart Rate" || label.contains("BP")) ? "%.0f" : "%.1f"
                let unitDisplay = vitalData.unit.isEmpty && (label.contains("BP")) ? "mmHg" : vitalData.unit
                let unitString = unitDisplay.isEmpty && label == "Heart Rate" ? "bpm" : unitDisplay
                
                Text("\(String(format: formatString, vitalData.value)) \(unitString)")
                Text("(\(vitalData.date, style: .time))")
                    .font(.caption).foregroundColor(.gray)
            } else {
                Text("Not available").foregroundColor(.gray)
            }
        }
    }
}

private struct BloodPressureDisplayRow: View {
    let snapshot: HealthKitSnapshot

    var body: some View {
        if let systolic = snapshot.latestBloodPressureSystolic,
           let diastolic = snapshot.latestBloodPressureDiastolic {
            HStack {
                Text("Blood Pressure:").fontWeight(.medium)
                Spacer()
                let unit = systolic.unit.isEmpty ? "mmHg" : systolic.unit
                Text("\(String(format: "%.0f", systolic.value))/\(String(format: "%.0f", diastolic.value)) \(unit)")
                Text("(\(systolic.date, style: .time))")
                    .font(.caption).foregroundColor(.gray)
            }
        } else if snapshot.latestBloodPressureSystolic != nil {
            FormatVitalRow(label: "Systolic BP", data: snapshot.latestBloodPressureSystolic)
            HStack { Text("Diastolic BP:").fontWeight(.medium); Spacer(); Text("Not available").foregroundColor(.gray) }
        } else if snapshot.latestBloodPressureDiastolic != nil {
            HStack { Text("Systolic BP:").fontWeight(.medium); Spacer(); Text("Not available").foregroundColor(.gray) }
            FormatVitalRow(label: "Diastolic BP", data: snapshot.latestBloodPressureDiastolic)
        } else {
            HStack { Text("Blood Pressure:").fontWeight(.medium); Spacer(); Text("Not available").foregroundColor(.gray) }
        }
    }
}

private struct SuccessSubView: View {
    let snapshot: HealthKitSnapshot
    var onContinueToQuestionnaire: (HealthKitSnapshot?) -> Void
    @Binding var viewState: ViewState // To disable button
    @State private var internalShowSuccessAnimation = false // Animation state local to this subview

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                successIcon
                Text("Vitals Fetched!").font(.title2).fontWeight(.semibold)
                vitalDetails
                Text("This data can be saved with your questionnaire response.")
                    .font(.caption).foregroundColor(.secondary).multilineTextAlignment(.center)
                continueButton
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                internalShowSuccessAnimation = true
            }
        }
    }

    @ViewBuilder
    private var successIcon: some View {
        HStack {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60)).foregroundColor(.green)
                .scaleEffect(internalShowSuccessAnimation ? 1 : 0.5)
                .opacity(internalShowSuccessAnimation ? 1 : 0)
            Spacer()
        }.padding(.bottom)
    }

    @ViewBuilder
    private var vitalDetails: some View {
        VStack(alignment: .leading, spacing: 15) {
            FormatVitalRow(label: "Heart Rate", data: snapshot.latestHeartRate)
            FormatVitalRow(label: "Blood Oxygen (SpO2)", data: snapshot.latestBloodOxygen)
            FormatVitalRow(label: "Body Temperature", data: snapshot.latestBodyTemperature)
            BloodPressureDisplayRow(snapshot: snapshot)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
    }

    @ViewBuilder
    private var continueButton: some View {
        Button("Continue to Questions") { onContinueToQuestionnaire(snapshot) }
            .buttonStyle(PreviewPrimaryActionButtonStyle())
            .disabled(viewState == .processing)
    }
}

private struct ErrorSubView: View {
    let error: Error
    var onRetry: () -> Void
    var onContinueWithoutVitals: () -> Void
    @Binding var viewState: ViewState // To disable buttons

    var body: some View {
        let localizedError = error as? LocalizedError ?? AnyLocalizedError(
            error: error,
            defaultErrorDescription: "An unknown error occurred."
        )
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60)).foregroundColor(.orange)
            Text("Could Not Fetch Vitals").font(.title2).fontWeight(.semibold)
            Text("Error: \(localizedError.localizedDescription). You can still proceed.")
                .font(.body).multilineTextAlignment(.center).foregroundColor(.secondary)
            Button(action: onRetry, label: { Text("Retry") })
                .buttonStyle(PreviewPrimaryActionButtonStyle())
                .disabled(viewState == .processing)
            
            Button("Continue Without Vitals", action: onContinueWithoutVitals)
                .padding(.top, 5)
                .disabled(viewState == .processing)
        }
    }
}


// MARK: - Main View
struct VitalsPreambleView: View {
    let event: Event
    var onContinueToQuestionnaire: (HealthKitSnapshot?) -> Void

    @Environment(HealthKit.self) private var healthKit
    @Environment(\.dismiss) private var dismiss

    @State private var viewState: ViewState = .idle
    @State private var fetchedSnapshot: HealthKitSnapshot?
    // showSuccessAnimation is now managed by SuccessSubView

    private var queryTimeRange: HealthKitQueryTimeRange { .last(hours: 2) }

    var body: some View {
        NavigationView {
            mainContent
                .padding()
                .navigationTitle("Vitals Check")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { navigationToolbar }
                .task(id: viewState) {
                    if case .processing = viewState {
                        await fetchVitals()
                    }
                }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 20) {
            switch viewState {
            case .idle:
                idleStateView
            case .processing:
                ProgressView("Fetching your latest vitals...")
                    .padding()
            case .error(let error):
                ErrorSubView(
                    error: error,
                    onRetry: {
                        fetchedSnapshot = nil
                        viewState = .processing
                    },
                    onContinueWithoutVitals: { onContinueToQuestionnaire(nil) },
                    viewState: $viewState
                )
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var idleStateView: some View {
        if let snapshot = fetchedSnapshot {
            SuccessSubView(
                snapshot: snapshot,
                onContinueToQuestionnaire: onContinueToQuestionnaire,
                viewState: $viewState
            )
        } else {
            InitialMessageSubView(
                onFetchVitals: {
                    fetchedSnapshot = nil
                    viewState = .processing
                },
                viewState: $viewState
            )
        }
    }
    
    @ToolbarContentBuilder
    private var navigationToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if viewState != .processing {
                Button("Cancel") { dismiss() }
            }
        }
    }

    // MARK: - Data Fetching Logic (Remains in VitalsPreambleView)
    @MainActor
    private func fetchVitals(test: Bool = false) async {
        if test {
            setupMockSnapshotForTest()
            return
        }
        
        let collectionTime = Date()
        print("""
        VitalsPreambleView: fetchVitals() called. \
        Attempting to fetch HealthKit data for the last 2 hours from \(collectionTime)
        """)
        var snapshot = HealthKitSnapshot(collectionDate: collectionTime)
        
        do {
            snapshot.latestHeartRate = await fetchHeartRate(timeRange: queryTimeRange)
            snapshot.latestBloodOxygen = await fetchBloodOxygen(
                timeRange: queryTimeRange,
                mockDate: collectionTime
            )
            snapshot.latestBodyTemperature = await fetchBodyTemperature(
                timeRange: queryTimeRange,
                mockDate: collectionTime
            )
            
            let (systolic, diastolic) = await fetchBloodPressure(
                timeRange: queryTimeRange,
                mockDate: collectionTime
            )
            snapshot.latestBloodPressureSystolic = systolic
            snapshot.latestBloodPressureDiastolic = diastolic

            self.fetchedSnapshot = snapshot
            self.viewState = .idle
            print("""
            VitalsPreambleView: HealthKit data fetching attempt complete. \
            Snapshot (may include mock data): \(String(describing: self.fetchedSnapshot))
            """)
        } catch {
            print("ERROR: VitalsPreambleView - Failed to fetch HealthKit data: \(error.localizedDescription)")
            self.viewState = .error(
                AnyLocalizedError(
                    error: error,
                    defaultErrorDescription: "Could not fetch vitals. Please ensure HealthKit permissions are granted or try again later."
                )
            )
        }
    }

    private func setupMockSnapshotForTest() {
        var testSnapshot = HealthKitSnapshot(collectionDate: Date()) // Collection date is now
        let tenMinutesAgo = Date().addingTimeInterval(-10 * 60) // -10 minutes * 60 seconds/minute

        testSnapshot.latestHeartRate = .init(value: 75, unit: "bpm", date: tenMinutesAgo)
        testSnapshot.latestBloodOxygen = .init(value: 98, unit: "%", date: tenMinutesAgo)
        testSnapshot.latestBodyTemperature = .init(value: 36.6, unit: "°C", date: tenMinutesAgo)
        testSnapshot.latestBloodPressureSystolic = .init(value: 120, unit: "mmHg", date: tenMinutesAgo)
        testSnapshot.latestBloodPressureDiastolic = .init(value: 80, unit: "mmHg", date: tenMinutesAgo)
        self.fetchedSnapshot = testSnapshot
        self.viewState = .idle
    }

    private func fetchHeartRate(timeRange: HealthKitQueryTimeRange) async -> HealthKitSnapshot.ValueWithUnit? {
        do {
            let samples: [HKQuantitySample] = try await healthKit.query(.heartRate, timeRange: timeRange, limit: 1)
            if let latestSample = samples.first {
                return .init(
                    value: latestSample.quantity.doubleValue(for: .count().unitDivided(by: .minute())),
                    unit: "bpm",
                    date: latestSample.endDate
                )
            }
            print("VitalsPreambleView: No heart rate data found in HealthKit.")
            return nil
        } catch {
            print("VitalsPreambleView: Error fetching heart rate: \(error.localizedDescription)")
            return nil
        }
    }

    private func fetchBloodOxygen(
        timeRange: HealthKitQueryTimeRange,
        mockDate: Date
    ) async -> HealthKitSnapshot.ValueWithUnit? {
        let mock = HealthKitSnapshot.ValueWithUnit(value: 98, unit: "%", date: mockDate.addingTimeInterval(-360))
        do {
            let samples: [HKQuantitySample] = try await healthKit.query(.bloodOxygen, timeRange: timeRange, limit: 1)
            if let latestSample = samples.first {
                return .init(
                    value: latestSample.quantity.doubleValue(for: .percent()) * 100,
                    unit: "%",
                    date: latestSample.endDate
                )
            }
            print("VitalsPreambleView: No blood oxygen data. Using mock.")
            return mock
        } catch {
            print("VitalsPreambleView: Error fetching SpO2: \(error.localizedDescription). Using mock.")
            return mock
        }
    }

    private func fetchBodyTemperature(
        timeRange: HealthKitQueryTimeRange,
        mockDate: Date
    ) async -> HealthKitSnapshot.ValueWithUnit? {
        let mock = HealthKitSnapshot.ValueWithUnit(value: 36.6, unit: "°C", date: mockDate.addingTimeInterval(-420))
        do {
            let samples: [HKQuantitySample] = try await healthKit.query(.bodyTemperature, timeRange: timeRange, limit: 1)
            if let latestSample = samples.first {
                return .init(
                    value: latestSample.quantity.doubleValue(for: .degreeCelsius()),
                    unit: "°C",
                    date: latestSample.endDate
                )
            }
            print("VitalsPreambleView: No body temperature data. Using mock.")
            return mock
        } catch {
            print("VitalsPreambleView: Error fetching temperature: \(error.localizedDescription). Using mock.")
            return mock
        }
    }

    private func fetchBloodPressure(
        timeRange: HealthKitQueryTimeRange,
        mockDate: Date
    ) async -> (systolic: HealthKitSnapshot.ValueWithUnit?, diastolic: HealthKitSnapshot.ValueWithUnit?) {
        let mockSystolic = HealthKitSnapshot.ValueWithUnit(value: 118, unit: "mmHg", date: mockDate.addingTimeInterval(-480))
        let mockDiastolic = HealthKitSnapshot.ValueWithUnit(value: 78, unit: "mmHg", date: mockDate.addingTimeInterval(-480))

        do {
            // Use SpeziHealthKit.SampleType.bloodPressure directly
            let correlations: [HKCorrelation] = try await healthKit.query(
                SampleType.bloodPressure, // Corrected: Use SpeziHealthKit's SampleType
                timeRange: timeRange,
                limit: 1
            )

            var fetchedSystolic: HealthKitSnapshot.ValueWithUnit?
            var fetchedDiastolic: HealthKitSnapshot.ValueWithUnit?

            if let latestCorrelation = correlations.first {
                // When extracting objects from HKCorrelation, use the HKQuantityType directly.
                if let systolicHKType = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic),
                   let sample = latestCorrelation.objects(for: systolicHKType).first as? HKQuantitySample {
                    fetchedSystolic = .init(
                        value: sample.quantity.doubleValue(for: .millimeterOfMercury()),
                        unit: "mmHg",
                        date: sample.endDate
                    )
                }
                if let diastolicHKType = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic),
                   let sample = latestCorrelation.objects(for: diastolicHKType).first as? HKQuantitySample {
                    fetchedDiastolic = .init(
                        value: sample.quantity.doubleValue(for: .millimeterOfMercury()),
                        unit: "mmHg",
                        date: sample.endDate
                    )
                }
            }
            
            let systolicToUse = fetchedSystolic ?? mockSystolic
            let diastolicToUse = fetchedDiastolic ?? mockDiastolic

            if fetchedSystolic == nil { print("VitalsPreambleView: No systolic BP data. Using mock.") }
            if fetchedDiastolic == nil { print("VitalsPreambleView: No diastolic BP data. Using mock.") }
            if correlations.isEmpty && fetchedSystolic == nil && fetchedDiastolic == nil {
                 print("VitalsPreambleView: No BP correlation. Using mock for both.")
            }
            return (systolicToUse, diastolicToUse)
        } catch {
            print("VitalsPreambleView: Error fetching blood pressure: \(error.localizedDescription). Using mock data.")
            return (mockSystolic, mockDiastolic)
        }
    }
}

// MARK: - Helper Structs (Remain the same)
struct AnyLocalizedError: LocalizedError {
    var errorDescription: String?
    init(error: Error, defaultErrorDescription: String) {
        self.errorDescription = (error as? LocalizedError)?.errorDescription ?? defaultErrorDescription
    }
}
struct PreviewPrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
