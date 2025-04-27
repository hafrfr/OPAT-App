// InstructionsListView.swift
// Part of the OPAT @ Home application
//
// A simple, extendable list of available instruction guides.
// Point is to build with PrimaryBackgroundView and ready to integrate full instruction flows with Jacob's code
// Created by harre on 2025-04-27.

import SwiftUI

/// A lightweight model representing an instruction guide. (will be replaced by Jacob's code like a lot of it
struct InstructionGuide: Identifiable {
    let id = UUID()
    let title: String
}

/// The main list view displaying available instruction guides.
struct InstructionsListView: View {
    /// Temporary hardcoded guides; will later be replaced by dynamic data.
    private let instructionGuides: [InstructionGuide] = [
        InstructionGuide(title: "IV Preparation"),
        InstructionGuide(title: "Start Infusion"),
        InstructionGuide(title: "Aftercare")
    ]

    var body: some View {
        NavigationStack {
            PrimaryBackgroundView(title: "Instructions") {
                VStack(spacing: Layout.Spacing.large) {
                    ForEach(instructionGuides) { guide in
                        NavigationLink(destination: Text("Guide for \(guide.title)")) {
                            Text(guide.title)
                                .font(FontTheme.button)
                                .foregroundColor(ColorTheme.title)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorTheme.listItemBackground)
                                .cornerRadius(Layout.Radius.medium)
                                .shadowStyle(ShadowTheme.card)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

#if DEBUG
#Preview {
    InstructionsListView()
}
#endif
