//
//  CelebrationView.swift
//  OPATApp
//
//  Created by harre on 2025-04-28.
//


// CelebrationView.swift
// Part of the OPAT @ Home application
//
// A celebration screen after completing an instruction guide.
// Created by OPAT @ Home team, Chalmers University of Technology, 2025.


import SwiftUI

struct CelebrationView: View {
    @State private var showConfetti = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PrimaryBackgroundView(title: "") {
            ZStack {
                // Confetti Layer
                if showConfetti {
                    ConfettiView()
                        .transition(.opacity)
                        .zIndex(1) // Ensure confetti floats above everything
                }

                // Main content
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
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showConfetti = true
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    CelebrationView()
}
#endif
