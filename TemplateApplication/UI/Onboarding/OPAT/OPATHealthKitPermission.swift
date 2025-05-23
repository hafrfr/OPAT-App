//
// This source file is part of the Stanford Spezi Template Application open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit
import SpeziOnboarding
import SwiftUI


struct OPATHealthKitPermission: View {
    @Environment(HealthKit.self) private var healthKit
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    
    @State private var healthKitProcessing = false
    
    
    var body: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: "HealthKit Access",
                        subtitle: "HEALTHKIT_PERMISSIONS_SUBTITLE"
                    )
                    Spacer()
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 150))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)
                    Text("HEALTHKIT_PERMISSIONS_DESCRIPTION")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                    Spacer()
                }
            }, actionView: {
                OnboardingActionsView(
                    "Grant Access",
                    action: {
                        do {
                            healthKitProcessing = true
                            if ProcessInfo.processInfo.isPreviewSimulator {
                                try await _Concurrency.Task.sleep(for: .seconds(5))
                            } else {
                                //try await healthKit.askForAuthorization()
                                
                            }
                        } catch {
                            print("Could not request HealthKit permissions.")
                        }
                        healthKitProcessing = false
                        
                        onboardingNavigationPath.nextStep()
                    }
                )
            }
        )
            .navigationBarBackButtonHidden(healthKitProcessing)
            .navigationTitle(Text(verbatim: ""))
    }
}


#if DEBUG
#Preview {
    OnboardingStack {
        OPATHealthKitPermission()
    }
        .previewWith(standard: TemplateApplicationStandard()) {
            HealthKit()
        }
}
#endif
