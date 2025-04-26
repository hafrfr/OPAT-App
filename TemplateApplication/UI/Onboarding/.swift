//
// LanguageSelectorView.swift
// Part of the OPAT @ Home application
//
// First step before onboarding: allow user to pick English or Swedish manually.
// Created by the OPAT @ Home team, Chalmers University of Technology, 2025.
//

import SwiftUI

struct LanguageSelectorView: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    @AppStorage("selectedLanguage") private var selectedLanguage: String?

    var body: some View {
        VStack(spacing: Layout.Spacing.large) {
            Spacer()

            Text("Choose Your Language")
                .font(FontTheme.title)
                .multilineTextAlignment(.center)

            VStack(spacing: Layout.Spacing.medium) {
                Button(action: {
                    selectedLanguage = "en"
                    Bundle.setLanguage("en")
                    onboardingNavigationPath.nextStep()
                }) {
                    Text("🇬🇧 English")
                        .font(FontTheme.body)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ColorTheme.buttonLarge)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button(action: {
                    selectedLanguage = "sv"
                    Bundle.setLanguage("sv")
                    onboardingNavigationPath.nextStep()
                }) {
                    Text("🇸🇪 Svenska")
                        .font(FontTheme.body)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ColorTheme.buttonLarge)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, Layout.Spacing.large)

            Spacer()

            Text("You can change this later in Settings.")
                .font(FontTheme.caption)
                .foregroundColor(.gray)
                .padding(.top, Layout.Spacing.small)
        }
        .padding()
    }
}

#if DEBUG
#Preview {
    OnboardingStack {
        LanguageSelectorView()
    }
}
#endif
