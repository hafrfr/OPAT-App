// SpeziTemplateApplication/TemplateApplication/Instructions/InstructionsListView.swift
// (Complete File - Ensure Consistency)

import SwiftUI

// MARK: - Navigation Target Structs
// Ensure these definitions are exactly as follows within this file or accessible globally

struct OverviewNavigationTarget: Hashable {
    let guideInfo: InstructionGuideInfo // Contains the full guide info
}

struct ChecklistNavigationTarget: Hashable {
    let guideInfo: InstructionGuideInfo // Contains the full guide info
}

struct GuideNavigationTarget: Hashable {
    let guideTitle: String // Specific title for comparison
    let steps: [InstructionStep] // Specific steps for the final view
}

// MARK: - Main View

struct InstructionsListView: View {
    // MARK: State Variables
    // Load data source - If this causes issues, try initializing with an empty array first
    // and loading in .onAppear for debugging.
    @State private var availableGuides: [InstructionGuideInfo] = InstructionGuideDataSource.loadGuides()
    @State private var navigationPath = NavigationPath()

    // MARK: - Body
    var body: some View {
        NavigationStack(path: $navigationPath) {
            // Use the computed property for the list view
            guideList
            .navigationTitle("Instructions")
            // Define navigation destinations using the helper functions
            .navigationDestination(for: OverviewNavigationTarget.self, destination: overviewDestination)
            .navigationDestination(for: ChecklistNavigationTarget.self, destination: checklistDestination)
            .navigationDestination(for: GuideNavigationTarget.self, destination: guideDestination)
            // Optional: Monitor path changes for debugging
            .onChange(of: navigationPath) { _, newPath in
                 print("[Nav] Path changed. Count: \(newPath.count)")
            }
        }
    }

    // MARK: - Private Computed Views

    // Builds the list of guides
    private var guideList: some View {
         List(availableGuides) { guideInfo in
             // This NavigationLink pushes OverviewNavigationTarget when tapped
             NavigationLink(value: OverviewNavigationTarget(guideInfo: guideInfo)) {
                 HStack(spacing: 15) {
                     // Ensure guideInfo.iconName exists in Assets
                     Image(guideInfo.iconName)
                         .resizable().scaledToFit().frame(width: 60, height: 60)
                     // Ensure guideInfo.title is a valid String
                     Text(guideInfo.title)
                 }
             }
         }
    }

    // MARK: - Navigation Destination Builder Functions

    // Destination 1: Builds the Step Overview View
    private func overviewDestination(target: OverviewNavigationTarget) -> some View {
         InstructionStepOverviewView(
            // Pass the guideInfo from the target
            guideInfo: target.guideInfo,
            // Pass the navigationPath binding
            navigationPath: $navigationPath
         ) {
            // onGetStarted closure appends the next target
            navigationPath.append(ChecklistNavigationTarget(guideInfo: target.guideInfo))
            print("[Nav] Appended Checklist Target")
         }
    }

    // Destination 2: Builds the Supplies Checklist View
    private func checklistDestination(target: ChecklistNavigationTarget) -> some View {
         SuppliesChecklistView(
            // Pass checklist items from the target's guideInfo
            items: target.guideInfo.checklistItems,
            // Pass the navigationPath binding
            navigationPath: $navigationPath
         ) {
            // onComplete closure appends the next target
            navigationPath.append(
                GuideNavigationTarget(
                    guideTitle: target.guideInfo.title,
                    steps: target.guideInfo.steps
                )
            )
            print("[Nav] Appended Guide Target")
         }
    }

    // Destination 3: Builds the final Instruction Guide View

        private func guideDestination(target: GuideNavigationTarget) -> some View {
             Group {
                 if target.guideTitle == "OPAT Self-Administration Guide" {
                     OpatInstructionView(steps: target.steps, navigationPath: $navigationPath) // Pass binding
                 } else {
                     Text("Details for \(target.guideTitle)")
                 }
             }
        }
} // End Struct InstructionsListView

#Preview {
    // Ensure preview works, might need dummy data source setup if needed
    InstructionsListView()
}
