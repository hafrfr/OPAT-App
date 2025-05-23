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
// 2. OPATIntro — educate users about what OPAT actually is.
// ---

import SpeziOnboarding
import SwiftUI

struct OPATIntro: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath

    var body: some View {
        OnboardingView(
            title: String(localized: "INTRO_TITLE"),
            subtitle: String(localized: "INTRO_SUBTITLE"),
            areas: [
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "house.and.flag.fill")
                            .accessibilityHidden(true)
                            .foregroundColor(ColorTheme.tabBarItemActive)
                    },
                    title: String(localized: "INTRO_AREA1_TITLE"),
                    description: String(localized: "INTRO_AREA1_DESCRIPTION")
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "calendar.badge.clock")
                            .accessibilityHidden(true)
                            .foregroundColor(ColorTheme.tabBarItemActive)
                    },
                    title: String(localized: "INTRO_AREA2_TITLE"),
                    description: String(localized: "INTRO_AREA2_DESCRIPTION")
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "person.3.fill")
                            .accessibilityHidden(true)
                            .foregroundColor(ColorTheme.tabBarItemActive)
                    },
                    title: String(localized: "INTRO_AREA3_TITLE"),
                    description: String(localized: "INTRO_AREA3_DESCRIPTION")
                )
            ],
            actionText: String(localized: "NEXT"),
            action: {
                SoundManager.shared.playSound(.nextTap)
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
        OPATIntro()
    }
}
#endif
