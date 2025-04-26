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
// 5. OPATNotifications — invite users to allow treatment-related notifications in a respectful way, specifying the use of the notifications
// ---

import SpeziNotifications
import SpeziOnboarding
import SwiftUI

struct OPATNotifications: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    @Environment(\.requestNotificationAuthorization) private var requestNotificationAuthorization

    @State private var notificationProcessing = false

    var body: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: String(localized: "NOTIFICATIONS_TITLE"),
                        subtitle: String(localized: "NOTIFICATIONS_SUBTITLE")
                    )
                    Spacer()
                    Image(systemName: "bell.square.fill")
                        .font(.system(size: 150))
                        .foregroundColor(ColorTheme.buttonLarge)
                        .accessibilityHidden(true)

                    Text(String(localized: "NOTIFICATIONS_BODY"))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                    Spacer()
                }
            },
            actionView: {
                OnboardingActionsView(
                    verbatim: String(localized: "ALLOW_NOTIFICATIONS"),
                    action: {
                        do {
                            notificationProcessing = true

                            if ProcessInfo.processInfo.isPreviewSimulator {
                                try await _Concurrency.Task.sleep(for: .seconds(5))
                            } else {
                                try await requestNotificationAuthorization(options: [.alert, .sound, .badge])
                            }
                        } catch {
                            print("Could not request notification permissions.")
                        }

                        notificationProcessing = false
                        onboardingNavigationPath.nextStep()
                    }
                )
                .tint(ColorTheme.buttonLarge)
            }
        )
        .navigationBarBackButtonHidden(notificationProcessing)
        .navigationTitle(Text(verbatim: ""))
    }
}

#if DEBUG
#Preview {
    OnboardingStack {
        OPATNotifications()
    }
    .previewWith {
        TemplateApplicationScheduler()
    }
}
#endif
