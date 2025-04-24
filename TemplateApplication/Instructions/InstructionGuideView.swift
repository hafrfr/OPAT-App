import SwiftUI

struct InstructionGuideView: View {
    let steps: [InstructionStep]
    @State private var currentStepIndex = 0
    @State private var currentSubStepIndex = 0
    @Binding var navigationPath: NavigationPath

    // Computed property for the current step
    private var currentStep: InstructionStep { steps[currentStepIndex] }

    // Computed property for the current substep
    private var currentSubStep: SubStep {
        guard !currentStep.substeps.isEmpty else {
             // CORRECTED: Ensure return for empty case
             return SubStep(title: "Error", description: "No substeps defined.", imageName: "exclamationmark.triangle")
        }
        let safeIndex = max(0, min(currentSubStepIndex, currentStep.substeps.count - 1))
        return currentStep.substeps[safeIndex]
    }

    // Function to handle backward navigation
    private func goToPrevious() {
         if currentSubStepIndex > 0 { currentSubStepIndex -= 1 }
         else if currentStepIndex > 0 {
             currentStepIndex -= 1
             currentSubStepIndex = max(0, steps[currentStepIndex].substeps.count - 1)
         } else {
             // Use isEmpty check (SwiftLint fix from previous step)
             if !navigationPath.isEmpty {
                 navigationPath.removeLast() // Modify the value via binding
             }
         }
    }

    // Function to handle forward navigation
    private func goToNext() {
         if currentSubStepIndex < currentStep.substeps.count - 1 {
             currentSubStepIndex += 1
         } else if currentStepIndex < steps.count - 1 {
             currentStepIndex += 1
             currentSubStepIndex = 0
         }
    }




    // MARK: - Body
    private let progressViewHeight: CGFloat = 30 // Adjust as needed (e.g., dot height + vertical padding)

       // MARK: - Body
       var body: some View {
           VStack(spacing: 0) {
               // Header View
               InstructionHeaderView(
                   stepTitle: currentStep.title,
                   onBack: goToPrevious
               )
               Divider().padding(.bottom, 5)

               // --- Placeholder for Progress View Area ---
               Color.clear // Use a clear, invisible placeholder
                   .frame(height: progressViewHeight) // Reserve consistent height
                   .overlay { // Overlay the actual progress view conditionally
                       if currentStep.substeps.count > 1 {
                           SubstepProgressView(
                               totalSubsteps: currentStep.substeps.count,
                               currentSubstepIndex: currentSubStepIndex
                           )
                           // Center the dots within the reserved space if needed
                           // .alignment(.center) // Default for overlay
                       }
                       // No else needed, overlay is empty if condition is false
                   }
                   // Add padding below the placeholder area
                   .padding(.bottom, 15) // Adjust padding below the progress area


               // Substep Content ScrollView
               substepContentScrollView

               Spacer() // Pushes buttons to bottom

               // Bottom Navigation Buttons
               bottomNavigationButtons

           } // End VStack
           .navigationBarHidden(true)
           .navigationBarBackButtonHidden(true)
       } // End body

       // MARK: - Private Computed Views (Removed progressIndicator)

       private var substepContentScrollView: some View {
            ScrollView {
                 InstructionStepView(substep: currentSubStep)
                     .padding(.horizontal)
            }
       }
    private var progressIndicator: some View {
           // Show ProgressView only if needed, otherwise show nothing
           // The consistent padding is handled in the main body now
           Group {
               if currentStep.substeps.count > 1 {
                   SubstepProgressView(
                       totalSubsteps: currentStep.substeps.count,
                       currentSubstepIndex: currentSubStepIndex
                   )
                   // Padding inside here affects only the dots view itself
                   // .padding(.vertical) // Example internal padding if needed
               }
               // ** Else block removed ** - No explicit spacer needed here now
           }
           // Ensure this Group doesn't take up extra height when empty
           .frame(height: currentStep.substeps.count > 1 ? nil : 0) // Collapse height if empty
           .clipped() // Clip to prevent empty group taking space
       }
    private var bottomNavigationButtons: some View {
            HStack {
                // Previous Button
                Button("Previous") { goToPrevious() }
                    .buttonStyle(.bordered)
                    .disabled(currentStepIndex == 0 && currentSubStepIndex == 0)

                Spacer()

                // Next / Finish Button
                if currentStepIndex == steps.count - 1 && currentSubStepIndex == currentStep.substeps.count - 1 {
                    // Finish Button
                    Button("Finish") {
                        print("[GuideView] Finish tapped - resetting navigation path.")
                        navigationPath.removeLast(navigationPath.count)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    // Next Button
                    Button("Next") { goToNext() }
                     .buttonStyle(.borderedProminent)
                }
            }
            .padding() // Padding around the button HStack
        }

} // End struct

// MARK: - Preview Provider
#Preview {
     // CORRECTED: Ensure PreviewWrapper is used correctly
     struct PreviewWrapper: View {
         // Load sample steps, provide a safe fallback
         let previewSteps = InstructionGuideDataSource.loadGuides().first?.steps ?? [
             // CORRECTED: Shortened fallback description line
             InstructionStep(title: "Preview Error", substeps: [
                SubStep(title: "Error", description: "Could not load steps.", imageName: nil)
             ])
         ]
         // State variable for the navigation path binding in the preview
         @State private var previewPath = NavigationPath()

         var body: some View {
             // Use NavigationStack to mimic navigation environment
             NavigationStack(path: $previewPath) {
                 // Initialize InstructionGuideView with steps and the path binding
                 InstructionGuideView(
                     steps: previewSteps,
                     navigationPath: $previewPath // Pass the binding correctly
                 )
             }
         }
     }
     return PreviewWrapper() // Return the preview wrapper
}
