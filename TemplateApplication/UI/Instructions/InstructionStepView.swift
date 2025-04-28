//
// InstructionStepView.swift
// OPAT @ Home
//
// A reusable, polished view for presenting a step in the instruction flow.
// Built to sit on top of PrimaryBackgroundView, with animated transitions and optional more info support.
// Created by harre 2025-04-27.
//

import SwiftUI

struct InstructionStepView: View {
    let title: String
    let stepNumber: Int
    let totalSteps: Int
    let image: Image?
    let description: String
    let moreInfo: String? // <-- NEW
    let buttonText: String
    let onNext: () -> Void
    let onStepSelected: ((Int) -> Void)?
    
    @State private var animateContent = false
    @State private var showMoreInfoAlert = false

    var body: some View {
        PrimaryBackgroundView(title: title) {
            instructionContent
        }
    }

    // MARK: - Main Content
    private var instructionContent: some View {
        VStack(spacing: Layout.Spacing.large) {
            StepProgressIndicatorView(
                currentStep: stepNumber,
                totalSteps: totalSteps,
                onStepSelected: onStepSelected
            )
            .padding(.bottom, Layout.Spacing.medium)

            if let moreInfo = moreInfo, !moreInfo.isEmpty {
                moreInfoButton(moreInfo: moreInfo) // <-- NEW
                    .padding(.bottom, Layout.Spacing.small)
            }

            instructionImage

            instructionText

            Spacer()

            nextButton
        }
        .padding()
        .onAppear {
            animateContent = true
        }
    }

    private var instructionImage: some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 180)
                    .scaleEffect(animateContent ? 1.0 : 0.9)
                    .opacity(animateContent ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.4), value: animateContent)
                    .padding(.top)
            }
        }
    }

    private var instructionText: some View {
        Text(description)
            .font(FontTheme.body)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .opacity(animateContent ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.4).delay(0.2), value: animateContent)
    }

    private var nextButton: some View {
        Button(action: {
            SoundManager.shared.playSound(.nextTap)
            onNext()
        }) {
            Text(buttonText)
                .font(FontTheme.button)
                .frame(maxWidth: .infinity)
                .padding()
                .background(ColorTheme.buttonLarge)
                .foregroundColor(.white)
                .cornerRadius(Layout.Radius.medium)
        }
        .padding(.bottom)
    }

    // MARK: - More Info Button
    private func moreInfoButton(moreInfo: String) -> some View {
        Button(action: {
            showMoreInfoAlert = true
        }) {
            Image(systemName: "questionmark.circle.fill")
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

#if DEBUG
#Preview {
    InstructionStepView(
        title: "Step 1",
        stepNumber: 1,
        totalSteps: 4,
        image: Image(systemName: "cross.case.fill"),
        description: "Gather all necessary IV equipment for today's treatment.",
        moreInfo: "Make sure all supplies are within expiration dates and properly sanitized.",
        buttonText: "Next",
        onNext: { print("Next tapped") },
        onStepSelected: { tappedStep in print("Tapped step \(tappedStep)") }
    )
}
#endif
