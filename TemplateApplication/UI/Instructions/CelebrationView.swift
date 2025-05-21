// CelebrationView.swift
// Part of the OPAT @ Home application
//
// A celebration screen after completing an instruction guide.
// Created by OPAT @ Home team, Chalmers University of Technology, 2025.

import Confetti3D
import SwiftUI

struct CelebrationView: View {
    private let confettiView = C3DView()
    @Environment(\.dismiss) private var dismiss
    @State private var animateGlow = false

    var body: some View {
        PrimaryBackgroundView(title: "") {
            ZStack {
                confettiView
                           .ignoresSafeArea()
                           .zIndex(0)
                contentLayer
                            .zIndex(1)
            }
            .onAppear {
                confettiView.throwConfetti()
                SoundManager.shared.playSound(.celebration) // plays as soon as the screen appears
            }
        }
    }

    // MARK: - Layers

    private var contentLayer: some View {
        VStack(spacing: Layout.Spacing.large) {
            Spacer()
            Image(systemName: "party.popper.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(ColorTheme.progressActive)
                            .shadow(
                                color: Color("SandYellow")
                                    .opacity(animateGlow ? 0.8 : 0.3),
                                radius: animateGlow ? 18 : 8
                            )
                            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animateGlow)
                            .onAppear {
                                animateGlow = true
                            }
            Text("All Done!")
                .font(FontTheme.title)
                .foregroundColor(ColorTheme.title)
            
            Spacer()
            
            Button(action: {
                SoundManager.shared.playSound(.nextTap)
                dismiss()
            }) {
                Text("Return to Instructions")
                    .font(FontTheme.button)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorTheme.buttonLarge)
                    .foregroundColor(.white)
                    .cornerRadius(Layout.Radius.medium)
            }
            .padding()
        }
        .padding()
    }
}

#if DEBUG
#Preview {
    CelebrationView()
}
#endif
