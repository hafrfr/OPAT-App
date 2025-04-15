//
// NotificationPermissions.swift
// Part of the OPAT @ Home application
//
// Requesting notification permissions to support daily check-ins and gentle reminders.
// Updated by the OPAT @ Home team, Chalmers University of Technology, 2025.
//

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
                        title: "Stay Informed",
                        subtitle: "Get helpful reminders during your treatment."
                    )
                    Spacer()
                    Image(systemName: "bell.square.fill")
                        .font(.system(size: 150))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)

                    Text("We can send reminders to check in or review tips. It’s optional — and you can turn it off anytime.")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)

                    // TODO: Consider letting the user choose reminder time or type later (e.g., daily check-in vs. weekly summary)
                    // TODO: If the app adds more notification types (e.g., new guides or clinical alerts), clarify this up front
                    Spacer()
                }
            },
            actionView: {
                OnboardingActionsView(
                    "Allow Notifications",
                    action: {
                        do {
                            notificationProcessing = true

                            // Simulated delay in preview environment
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
            }
        )
        .navigationBarBackButtonHidden(notificationProcessing)
        .navigationTitle(Text(verbatim: ""))

        // TODO: Possibly show current notification status here for returning users
        // TODO: Consider showing a reminder toggle in settings or onboarding review later
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
