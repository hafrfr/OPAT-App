// SpeziTemplateApplication/TemplateApplication/Instructions/InstructionStepView.swift
// (Forced Text Left Alignment)

import SwiftUI

struct InstructionStepView: View {
    let substep: SubStep

    var body: some View {
        VStack(alignment: .leading, spacing: 15) { // Keep overall leading alignment

            // --- Substep Title ---
            if let title = substep.title {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    // Force frame to max width and align text within it
                    .frame(maxWidth: .infinity, alignment: .leading)
                    // Ensure multiline text is also leading aligned
                    .multilineTextAlignment(.leading)
            }

            // --- Description ---
            Text(substep.description)
                .font(.body)
                .lineSpacing(5)
                // Force frame to max width and align text within it
                .frame(maxWidth: .infinity, alignment: .leading)
                // Ensure multiline text is also leading aligned
                .multilineTextAlignment(.leading)


            // --- Image ---
            // Images naturally center if frame is wider; keep as is or align if needed
            if let imageName = substep.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    // .frame(maxWidth: .infinity) // Max width allows centering
                    // If you wanted image left aligned too:
                     .frame(maxWidth: .infinity, alignment: .leading)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.vertical)
            }
        }
        // The parent ScrollView + padding in InstructionGuideView should provide context
    }
}

// Preview
#Preview {
    ScrollView { // Add ScrollView for realistic preview
        VStack {
            InstructionStepView(
                substep: SubStep(
                    title: "Wash Your Hands",
                    description: "• This is the first bullet point which might wrap.\n• This is a second bullet.",
                    imageName: "hand_wash_image"
                )
            )
            Divider()
            InstructionStepView(
                substep: SubStep(
                    title: "Short Title",
                    description: "This is a single short line.",
                    imageName: nil
                )
            )
        }
        .padding()
    }
}
