// File: TemplateApplication/UI/Instructions/GuideOverviewView.swift (Simplified Nav + Refactored + Extra Padding)
import SwiftUI

struct GuideOverviewView: View {
    let guide: Guide
    @Environment(\.dismiss) private var dismiss

    // MARK: - Main Body
    var body: some View {
        PrimaryBackgroundView(title: guide.title) {
            // Extracted ScrollView content
            guideStepsScrollView
        }
        // Apply safe area inset for the button to the PrimaryBackgroundView content
        .safeAreaInset(edge: .bottom) {
            bottomButtonArea
        }
        // No .navigationDestination needed
    }

    // MARK: - Private Computed Views

    // Extracted ScrollView containing the steps
    private var guideStepsScrollView: some View {
        ScrollView {
            VStack(spacing: Layout.Spacing.medium) {

                ForEach(Array(guide.steps.enumerated()), id: \.element.id) { index, mainStep in
                    NavigationLink {
                        DynamicInstructionFlow(
                            guide: guide,
                            startMainStepIndex: index,
                            startSubStepIndex: 0
                        )
                    } label: {
                        // Extracted Row Label View
                        guideStepRowLabel(title: mainStep.title)
                    }
                    .padding(.horizontal) // Padding outside the link card
                }
                // No Spacer needed here; ScrollView handles vertical extent
            } // End VStack
        } // End ScrollView
        .background(Color.clear) // Ensure ScrollView background is clear
    }

    // Extracted view for a single row's label content
    private func guideStepRowLabel(title: String) -> some View {
        HStack {
            Text(title)
                .font(FontTheme.body)
                .foregroundColor(ColorTheme.title)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding()
        .background(ColorTheme.listItemBackground)
        .cornerRadius(Layout.Radius.medium)
        .shadowStyle(ShadowTheme.card)
    }

    // Extracted view for the bottom button area within the safe area inset
    private var bottomButtonArea: some View {
         NavigationLink {
              DynamicInstructionFlow(
                  guide: guide,
                  startMainStepIndex: 0,
                  startSubStepIndex: 0
              )
          } label: {
              Text("Start from the beginning")
                  .font(FontTheme.button)
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(ColorTheme.buttonLarge)
                  .foregroundColor(.white)
                  .cornerRadius(Layout.Radius.medium)
          }
          .padding(.horizontal) // Padding for button side margins
          // --- ADD EXTRA BOTTOM PADDING ---
          // Add sufficient padding to lift above the tab bar. Adjust 30 if needed.
          .padding(.bottom, 30)
          // --- END EXTRA PADDING ---
          .padding(.top, 5) // Small padding above the button
          .background(.thinMaterial) // Background for the inset area
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    let sampleGuide = Guide(
        title: "OPAT Self-Administration",
        steps: [
            MainStep(title: "Step 1: Preparation", substeps: []),
            MainStep(title: "Step 2: Disinfecting", substeps: []),
            MainStep(title: "Step 3: Connecting", substeps: []),
            MainStep(title: "Step 4: Flushing", substeps: [])
        ]
    )

    // Wrap preview in NavigationStack AND a TabView mock if needed
    // to simulate the environment causing the overlap.
    NavigationStack {
        // Mock TabView structure for layout context
        TabView {
             GuideOverviewView(guide: sampleGuide)
                 .tabItem { Label("Instructions", systemImage: "list.bullet.clipboard") }
             Text("Other Tab")
                 .tabItem { Label("Other", systemImage: "square") }
        }
    }
}
#endif
