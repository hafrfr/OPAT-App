// SpeziTemplateApplication/TemplateApplication/Instructions/InstructionHeaderView.swift
// (Simplified Version)

import SwiftUI

struct InstructionHeaderView: View {
    let stepTitle: String // e.g., "Step 2"
    var onBack: () -> Void // Action for the back button

    var body: some View {
        HStack {
            // Back Button
            Button {
                onBack()
            } label: {
                Image(systemName: "chevron.left")
                    .imageScale(.large) 
                    .foregroundColor(.accentColor) // Use standard accent color
            }

            Spacer() // Pushes title to center

            // Step Title
            Text(stepTitle)
                .font(.headline) // Use a standard headline font
                .fontWeight(.semibold)

            Spacer() // Pushes button/title away from trailing edge

            // Placeholder for symmetrical spacing
            // Keep the button size consistent for balance
            Image(systemName: "chevron.left")
                .imageScale(.large)
                .opacity(0) // Invisible

        }
        .padding(.vertical, 10) // Add some vertical padding
        .padding(.horizontal) // Add horizontal padding
        // Removed all ZStack, background shapes, safe area logic etc.
    }
}

#Preview {
    InstructionHeaderView(stepTitle: "Step 2", onBack: { print("Back Tapped") })
        .previewLayout(.sizeThatFits) // Adjust preview layout
}
