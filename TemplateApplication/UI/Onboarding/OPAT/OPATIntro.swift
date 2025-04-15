//
// OPATIntro.swift
// Part of the OPAT @ Home application
//
// Custom onboarding screen inspired by the Stanford Spezi Template structure.
// Created by the OPAT @ Home team, Chalmers University of Technology, 2025.
//

import SpeziOnboarding
import SwiftUI

struct OPATIntro: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath

    var body: some View {
        OnboardingView(
            title: "What is OPAT?",
            subtitle: "OPAT stands for Outpatient Parenteral Antimicrobial Therapy.",
            areas: [
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "syringe.fill")
                            .accessibilityHidden(true)
                    },
                    title: "IV Treatment at Home",
                    description: "With OPAT, you receive IV antibiotics outside the hospital — often from the comfort of your own home."
                    // TODO: Confirm this description with clinicians. Add nuance for different types of IV access (e.g., PICC, port).
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "calendar")
                            .accessibilityHidden(true)
                    },
                    title: "Scheduled and Supervised",
                    description: "You’ll follow a treatment plan from your doctor, with check-ins as needed."
                    // TODO: Check how they want follow-ups to work in Swedish OPAT programs — is it self-reporting, nurse visits, etc? Should we keep it to current system or the system they WANT?
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "heart.text.square.fill")
                            .accessibilityHidden(true)
                    },
                    title: "You’re Not Alone",
                    description: "This app, along with your care team, is here to help you stay informed and confident."
                )
            ],
            actionText: "Next",
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
        OPATIntro()
    }
}
#endif
