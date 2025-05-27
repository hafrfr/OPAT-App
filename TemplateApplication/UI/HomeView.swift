//
// This source file is part of the Stanford Spezi Template Application open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SwiftUI

struct HomeView: View {
    enum Tabs: String {
        case schedule
        case contact
        case instructions
        case faq
    }

    @AppStorage(StorageKeys.homeTabSelection) private var selectedTab = Tabs.schedule
    @AppStorage(StorageKeys.tabViewCustomization) private var tabViewCustomization = TabViewCustomization()

    @State private var presentingAccount = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Schedule", systemImage: "calendar.badge.clock", value: .schedule) {
                OPATScheduleView(presentingAccount: $presentingAccount)
                .tint(ColorTheme.tabBarItemActive)
            }
            .customizationID("home.schedule")
            Tab("Contacts", systemImage: "phone.fill", value: .contact) {
                Contacts(presentingAccount: $presentingAccount)
                .tint(ColorTheme.tabBarItemActive)
            }
            .customizationID("home.contacts")
            Tab("Instructions", systemImage: "book.fill", value: .instructions) {
                InstructionsListView(presentingAccount: $presentingAccount)
                .tint(ColorTheme.tabBarItemActive)
            }
            .customizationID("home.instructions")
            Tab("FAQ", systemImage: "questionmark.circle", value: .faq) {
                FAQView(presentingAccount: $presentingAccount)
                .tint(ColorTheme.tabBarItemActive)
            }
            .customizationID("home.faq")
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .tabViewStyle(.sidebarAdaptable)
        .tabViewCustomization($tabViewCustomization)
        .sheet(isPresented: $presentingAccount) {
            AccountSheet(dismissAfterSignIn: false)
        }
        .accountRequired(!FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding) {
            AccountSheet()
        } .onAppear { 
            setupTransparentTabBar()
        }
    }
    
        private func setupTransparentTabBar() {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()



            // Apply the appearance to the standard and scroll edge states
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
}

#if DEBUG
#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    
    return HomeView()
        .previewWith(standard: TemplateApplicationStandard()) {
            TemplateApplicationScheduler()
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}
#endif
