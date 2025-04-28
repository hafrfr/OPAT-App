// InstructionsListView.swift
// Part of the OPAT @ Home application
//
// A clean, dynamic list of available instruction guides.
// Created by harre on 2025-04-27.
import Spezi
import SwiftUI
struct InstructionsListView: View {
    /// Real loaded guides
    private let guides: [Guide] = GuideLoader.loadAllGuides()
       
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
