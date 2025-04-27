// StepProgressIndicatorView.swift
// Part of the OPAT @ Home application
//
// A reusable, dynamic view showing step-by-step progress in an instructional flow.
// Built for maximum clarity, patient encouragement, clean animations, and optional fast navigation.
// Created by harre on 2025-04-27.

import SwiftUI

/// Displays the current progress through a series of instructional steps.
/// Supports both animated highlighting and optional step navigation.
public struct StepProgressIndicatorView: View {
    let currentStep: Int
    let totalSteps: Int
    let onStepSelected: ((Int) -> Void)? // Optional tap handler to jump between steps

    @State private var animatePulse = false // Controls subtle pulse animation when changing steps

    /// Creates a step indicator.
    /// - Parameters:
    ///   - currentStep: The current active step (starting from 1).
    ///   - totalSteps: The total number of steps in the sequence.
    ///   - onStepSelected: Optional closure triggered when user taps a specific step.
    public init(currentStep: Int, totalSteps: Int, onStepSelected: ((Int) -> Void)? = nil) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.onStepSelected = onStepSelected
    }

    public var body: some View {
        HStack(spacing: Layout.Spacing.small) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? ColorTheme.progressActive : ColorTheme.progressInactive)
                    .frame(width: 12, height: 12)
                    .scaleEffect(scale(for: step))
                    .animation(.easeInOut(duration: 0.4), value: animatePulse)
                    .onTapGesture {
                        onStepSelected?(step) // Call handler if tapable
                    }
                    .contentShape(Circle()) // Enlarge tap area to match circle for easier UX
            }
        }
        .padding(.bottom, Layout.Spacing.medium)
        .onAppear {
            animatePulse = true // Initial animation trigger
        }
        .onChange(of: currentStep) { _ in
            // Re-trigger animation whenever the active step changes
            animatePulse = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                animatePulse = true
            }
        }
    }

    /// Determines the visual scaling for each step based on current animation state.
    private func scale(for step: Int) -> CGFloat {
        if step == currentStep {
            return animatePulse ? 1.3 : 1.0 // Pulse bigger when selected
        } else {
            return 1.0
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 20) {
        StepProgressIndicatorView(currentStep: 2, totalSteps: 5) { tappedStep in
            print("Tapped step: \(tappedStep)")
        }
        StepProgressIndicatorView(currentStep: 4, totalSteps: 5)
    }
    .padding()
}
#endif
