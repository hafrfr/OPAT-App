// InstructionsListView.swift
// Part of the OPAT @ Home application
//
// A clean, dynamic list of available instruction guides.
// Created by harre on 2025-04-27.

import SwiftUI

struct InstructionsListView: View {
    /// Real loaded guides
    private let guides: [Guide] = [
        GuideLoader.loadGuide(named: "guide-template")!
        // Later: Add more once you upload more guides (or create automatic system if we want, but maybe not for MVP? or maybeee :D)
    ]

    var body: some View {
        NavigationStack {
            PrimaryBackgroundView(title: "Instructions") {
                VStack(spacing: Layout.Spacing.large) {
                    ForEach(guides) { guide in
                        NavigationLink(destination: DynamicInstructionFlow(guide: guide)) {
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
