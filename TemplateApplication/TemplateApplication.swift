//
// TemplateApplication.swift
// Part of the OPAT @ Home application based on the Stanford Spezi Template Application.
//
// Entry point for the app.
// Created by the OPAT @ Home team, Chalmers University of Technology, 2025.
//

import Spezi
import SpeziFirebaseAccount
import SpeziViews
import SwiftUI

@main
struct TemplateApplication: App {
    @UIApplicationDelegateAdaptor(TemplateApplicationDelegate.self) var appDelegate
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @State private var showSplash = true // Controls splash screen visibility

    // Always reset onboarding state for development/testing
    init() {
        UserDefaults.standard.set(false, forKey: StorageKeys.onboardingFlowComplete)
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if completedOnboardingFlow {
                    HomeView()
                } else if showSplash {
                    OPATSplashView()
                        .onAppear {
                            // Add delay before starting onboarding (to show our splash screen <3, mostly for presentation)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation {
                                    showSplash = false
                                }
                            }
                        }
                } else {
                    OPATOnboardingFlow()
                }
            }
            .testingSetup()
            .spezi(appDelegate)
        }
    }
}
