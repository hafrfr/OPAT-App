//
//  DynamicInstructionFlow.swift
//  OPATApp
//
//  Created by harre 2025-04-28.
//

import SwiftUI

struct DynamicInstructionFlow: View {
    let guide: Guide

    @State private var currentStepIndex = 0
    @State private var navigateToCelebration = false

    var body: some View {
        VStack {
            if navigateToCelebration {
                CelebrationView()
            } else if currentStepIndex < guide.steps.count {
                let step = guide.steps[currentStepIndex]
                InstructionStepView(
                    title: guide.title,
                    stepNumber: step.stepNumber,
                    totalSteps: guide.steps.count,
                    image: Image(step.imageName), // assuming image exists
                    description: step.description,
                    moreInfo: step.moreInfo.isEmpty ? nil : step.moreInfo,
                    buttonText: currentStepIndex == guide.steps.count - 1 ? "Finish" : "Next",
                    onNext: {
                        if currentStepIndex < guide.steps.count - 1 {
                            currentStepIndex += 1
                        } else {
                            navigateToCelebration = true
                        }
                    },
                    onStepSelected: { tappedStep in
                        currentStepIndex = tappedStep - 1
                    }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar) // Hide the tab bar
    }
}
