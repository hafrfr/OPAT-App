//
// OPATOnboardingFlow.swift
// Part of the OPAT @ Home application
//
// Modified onboarding flow using OPAT-specific steps, based on the Stanford Spezi Template Application.
// Created by the OPAT @ Home team, Chalmers University of Technology, 2025.
//

import SpeziOnboarding
import SpeziNotifications
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
            OPATConsent()

            if !localNotificationAuthorization {
                OPATNotifications()
            }

            // TODO: If more onboarding steps (e.g. LanguageSelector, accessibility settings) are added, insert here
            // TODO: Consider letting users revisit onboarding later from settings
        }
        .interactiveDismissDisabled(!completedOnboardingFlow)
        .onChange(of: scenePhase, initial: true) {
            guard case .active = scenePhase else { return }

            Task {
                localNotificationAuthorization = await notificationSettings().authorizationStatus == .authorized
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
