// File: TemplateApplication/UI/Instructions/InstructionSubStepView.swift (Adjusted)
import SwiftUI

struct InstructionSubStepView: View {
    // Input properties
    let guideTitle: String
    let mainStepTitle: String
    let subStep: SubStep
    let currentSubStepNumber: Int
    let totalSubStepsInMain: Int
    let isFirstStep: Bool // NEW: To disable back button
    let isFinalStep: Bool // NEW: To change Next to Finish
    let onNext: () -> Void
    let onBack: () -> Void // NEW: Action for back button
    let onStepSelected: ((Int) -> Void)?

    // State for animations and alerts
    @State private var animateContent = false
    @State private var showMoreInfoAlert = false

    // Computed property for the right button text
    private var rightButtonText: String {
        isFinalStep ? "Finish" : "Next"
    }

    var body: some View {
        PrimaryBackgroundView(title: mainStepTitle) {
            instructionContent
        }
    }

    // MARK: - Main Content
    private var instructionContent: some View {
        VStack(spacing: Layout.Spacing.medium) {
            if totalSubStepsInMain > 1 {
                StepProgressIndicatorView(
                    currentStep: currentSubStepNumber,
                    totalSteps: totalSubStepsInMain,
                    onStepSelected: { tappedStepNumber in
                        onStepSelected?(tappedStepNumber - 1)
                    }
                )
                .padding(.bottom, Layout.Spacing.small)
            }

            if let subTitle = subStep.title, !subTitle.isEmpty {
                Text(subTitle)
                    .font(FontTheme.title.weight(.semibold))
                    .foregroundColor(ColorTheme.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

             if let moreInfo = subStep.moreInfo, !moreInfo.isEmpty {
                 moreInfoButton(moreInfo: moreInfo)
                     .padding(.bottom, Layout.Spacing.xSmall)
             }

            instructionImage
            instructionText
            Spacer() // Pushes buttons to bottom

            // --- Updated Button Area ---
            bottomNavigationButtons
            // --- End Update ---
        }
        .padding()
        .onAppear {
            animateContent = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    animateContent = true
                }
            }
        }
        .id(subStep.description)
    }

    // MARK: - Bottom Navigation Buttons (NEW/Updated)
    private var bottomNavigationButtons: some View {
        HStack {
            // Back Button
            Button(action: {
                // Add sound effect if desired
                // SoundManager.shared.playSound(.previousTap) // Example sound
                onBack() // Call the closure provided by the parent
            }) {
                Text("Back")
                    .font(FontTheme.button)
                    .frame(maxWidth: .infinity) // Make buttons equal width
                    .padding()
                    .background(isFirstStep ? Color.gray.opacity(0.5) : Color.gray) // Use different background when disabled
                    .foregroundColor(.white)
                    .cornerRadius(Layout.Radius.medium)
            }
            .disabled(isFirstStep) // Disable if it's the very first step

            // Next/Finish Button
            Button(action: {
                SoundManager.shared.playSound(.nextTap)
                onNext() // Call the closure provided by the parent
            }) {
                Text(rightButtonText) // Use computed button text (Next or Finish)
                    .font(FontTheme.button)
                    .frame(maxWidth: .infinity) // Make buttons equal width
                    .padding()
                    .background(ColorTheme.buttonLarge) // Main action color
                    .foregroundColor(.white)
                    .cornerRadius(Layout.Radius.medium)
            }
            // No need to disable the "Finish" button explicitly here,
            // the onNext action handles navigation.
        }
        .padding(.bottom) // Add padding below the HStack
    }


    // MARK: - Sub-views (Image, Text, More Info - No changes needed)
    // ... (instructionImage, instructionText, moreInfoButton remain the same) ...

     private var instructionImage: some View {
         Group {
             let imageName = subStep.imageName ?? ""
             if !imageName.isEmpty, let uiImage = UIImage(named: imageName) {
                 Image(uiImage: uiImage)
                     .resizable()
                     .scaledToFit()
                     .frame(maxHeight: 180)
                     .cornerRadius(Layout.Radius.small)
                     .scaleEffect(animateContent ? 1.0 : 0.9)
                     .opacity(animateContent ? 1.0 : 0.0)
                     .padding(.top, Layout.Spacing.small)
             } else if subStep.imageName != nil {
                  Image(systemName: "photo.fill")
                      .resizable()
                      .scaledToFit()
                      .frame(height: 100)
                      .foregroundColor(.gray.opacity(0.5))
                      .padding()
                      .opacity(animateContent ? 1.0 : 0.0)
             }
         }
     }

     private var instructionText: some View {
         Text(subStep.description)
             .font(FontTheme.body)
             .multilineTextAlignment(.center)
             .padding(.horizontal)
             .opacity(animateContent ? 1.0 : 0.0)
             .animation(.easeInOut(duration: 0.4).delay(0.1), value: animateContent)
     }


     private func moreInfoButton(moreInfo: String) -> some View {
         Button(action: {
             showMoreInfoAlert = true
         }) {
             Image(systemName: "info.circle.fill")
                 .foregroundColor(ColorTheme.progressActive)
                 .font(.system(size: 24))
         }
         .alert(isPresented: $showMoreInfoAlert) {
             Alert(
                 title: Text("More Info"),
                 message: Text(moreInfo),
                 dismissButton: .default(Text("Got it!"))
             )
         }
     }
    // --- End Sub-views ---
}

// MARK: - Preview Update
#if DEBUG
#Preview("First Step") { // Preview the first step
    InstructionSubStepView(
        guideTitle: "Preview Guide",
        mainStepTitle: "Preview Main Step 1",
        subStep: SubStep(
            title: "Sample Substep 1",
            moreInfo: "Info for 1",
            description: "Desc 1",
            imageName: "step1-example"
        ),
        currentSubStepNumber: 1,
        totalSubStepsInMain: 3,
        isFirstStep: true, // Explicitly true for preview
        isFinalStep: false,
        onNext: { print("Next tapped") },
        onBack: { print("Back tapped") },
        onStepSelected: { index in print("Tapped substep index \(index)") }
    )
}

#Preview("Last Step") { // Preview the last step
    InstructionSubStepView(
        guideTitle: "Preview Guide",
        mainStepTitle: "Preview Main Step 2",
        subStep: SubStep(
            title: "Sample Substep 3",
            moreInfo: "Info for 3",
            description: "Desc 3",
            imageName: nil
        ),
        currentSubStepNumber: 2,
        totalSubStepsInMain: 2,
        isFirstStep: false,
        isFinalStep: true, // Explicitly true for preview
        onNext: { print("Finish tapped") },
        onBack: { print("Back tapped") },
        onStepSelected: { index in print("Tapped substep index \(index)") }
    )
}
#endif
