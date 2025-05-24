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
// 4. OPATConsent — explain how the check-in feature works and that it's local; confirm user understanding of this. Also a push that they are a part of the team!
// ---

import SpeziOnboarding
import SwiftUI

struct OPATConsent: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath

    var body: some View {
        OnboardingView(
            title: String(localized: "CONSENT_TITLE"),
            subtitle: String(localized: "CONSENT_SUBTITLE"),
            areas: [
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "doc.text.fill")
                            .accessibilityHidden(true)
                            .foregroundColor(ColorTheme.tabBarItemActive)
                    },
                    title: String(localized: "CONSENT_AREA1_TITLE"),
                    description: String(localized: "CONSENT_AREA1_DESCRIPTION")
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "cross.case.fill")
                            .accessibilityHidden(true)
                            .foregroundColor(ColorTheme.tabBarItemActive)
                    },
                    title: String(localized: "CONSENT_AREA2_TITLE"),
                    description: String(localized: "CONSENT_AREA2_DESCRIPTION")
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "lock.shield.fill")
                            .accessibilityHidden(true)
                            .foregroundColor(ColorTheme.tabBarItemActive)
                    },
                    title: String(localized: "CONSENT_AREA3_TITLE"),
                    description: String(localized: "CONSENT_AREA3_DESCRIPTION")
                )
            ],
            actionText: String(localized: "I_UNDERSTAND"),
            action: {
                SoundManager.shared.playSound(.nextTap)
                onboardingNavigationPath.nextStep()
            }
        )
        .font(FontTheme.body)
        .tint(ColorTheme.buttonLarge)
        .padding(.top, Layout.Spacing.large)
        .accentColor(ColorTheme.buttonLarge)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: Layout.Spacing.large)
        }
    }
}


#if DEBUG
#Preview {
    OnboardingStack {
        OPATConsent()
    }
}
#endif
