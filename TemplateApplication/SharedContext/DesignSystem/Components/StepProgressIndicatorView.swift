// StepProgressIndicatorView.swift
// Part of the OPAT @ Home application
//
// A reusable, dynamic view showing step-by-step progress in an instructional flow.
// Updated to follow our color and visual philosophy strictly.
// Created by harre on 2025-04-27.

import SwiftUI

public struct StepProgressIndicatorView: View {
    let currentStep: Int
    let totalSteps: Int
    let onStepSelected: ((Int) -> Void)?

    @State private var animatePulse = false

    public init(currentStep: Int, totalSteps: Int, onStepSelected: ((Int) -> Void)? = nil) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.onStepSelected = onStepSelected
    }

    public var body: some View {
        HStack(spacing: Layout.Spacing.small) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(color(for: step))
                    .frame(width: 12, height: 12)
                    .scaleEffect(scale(for: step))
                    .animation(.easeInOut(duration: 0.4), value: animatePulse)
                    .onTapGesture {
                        SoundManager.shared.playSound(.progressTap)
                        onStepSelected?(step)
                    }
                    .contentShape(Circle())
            }
        }
        .padding(.bottom, Layout.Spacing.medium)
        .onAppear {
            animatePulse = true
        }
        .onChange(of: currentStep) { _ in
            animatePulse = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                animatePulse = true
            }
        }
    }

    private func color(for step: Int) -> Color {
        step == currentStep ? ColorTheme.progressActive : ColorTheme.progressInactive
    }

    private func scale(for step: Int) -> CGFloat {
        if step == currentStep {
            return animatePulse ? 1.3 : 1.0
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
