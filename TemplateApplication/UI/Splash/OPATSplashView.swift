//
// OPATSplashView.swift
// Part of the OPAT @ Home application
//
// Custom splash screen shown behind onboarding on first launch.
// Designed for a calming, confidence-building entry into the app.
// Created by the OPAT @ Home team, Chalmers University of Technology, 2025.
//

import SwiftUI

struct OPATSplashView: View {
    var body: some View {
        ZStack {
            // Background: Petroleum Blue brand color
            Color("PetroleumBlue")
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // App logo (icon in Assets.xcassets)
                Image("opat_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .accessibilityHidden(true)

                // App title
                Text("OPAT @ HOME")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("SandYellow"))

                // Supportive subheading
                Text("Here to guide your treatment\nOne step at a time")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("SandYellow"))
                    .padding(.top, 4)
            }
        }
    }
}

#if DEBUG
#Preview {
    OPATSplashView()
}
#endif
