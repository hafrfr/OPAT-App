// SpeziTemplateApplication/TemplateApplication/OpatInstructionView.swift
// (Ensure it accepts and passes binding)

import SwiftUI

struct OpatInstructionView: View {
    let steps: [InstructionStep]
    // Accept the binding
    @Binding var navigationPath: NavigationPath

    var body: some View {
        // Pass the binding down to InstructionGuideView
        InstructionGuideView(steps: steps, navigationPath: $navigationPath)
    }
}

#Preview {
     // Preview needs NavigationStack and dummy data/binding
     struct PreviewWrapper: View {
         @State private var previewPath = NavigationPath()
         var body: some View {
             NavigationStack { // Use NavigationStack for preview context
                 OpatInstructionView(
                     steps: InstructionGuideDataSource.loadGuides().first!.steps, // Load sample
                     navigationPath: $previewPath // Dummy binding
                 )
             }
         }
     }
     return PreviewWrapper()
}
