// File: TemplateApplication/UI/Instructions/GuideOverviewView.swift (Dynamic Centering via Spacers - No ScrollView)
import SwiftUI

// InstructionFlowTarget struct (assuming defined elsewhere or here, and Hashable)
// struct InstructionFlowTarget: Hashable { ... }

struct GuideOverviewView: View {
    let guide: Guide
    @Environment(\.dismiss) private var dismiss

    // MARK: - Main Body
    var body: some View {
        PrimaryBackgroundView(title: guide.title) { // Use guide.t
            guideStepsContent // Use the extracted view
        }
        .safeAreaInset(edge: .bottom) {
            bottomButtonArea // Use the extracted view
        }
    }

    // MARK: - Private Computed Views

    // VStack containing the steps, now directly used as content
    private var guideStepsContent: some View {
        VStack(spacing: Layout.Spacing.medium) {
            Spacer() // Top spacer

            ForEach(Array(guide.steps.enumerated()), id: \.element.id) { index, mainStep in
                NavigationLink {
                    DynamicInstructionFlow(
                        guide: guide,
                        startMainStepIndex: index,
                        startSubStepIndex: 0
                    )
                } label: {
                    guideStepRowLabel(title: mainStep.title)
                }
            }
            .padding(.horizontal) // Apply horizontal padding to the ForEach content block

            Spacer() // Bottom spacer
        }
        // --- ADD OFFSET --- to make in middle
        .offset(y: -40)
        // --- END OFFSET ---
    }

    // guideStepRowLabel remains the same
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

    // bottomButtonArea remains the same
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
          .padding(.horizontal)
          .padding(.bottom, 30) // Keep padding to avoid tab bar
          .padding(.top, 5)
          .background(.thinMaterial)
    }
}
// MARK: - Preview
#if DEBUG
#Preview {
    let sampleGuide = Guide(
        title: "OPAT Self-Administration", // Corrected: guideTitle
        steps: [
            // Use 3-4 steps for preview to test centering without scrolling
            MainStep(title: "Step 1: Preparation", substeps: []),
            MainStep(title: "Step 2: Disinfecting", substeps: []),
            MainStep(title: "Step 3: Connecting", substeps: [])
           // MainStep(title: "Step 4: Flushing", substeps: []) // Keep short for preview
        ]
    )

    NavigationStack {
        TabView {
             GuideOverviewView(guide: sampleGuide)
                 .tabItem { Label("Instructions", systemImage: "list.bullet.clipboard") }
             Text("Other Tab")
                 .tabItem { Label("Other", systemImage: "square") }
        }
    }
}
#endif
