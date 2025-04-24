// SpeziTemplateApplication/TemplateApplication/Instructions/InstructionStepOverviewView.swift
// (Removed Chevrons, Simplified Header Confirmed)

import SwiftUI

struct InstructionStepOverviewView: View {
    let guideInfo: InstructionGuideInfo
    @Binding var navigationPath: NavigationPath
    var onGetStarted: () -> Void

    private var stepTitles: [String] { guideInfo.steps.map { $0.title } }

    var body: some View {
        VStack {
            // --- List of Step Titles ---
            List {
                // Section provides grouping like the mockup visually
                Section("Steps") { // Optional section header
                    ForEach(stepTitles.indices, id: \.self) { index in
                        // Removed HStack, Spacer, and chevron Image
                        Text(stepTitles[index])
                           .padding(.vertical, 4) // Add some padding to the text row
                    }
                } // End Section
            }
            .listStyle(.insetGrouped) // insetGrouped looks good with section headers

            // --- Get Started Button ---
             Button("Go to CheckList") {
                 print("[Overview] Get Started Tapped")
                 onGetStarted()
             }
             .buttonStyle(.borderedProminent)
             .padding()
        }
        // --- Use Standard Navigation Title (Handles Fitting) ---
        .navigationTitle(guideInfo.title) // Displays the overall guide title
        // Ensure previous changes removing .navigationBarHidden were kept
    }
}

#Preview {
    // Preview needs NavigationStack and dummy data/binding
    NavigationStack {
        InstructionStepOverviewView(
            guideInfo: InstructionGuideDataSource.loadGuides().first!,
            navigationPath: .constant(NavigationPath()),
            onGetStarted: { print("Preview Get Started") }
        )
    }
}
