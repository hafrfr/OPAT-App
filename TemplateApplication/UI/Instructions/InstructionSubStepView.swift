// File: TemplateApplication/UI/Instructions/InstructionSubStepView.swift (Toolbar & Centering Added)
import SwiftUI

struct InstructionSubStepView: View {
    // Input properties (remain the same)
    let guideTitle: String
    let mainStepTitle: String
    let subStep: SubStep
    let currentSubStepNumber: Int
    let totalSubStepsInMain: Int
    let isFirstStep: Bool
    let isFinalStep: Bool
    let onNext: () -> Void
    let onBack: () -> Void
    let onStepSelected: ((Int) -> Void)?
    @Environment(\.dismiss) private var dismiss

    // State (remains the same)
    @State private var animateContent = false
    @State private var showMoreInfoAlert = false

    // Computed property (remains the same)
    private var rightButtonText: String {
        isFinalStep ? "Finish" : "Next"
    }

    var body: some View {
        // PrimaryBackgroundView now has the toolbar attached
        PrimaryBackgroundView(title: mainStepTitle, useWhiteContainer: true) {
            // instructionContent handles the main view content
            instructionContent
        }
        // --- ADD TOOLBAR ---
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                // Use the existing onBack action for this button
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                    Text("Back to instructions")
                }
                 .foregroundColor(ColorTheme.buttonLarge) // Example color

            }
        }

        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Main Content (Adjusted for Centering)
    private var instructionContent: some View {
        VStack(spacing: Layout.Spacing.medium) {
            // Progressbar
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
            Spacer()

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

            Spacer()
            // --- End Add ---

            // Bottom navigation buttons remain at the bottom
            bottomNavigationButtons

        } // End VStack
        .padding() // Keep overall padding for content
        .onAppear { // Animation logic remains
            animateContent = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    animateContent = true
                }
            }
        }
        .id(subStep.description) // Trigger animation on change
    }

    // MARK: - Bottom Navigation Buttons (Remains the same)
    private var bottomNavigationButtons: some View {
         // ... (code for HStack with Back and Next/Finish buttons is unchanged) ...
         HStack {
             Button(action: { onBack() }) {
                 Text("Back")
                     .font(FontTheme.button)
                     .frame(maxWidth: .infinity)
                     .padding()
                     .background(isFirstStep ? Color.gray.opacity(0.5) : Color.gray)
                     .foregroundColor(.white)
                     .cornerRadius(Layout.Radius.medium)
             }
             .disabled(isFirstStep)

             Button(action: {
                 SoundManager.shared.playSound(.nextTap)
                 onNext()
             }) {
                 Text(rightButtonText)
                     .font(FontTheme.button)
                     .frame(maxWidth: .infinity)
                     .padding()
                     .background(ColorTheme.buttonLarge)
                     .foregroundColor(.white)
                     .cornerRadius(Layout.Radius.medium)
             }
         }
         .padding(.bottom)
    }


    // MARK: - Sub-views (Image, Text, More Info - Remains the same)
    private var instructionImage: some View {
         // ... (code unchanged) ...
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
         // ... (code unchanged) ...
         Text(subStep.description)
             .font(FontTheme.body)
             .multilineTextAlignment(.center)
             .padding(.horizontal)
             .opacity(animateContent ? 1.0 : 0.0)
             .animation(.easeInOut(duration: 0.4).delay(0.1), value: animateContent)
    }

    private func moreInfoButton(moreInfo: String) -> some View {
         // ... (code unchanged) ...
         Button(action: { showMoreInfoAlert = true }) {
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
}

// MARK: - Preview Update (No changes needed, but good practice)
#if DEBUG
// Previews remain the same, testing first/last step states
#Preview("First Step") {
    InstructionSubStepView(
        guideTitle: "Preview Guide", mainStepTitle: "Preview Main Step 1",
        subStep: SubStep(title: "Sample Substep 1", moreInfo: "Info for 1", description: "Desc 1", imageName: "step1-example"),
        currentSubStepNumber: 1, totalSubStepsInMain: 3,
        isFirstStep: true, isFinalStep: false,
        onNext: { print("Next tapped") }, onBack: { print("Back tapped") },
        onStepSelected: { index in print("Tapped substep index \(index)") }
    )
}
#Preview("Last Step") {
    InstructionSubStepView(
        guideTitle: "Preview Guide", mainStepTitle: "Preview Main Step 2",
        subStep: SubStep(title: "Sample Substep 3", moreInfo: "Info for 3", description: "Desc 3", imageName: nil),
        currentSubStepNumber: 2, totalSubStepsInMain: 2,
        isFirstStep: false, isFinalStep: true,
        onNext: { print("Finish tapped") }, onBack: { print("Back tapped") },
        onStepSelected: { index in print("Tapped substep index \(index)") }
    )
}
#endif
