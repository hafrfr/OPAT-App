// TemplateApplication/UI/Schedule/VitalsPreambleView.swift
// View to collect and display HealthKit vitals before proceeding to a questionnaire.
// Aligned task handling with OPATScheduleView pattern using .task(id: viewState).
// Corrected Preview block.

import SwiftUI
import SpeziHealthKit
import SpeziScheduler // For Event, Task, Schedule, EventContext, Occurrence, Outcome
import SpeziViews    // For ViewState
import HealthKit     // For HK Objects

struct VitalsPreambleView: View {
    let event: Event
    var onContinueToQuestionnaire: (HealthKitSnapshot?) -> Void

    @Environment(HealthKit.self) private var healthKit
    @Environment(\.dismiss) private var dismiss

    @State private var viewState: ViewState = .idle
    @State private var fetchedSnapshot: HealthKitSnapshot?
    @State private var showSuccessAnimation = false

    private var queryTimeRange: HealthKitQueryTimeRange { .last(hours: 2) }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                switch viewState {
                case .idle:
                    if let snapshot = fetchedSnapshot {
                        successView(snapshot: snapshot)
                    } else {
                        initialMessageView()
                    }
                case .processing:
                    ProgressView("Fetching your latest vitals...")
                        .padding()
                case .error(let error):
                    errorView(error: error)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Vitals Check")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewState != .processing {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
            .task(id: viewState) {
                // Only fetch if the state was set to .processing
                if case .processing = viewState {
                    await fetchVitals()
                }
            }
            // .viewStateAlert(state: $viewState) // Optionally add for modal error alerts
        }
    }

    @ViewBuilder
    private func initialMessageView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundColor(Color("PetroleumBlue")) // Ensure this color is in your assets
            Text("Let's Check Your Vitals")
                .font(.title2).fontWeight(.semibold)
            Text("We'll quickly fetch your latest health data before the questionnaire.")
                .font(.body).multilineTextAlignment(.center).foregroundColor(.secondary)
            Button(action: {
                // Action: Set viewState to .processing to trigger the .task modifier.
                fetchedSnapshot = nil // Clear previous snapshot if any
                viewState = .processing
            }, label: {
                Text("Fetch Vitals")
            })
            .buttonStyle(PreviewPrimaryActionButtonStyle())
            .disabled(viewState == .processing)
        }
    }

    @ViewBuilder
    private func successView(snapshot: HealthKitSnapshot) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60)).foregroundColor(.green)
                        .scaleEffect(showSuccessAnimation ? 1 : 0.5)
                        .opacity(showSuccessAnimation ? 1 : 0)
                    Spacer()
                }.padding(.bottom)

                Text("Vitals Fetched!").font(.title2).fontWeight(.semibold)

                VStack(alignment: .leading, spacing: 15) {
                    formatVital(label: "Heart Rate", data: snapshot.latestHeartRate)
                    formatVital(label: "Blood Oxygen (SpO2)", data: snapshot.latestBloodOxygen)
                    formatVital(label: "Body Temperature", data: snapshot.latestBodyTemperature)
                }
                .padding().background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
                
                Text("This data can be saved with your questionnaire response.")
                    .font(.caption).foregroundColor(.secondary).multilineTextAlignment(.center)

                Button("Continue to Questions") { onContinueToQuestionnaire(snapshot) }
                    .buttonStyle(PreviewPrimaryActionButtonStyle())
                    .disabled(viewState == .processing)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                showSuccessAnimation = true
            }
        }
    }
    
    @ViewBuilder
    private func formatVital(label: String, data: HealthKitSnapshot.ValueWithUnit?) -> some View {
        HStack {
            Text("\(label):").fontWeight(.medium)
            Spacer()
            if let vitalData = data {
                Text("\(String(format: "%.1f", vitalData.value)) \(vitalData.unit)")
                Text("(\(vitalData.date, style: .time))")
                    .font(.caption).foregroundColor(.gray)
            } else {
                Text("Not available").foregroundColor(.gray)
            }
        }
    }

    @ViewBuilder
    private func errorView(error: Error) -> some View {
        let localizedError = error as? LocalizedError ?? AnyLocalizedError(error: error, defaultErrorDescription: "An unknown error occurred.")
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60)).foregroundColor(.orange)
            Text("Could Not Fetch Vitals").font(.title2).fontWeight(.semibold)
            Text("Error: \(localizedError.localizedDescription). You can still proceed.")
                .font(.body).multilineTextAlignment(.center).foregroundColor(.secondary)
            Button(action: {
                fetchedSnapshot = nil
                viewState = .processing
            }, label: {
                Text("Retry")
            })
            .buttonStyle(PreviewPrimaryActionButtonStyle())
            .disabled(viewState == .processing)
            
            Button("Continue Without Vitals") { onContinueToQuestionnaire(nil) }
                .padding(.top, 5)
                .disabled(viewState == .processing)
        }
    }

    @MainActor
    private func fetchVitals(test: Bool = false) async {
        if(test) {
            showSuccessAnimation = false
        }
        else{
            
            showSuccessAnimation = false
            
            let collectionTime = Date()
            print("VitalsPreambleView: fetchVitals() called. Attempting to fetch HealthKit data for the last 2 hours from \(collectionTime)")
            var snapshot = HealthKitSnapshot(collectionDate: collectionTime)
            
            let timeRangeToQuery = HealthKitQueryTimeRange.last(hours: 2)
            
            do {
                let heartRateType = SampleType.heartRate
                let heartRateSamples: [HKQuantitySample] = try await healthKit.query(
                    heartRateType, timeRange: timeRangeToQuery, limit: 1
                )
                if let latestSample = heartRateSamples.first{
                    snapshot.latestHeartRate = .init(
                        value: latestSample.quantity.doubleValue(for: .count().unitDivided(by: .minute())),
                        unit: "bpm",
                        date: latestSample.endDate)
                }
                
                let bloodOxygenType = SampleType.bloodOxygen
                let bloodOxygenSamples: [HKQuantitySample] = try await healthKit.query(
                    bloodOxygenType, timeRange: timeRangeToQuery, limit: 1
                )
                if let latestSample = bloodOxygenSamples.first {
                    snapshot.latestBloodOxygen = .init(
                        value: latestSample.quantity.doubleValue(for: .percent()) * 100,
                        unit: "%",
                        date: latestSample.endDate)
                }
                
                let bodyTemperatureType = SampleType.bodyTemperature
                let bodyTempSamples: [HKQuantitySample] = try await healthKit.query(
                    bodyTemperatureType, timeRange: timeRangeToQuery, limit: 1
                )
                if let latestSample = bodyTempSamples.first{
                    snapshot.latestBodyTemperature = .init(
                        value: latestSample.quantity.doubleValue(
                            for: .degreeCelsius()),
                        unit: "°C",
                        date: latestSample.endDate)
                }
                
                self.fetchedSnapshot = snapshot
                self.viewState = .idle // On success, set to .idle; successView will be shown
                print("VitalsPreambleView: HealthKit data fetching complete. Snapshot: \(String(describing: self.fetchedSnapshot))")
                
            } catch {
                print("ERROR: VitalsPreambleView - Failed to fetch HealthKit data: \(error.localizedDescription)")
                self.viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription:
                                                            "Could not fetch vitals. (This will be available in a later version)"))
            }
        }
    }
}

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
