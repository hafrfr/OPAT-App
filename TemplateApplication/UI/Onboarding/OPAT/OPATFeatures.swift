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
// 3. OPATFeatures — highlight key features of the app and how it supports them.
// ---

import SpeziOnboarding
import SwiftUI

struct OPATFeatures: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath

    var body: some View {
        SequentialOnboardingView(
            title: String(localized: "FEATURES_TITLE"),
            subtitle: String(localized: "FEATURES_SUBTITLE"),
            content: [
                SequentialOnboardingView.Content(
                    title: String(localized: "FEATURE1_TITLE"),
                    description: String(localized: "FEATURE1_DESCRIPTION")
                ),
                SequentialOnboardingView.Content(
                    title: String(localized: "FEATURE2_TITLE"),
                    description: String(localized: "FEATURE2_DESCRIPTION")
                ),
                SequentialOnboardingView.Content(
                    title: String(localized: "FEATURE3_TITLE"),
                    description: String(localized: "FEATURE3_DESCRIPTION")
                ),
                SequentialOnboardingView.Content(
                    title: String(localized: "FEATURE4_TITLE"),
                    description: String(localized: "FEATURE4_DESCRIPTION")
                ),
                SequentialOnboardingView.Content(
                    title: String(localized: "FEATURE5_TITLE"),
                    description: String(localized: "FEATURE5_DESCRIPTION")
                )
            ],
            actionText: String(localized: "SOUNDS_GOOD"),
            action: {
                SoundManager.shared.playSound(.nextTap)
                onboardingNavigationPath.nextStep()
            }
        )
        .font(FontTheme.body)
        .tint(ColorTheme.buttonLarge)
        .padding(.top, Layout.Spacing.large)
        .accentColor(ColorTheme.buttonLarge) // Override the numbered circles color to app color
    }
}

#if DEBUG
#Preview {
    OnboardingStack {
        OPATFeatures()
    }
}
#endif
