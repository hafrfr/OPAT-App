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

import SpeziNotifications
import SpeziOnboarding
import SwiftUI

/// Displays the onboarding flow for the OPAT @ Home app.
struct OPATOnboardingFlow: View {
    @AppStorage(StorageKeys.onboardingFlowComplete) private var completedOnboardingFlow = false
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.notificationSettings) private var notificationSettings

    @State private var localNotificationAuthorization = false

    var body: some View {
        OnboardingStack(onboardingFlowComplete: $completedOnboardingFlow) {
            OPATWelcome()
            OPATIntro()
            OPATFeatures()
            AccountOnboarding()
            OPATConsent()
            OPATHealthKitPermission()

            if !localNotificationAuthorization {
                OPATNotifications()
            }

            // TODO: If more onboarding steps (e.g. LanguageSelector, accessibility settings) are added, insert here
            // TODO: Consider letting users revisit onboarding later from settings
        }
        .interactiveDismissDisabled(!completedOnboardingFlow)
        .onAppear {
            #if DEBUG
            completedOnboardingFlow = false
            #endif
        }
        .onChange(of: scenePhase, initial: true) {
            guard case .active = scenePhase else { return }
            Task {
                #if DEBUG
                localNotificationAuthorization = false
                #else
                localNotificationAuthorization = await notificationSettings().authorizationStatus == .authorized
                #endif
            }
        }
    }
}

#if DEBUG
#Preview {
    OnboardingStack {
        OPATOnboardingFlow()
    }
}
#endif
