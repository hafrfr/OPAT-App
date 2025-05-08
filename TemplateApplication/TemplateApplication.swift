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
    @State private var showSplash = true // Controls splash screen visibility
    
    // Always reset onboarding state for development/testing
    init() {
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages") // remove after presentation (forces system language to be english)
        UserDefaults.standard.synchronize() // remove as well
        UserDefaults.standard.set(false, forKey: StorageKeys.onboardingFlowComplete)
        
        // Apply global tab bar styling using your ColorTheme
        UITabBar.appearance().tintColor = UIColor(ColorTheme.tabBarItemActive)
        UITabBar.appearance().unselectedItemTintColor = UIColor.black.withAlphaComponent(0.25)

        UITabBar.appearance().tintColor = UIColor(ColorTheme.tabBarItemActive) // Active icon color
        UITabBar.appearance().unselectedItemTintColor = UIColor(ColorTheme.tabBarItemInactive) // Inactive icon color
        UITabBar.appearance().backgroundColor = UIColor(ColorTheme.tabBarBackground) // Optional
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
