//
// This source file is part of the Stanford Spezi Template Application open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//
// ---
// Modified by the OPAT @ Home team, Chalmers University of Technology, 2025.
// Part of the OPAT @ Home application based on the Stanford Spezi Template Application.
// ---

import SpeziOnboarding
import SwiftUI

struct OPATWelcome: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath

    var body: some View {
        OnboardingView(
            title: "Welcome to OPAT @ Home",
            subtitle: "Feel confident and supported with IV treatment at home.",
            areas: [
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "cross.case.fill")
                            .accessibilityHidden(true)
                    },
                    title: "Understand Your Treatment",
                    description: "We’ll guide you step by step through what OPAT is and how it works."
                    // NOTE: Keep this language non-technical and emotionally supportive.
                    // TODO: May want to revisit “how it works” once we finalize content structure.
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "person.2.fill")
                            .accessibilityHidden(true)
                    },
                    title: "For Patients and Caregivers",
                    description: "Whether you’re receiving care or helping someone, we’re here to support you both."
                    // This wording emphasizes inclusion and shared responsibility. Good for early framing.
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "hand.thumbsup.fill")
                            .accessibilityHidden(true)
                    },
                    title: "Feel Prepared and in Control",
                    description: "Get answers to common questions and tips for staying safe, every step of the way."
                    // TODO: Confirm tone is appropriate across user groups (patients, caregivers, different age ranges).
                )
            ],
            actionText: "Get Started",
            action: {
                onboardingNavigationPath.nextStep()
            }
        )
        .padding(.top, 24)
    }
}

#if DEBUG
#Preview {
    OnboardingStack {
        OPATWelcome()
    }
}
#endif
