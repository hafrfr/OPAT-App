// InstructionsListView.swift
// Part of the OPAT @ Home application
//
// A clean, dynamic list of available instruction guides.
// Created by harre on 2025-04-27.
import Spezi
import SwiftUI

struct InstructionsListView: View {
    @Environment(GuideModule.self) private var guideModule

    var body: some View {
        NavigationStack {
            PrimaryBackgroundView(title: "Instructions") {
                GeometryReader { geometry in
                    ScrollView {
                        VStack {
                            Spacer(minLength: geometry.size.height * 0.35) // Adjust center starting point
                            VStack(spacing: Layout.Spacing.large) {
                                ForEach(guideModule.guides) { guide in
                                    NavigationLink(destination: GuideOverviewView(guide: guide)) {
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
                            Spacer() // Fill remaining space below
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    // Preview needs a mock GuideModule instance
    let mockGuideModule = GuideModule()
    mockGuideModule.configure()
    return InstructionsListView()
        .environment(mockGuideModule) // Provide the mock module to the environment
}
#endif
