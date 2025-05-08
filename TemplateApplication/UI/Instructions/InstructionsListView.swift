// InstructionsListView.swift
// Part of the OPAT @ Home application
//
// A clean, dynamic list of available instruction guides.
// Created by harre on 2025-04-27.
import Spezi // Ensure Spezi is imported if needed elsewhere
import SwiftUI

struct InstructionsListView: View {
    // Inject the GuideModule using Spezi's @Environment
    @Environment(GuideModule.self) private var guideModule
 
    var body: some View {
            NavigationStack {
                PrimaryBackgroundView(title: "Instructions") {
                    VStack(spacing: Layout.Spacing.large) {
                        ForEach(guideModule.guides)  { guide in
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
                    .padding()
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
