// CelebrationView.swift
// Part of the OPAT @ Home application
//
// A celebration screen after completing an instruction guide.
// Created by OPAT @ Home team, Chalmers University of Technology, 2025.

import SwiftUI
import Confetti3D

struct CelebrationView: View {
    private let confettiView = C3DView()
    @Environment(\.dismiss) private var dismiss

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
                .frame(width: 100, height: 100)
                .foregroundColor(ColorTheme.progressActive)
            
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
