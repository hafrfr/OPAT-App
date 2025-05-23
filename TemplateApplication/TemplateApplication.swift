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

import Spezi
import SpeziFirebaseAccount
import SpeziViews
import SwiftUI


@main
struct TemplateApplication: App {
    @UIApplicationDelegateAdaptor(TemplateApplicationDelegate.self) var appDelegate
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @State private var showSplash = true
    init() {
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()    }
    
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
