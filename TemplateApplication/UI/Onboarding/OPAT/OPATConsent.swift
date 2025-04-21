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

struct OPATConsent: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath

    var body: some View {
        OnboardingView(
            title: "Before You Start",
            subtitle: "A few words about your check-ins.",
            areas: [
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "lock.shield.fill")
                            .accessibilityHidden(true)
                    },
                    title: "Private & Optional",
                    description: "Daily check-ins help you reflect on how you’re feeling. It’s optional and your answers stay private on your device."
                    // TODO: Reconfirm this with someone who knows legal/ethics issues if check-ins evolve into structured symptom tracking
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "person.text.rectangle.fill")
                            .accessibilityHidden(true)
                    },
                    title: "You're in Control",
                    description: "Your check-ins are for your own insight. This is not medical advice or a replacement for professional care."
                    // TODO: Revisit this disclaimer if app starts integrating with clinicians or care pathways (probably not for this project)
                )
                // TODO: Optionally reintroduce info toggle section later as a third row if needed
            ],
            actionText: "I Understand",
            action: {
                onboardingNavigationPath.nextStep()
            }
        )
        .padding(.top, 24)
        // TODO: Consider saving consent locally (as a bool flag or timestamp) for internal auditing or future features
    }
}


#if DEBUG
#Preview {
    OnboardingStack {
        OPATConsent()
    }
}
#endif
