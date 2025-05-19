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
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Background: Petroleum Blue color
            Color("PetroleumBlue")
                .ignoresSafeArea()

            VStack(spacing: Layout.Spacing.small) {
                // App logo (with breathing animation)
                Image("opat_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .scaleEffect(scale) // Animate the scale
                    .accessibilityHidden(true)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 3.5)
                            .repeatForever(autoreverses: true)
                        ) {
                            scale = 1.15 // Gently grow to 115%
                        }
                    }

                // App title
                Text("OPAT @ HOME")
                    .font(FontTheme.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("SandYellow"))

                // Supportive subheading (localized)
                Text(String(localized: "SPLASH_SUBTITLE"))
                    .font(FontTheme.bodyBold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("SandYellow"))
                    .padding(.top, Layout.Spacing.small)
            }
            .padding(.horizontal, Layout.Spacing.large)
        }
    }
}

#if DEBUG
#Preview {
    OPATSplashView()
}
#endif
