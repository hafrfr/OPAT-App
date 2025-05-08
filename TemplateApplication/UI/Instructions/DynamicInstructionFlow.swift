// File: TemplateApplication/UI/Instructions/DynamicInstructionFlow.swift (Corrected Again)
import Foundation
import SwiftUI

struct DynamicInstructionFlow: View {
    let guide: Guide
    @Environment(\.dismiss) private var dismiss

    @State private var currentMainStepIndex: Int
    @State private var currentSubStepIndex: Int
    @State private var navigateToCelebration = false

    // Initializer (Looks OK, includes validation)
    init(guide: Guide, startMainStepIndex: Int = 0, startSubStepIndex: Int = 0) {
        self.guide = guide
        var validatedMainIndex = startMainStepIndex
        var validatedSubIndex = startSubStepIndex

        // Validation logic
        if startMainStepIndex >= guide.steps.count || startMainStepIndex < 0 {
            print("⚠️ Warning: Invalid startMainStepIndex (\(startMainStepIndex)) passed to DynamicInstructionFlow. Resetting to 0.")
            validatedMainIndex = 0
            validatedSubIndex = 0
        } else if guide.steps.indices.contains(validatedMainIndex) && // Check main index before accessing substeps
                  (startSubStepIndex >= guide.steps[validatedMainIndex].substeps.count || startSubStepIndex < 0) {
            print("⚠️ Warning: Invalid startSubStepIndex (\(startSubStepIndex)) for main step \(validatedMainIndex) passed to DynamicInstructionFlow. Resetting to 0.")
            validatedSubIndex = 0
        }

        // Initialize state with validated values
        self._currentMainStepIndex = State(initialValue: validatedMainIndex)
        self._currentSubStepIndex = State(initialValue: validatedSubIndex)
    }

    // Computed Properties (returning optionals)
    private var currentMainStep: MainStep? {
        guard currentMainStepIndex >= 0 && currentMainStepIndex < guide.steps.count else { return nil }
        return guide.steps[currentMainStepIndex]
    }
    private var currentSubStep: SubStep? {
        guard let mainStep = currentMainStep,
              currentSubStepIndex >= 0 && currentSubStepIndex < mainStep.substeps.count else { return nil }
        return mainStep.substeps[currentSubStepIndex]
    }
    private var isLastSubStep: Bool {
        guard let mainStep = currentMainStep else { return false }
        // Ensure count is > 0 before subtracting 1
        return mainStep.substeps.isEmpty ? true : (currentSubStepIndex == mainStep.substeps.count - 1)
    }
    private var isLastMainStep: Bool {
        guide.steps.isEmpty ? true : (currentMainStepIndex == guide.steps.count - 1)
    }
    private var isFinalStep: Bool { isLastMainStep && isLastSubStep }
    private var isFirstStepOfFlow: Bool { currentMainStepIndex == 0 && currentSubStepIndex == 0 }


    var body: some View {
        VStack {
            if navigateToCelebration {
                CelebrationView()
            // --- Use if let to unwrap optionals before calling subview ---
            } else if let mainStep = currentMainStep, let subStep = currentSubStep {
                InstructionSubStepView(
                    guideTitle: guide.title,
                    mainStepTitle: mainStep.title,
                    subStep: subStep,
                    currentSubStepNumber: currentSubStepIndex + 1,
                    totalSubStepsInMain: mainStep.substeps.count,
                    isFirstStep: isFirstStepOfFlow,
                    isFinalStep: isFinalStep,
                    onNext: handleNext,
                    onBack: handleBack,
                    onStepSelected: handleSubStepSelection
                )
            } else {
                 ContentUnavailableView("Error Loading Step", systemImage: "exclamationmark.triangle", description: Text(""))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Navigation Logic

     private func handleNext() {
         if isLastSubStep {
             if isLastMainStep {
                 navigateToCelebration = true
             } else if currentMainStepIndex < guide.steps.count - 1 { // Ensure we don't go out of bounds
                 currentMainStepIndex += 1
                 currentSubStepIndex = 0
             } else {
                 print("⚠️ Error in handleNext: Tried to advance main step beyond bounds.")
             }
         } else {
             if let mainStep = currentMainStep, currentSubStepIndex < mainStep.substeps.count - 1 {
                  currentSubStepIndex += 1
             } else {
                  print("⚠️ Error in handleNext: Tried to increment substep index beyond bounds or mainStep was nil.")
             }
         }
     }

     private func handleBack() {
         if currentSubStepIndex > 0 {
             currentSubStepIndex -= 1
         } else if currentMainStepIndex > 0 {
             currentMainStepIndex -= 1
             let prevMainStep = guide.steps[currentMainStepIndex]
             currentSubStepIndex = max(0, prevMainStep.substeps.count - 1)
         } else {
              dismiss()
         }
     }

     private func handleSubStepSelection(_ tappedSubStepIndex: Int) {
         if let mainStep = currentMainStep,
            tappedSubStepIndex >= 0 && tappedSubStepIndex < mainStep.substeps.count {
              currentSubStepIndex = tappedSubStepIndex
         }
     }
    // --- End Navigation Logic ---
}

// Preview (Use guideTitle)
#if DEBUG
#Preview {
    let sampleGuide = Guide(
        title: "Preview Guide", // Use guideTitle
        steps: [
            MainStep(title: "Preview Main 1", substeps: [
                SubStep(title: "Sub 1.1", moreInfo: "Info for 1.1", description: "Desc 1.1", imageName: nil),
                SubStep(title: nil, moreInfo: nil, description: "Desc 1.2", imageName: "step1-example")
            ]),
            MainStep(title: "Preview Main 2", substeps: [
                SubStep(title: "Sub 2.1", moreInfo: "", description: "Desc 2.1", imageName: nil)
            ])
        ]
    )


        DynamicInstructionFlow(guide: sampleGuide)
    
}
#endif
