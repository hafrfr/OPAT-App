//
// OPATFeatures.swift
// Part of the OPAT @ Home application
//
// Overview screen that introduces key features available in the app.
// Created by the OPAT @ Home team, Chalmers University of Technology, 2025.
//

import SpeziOnboarding
import SwiftUI

struct OPATFeatures: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath

    var body: some View {
        SequentialOnboardingView(
            title: "What You’ll Find in the App",
            subtitle: "Helpful tools to guide you through treatment at home.",
            content: [
                SequentialOnboardingView.Content(
                    title: "Daily Check-ins",
                    description: "Reflect on how you're feeling and get reminders of what to watch out for."
                    // TODO: Link this feature more visually to the actual questionnaire screen once it's styled
                    // TODO: Update this if the daily check-ins are removed or made weekly
                ),
                SequentialOnboardingView.Content(
                    title: "Educational Resources",
                    description: "Short videos and step-by-step guides for staying confident with IV treatment."
                    // TODO: Consider adding icons or previews for video content here once available
                    // TODO: Make this clickable later to jump directly into the Education module post-onboarding
                ),
                SequentialOnboardingView.Content(
                    title: "FAQs and Tips",
                    description: "Clear answers to common questions and guidance on what to do if something feels off."
                    // TODO: Validate FAQ content with clinical team before launch
                    // TODO: Possibly localize these for different regions or care teams
                ),
                SequentialOnboardingView.Content(
                    title: "More Coming Soon",
                    description: "We're building more ways to support you — like audio guidance and multilingual content."
                    // TODO: Replace this section with real modules once features like voice, translations, or streaks are ready
                )
            ],
            actionText: "Sounds Good",
            action: {
                onboardingNavigationPath.nextStep()
            }
        )
    }
}


#if DEBUG
#Preview {
    OnboardingStack {
        OPATFeatures()
    }
}
#endif
