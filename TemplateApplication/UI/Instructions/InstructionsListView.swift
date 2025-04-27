// InstructionsListView.swift
// Part of the OPAT @ Home application
//
// A simple, extendable list of available instruction guides.
// Point is to build with PrimaryBackgroundView and ready to integrate full instruction flows with Jacob's code
// Created by harre on 2025-04-27.

import SwiftUI

/// A lightweight model representing an instruction guide.
struct InstructionGuide: Identifiable {
    let id = UUID()
    let title: String
}

/// The main list view displaying available instruction guides.
struct InstructionsListView: View {
    /// Temporary hardcoded guides; will later be replaced by dynamic data.
    private let instructionGuides: [InstructionGuide] = [
        InstructionGuide(title: "IV Preparation"),
        InstructionGuide(title: "Start Infusion"),
        InstructionGuide(title: "Aftercare"),
        InstructionGuide(title: "Example Guide") // demo flow
    ]

    var body: some View {
        NavigationStack {
            PrimaryBackgroundView(title: "Instructions") {
                VStack(spacing: Layout.Spacing.large) {
                    ForEach(instructionGuides) { guide in
                        NavigationLink(destination: destinationView(for: guide)) {
                            Text(guide.title)
                                .font(FontTheme.button)
                                .foregroundColor(ColorTheme.title)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorTheme.listItemBackground)
                                .cornerRadius(Layout.Radius.medium)
                                .shadowStyle(ShadowTheme.card)
                        }
                    }
                }
                .padding()
            }
        }
    }

    /// Decides where the NavigationLink should go based on the guide title
    @ViewBuilder
    private func destinationView(for guide: InstructionGuide) -> some View {
        if guide.title == "Example Guide" {
            ExampleInstructionFlow()
        } else {
            ComingSoonView(guideTitle: guide.title)
        }
    }
}

// Below is example view that will be removed or  commented out when showing prototype

// MARK: - ExampleInstructionFlow (Will be removed later)
struct ExampleInstructionFlow: View {
    @State private var currentStep = 1

    var body: some View {
        InstructionStepView(
            title: "Step \(currentStep)",
            stepNumber: currentStep,
            totalSteps: 3,
            image: Image(systemName: "cross.case.fill"),
            description: descriptionForCurrentStep(),
            buttonText: currentStep < 3 ? "Next" : "Finish",
            onNext: {
                if currentStep < 3 {
                    currentStep += 1
                } else {
                    // Handle finishing, maybe pop back or show a "Done" screen
                }
            },
            onStepSelected: { tappedStep in
                currentStep = tappedStep
            }
        )
        .toolbar(.hidden, for: .tabBar)
// Hiding tabs, but might have to find a smoother way to do this in the future, instead of adding this to all views we dont want them in :PP
    }

    private func descriptionForCurrentStep() -> String {
        switch currentStep {
        case 1:
            return "Gather your IV supplies and wash your hands thoroughly."
        case 2:
            return "Prepare the IV line and medication according to instructions."
        case 3:
            return "Connect your IV line and start the infusion."
        default:
            return ""
        }
    }
}

// MARK: - ComingSoonView (Might keep in case we want user to have a view in case there is missing guides?)
struct ComingSoonView: View {
    let guideTitle: String

    var body: some View {
        VStack {
            Text("\(guideTitle) guide coming soon!")
                .font(FontTheme.title)
                .padding()
            Spacer()
        }
        .navigationTitle(guideTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
#Preview {
    InstructionsListView()
}
#endif
