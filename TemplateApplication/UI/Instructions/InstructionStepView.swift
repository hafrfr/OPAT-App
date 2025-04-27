// InstructionStepView.swift
// Part of the OPAT @ Home application
//
// A reusable, polished view for presenting a step in the instruction flow.
// Built to sit on top of PrimaryBackgroundView, with animated transitions and encouragement support.
// Created by harre on 2025-04-27.

import SwiftUI

struct InstructionStepView: View {
    let title: String
    let stepNumber: Int
    let totalSteps: Int
    let image: Image?
    let description: String
    let buttonText: String
    let onNext: () -> Void
    let onStepSelected: ((Int) -> Void)? // step jumping

    @State private var animateContent = false
// Could use similiar logic to below but not needed
    /*
    private var encouragementText: String? {
        if stepNumber == totalSteps {
            return "You're all set!"
        } else if stepNumber == totalSteps / 2 {
            return "Halfway there!"
        } else {
            return nil
        }
    }
    */


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

            // encouragementView

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
    
    /*
    // MARK: - Subviews
    private var encouragementView: some View {
        Group {
            if let encouragement = encouragementText {
                Text(encouragement)
                    .font(FontTheme.progress)
                    .foregroundColor(ColorTheme.progressActive)
                    .transition(.opacity)
                    .padding(.bottom, Layout.Spacing.small)
            }
        }
    }
    */

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
}

#if DEBUG
#Preview {
    InstructionStepView(
        title: "Step 1",
        stepNumber: 1,
        totalSteps: 4,
        image: Image(systemName: "cross.case.fill"),
        description: "Gather all necessary IV equipment for today's treatment.",
        buttonText: "Next",
        onNext: { print("Next tapped") },
        onStepSelected: { tappedStep in print("Tapped step \(tappedStep)") }
    )
}
#endif
