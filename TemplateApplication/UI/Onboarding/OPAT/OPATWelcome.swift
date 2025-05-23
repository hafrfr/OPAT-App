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
// 1. OPATWelcome — welcome users, set a tone of confidence and home treatment.
// ---

import SpeziOnboarding
import SwiftUI

struct OPATWelcome: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath

    var body: some View {
        OnboardingView(
            title: String(localized: "WELCOME_TITLE"),
            subtitle: String(localized: "WELCOME_SUBTITLE"),
            areas: [
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "book.closed.fill")
                            .accessibilityHidden(true)
                            .foregroundColor(ColorTheme.tabBarItemActive)
                    },
                    title: String(localized: "WELCOME_AREA1_TITLE"),
                    description: String(localized: "WELCOME_AREA1_DESCRIPTION")
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "person.2.fill")
                            .accessibilityHidden(true)
                            .foregroundColor(ColorTheme.tabBarItemActive)
                    },
                    title: String(localized: "WELCOME_AREA2_TITLE"),
                    description: String(localized: "WELCOME_AREA2_DESCRIPTION")
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "hand.thumbsup.fill")
                            .accessibilityHidden(true)
                            .foregroundColor(ColorTheme.tabBarItemActive)
                    },
                    title: String(localized: "WELCOME_AREA3_TITLE"),
                    description: String(localized: "WELCOME_AREA3_DESCRIPTION")
                )
            ],
            actionText: String(localized: "GET_STARTED"),
            action: {
                SoundManager.shared.playSound(.nextTap) // Soft tap sound when getting started :D (same as next tap for instructions)
                onboardingNavigationPath.nextStep()
            }
        )
        .font(FontTheme.body)
        .tint(ColorTheme.buttonLarge)
        .padding(.top, Layout.Spacing.large)
    }
}

#if DEBUG
#Preview {
    OnboardingStack {
        OPATWelcome()
    }
}
#endif
