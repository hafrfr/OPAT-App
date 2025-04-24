//
//  SubstepProgressView.swift
//  TemplateApplication
//
//  Created by Jacob Justad on 2025-04-18.
//



import SwiftUI

struct SubstepProgressView: View {
    let totalSubsteps: Int
    let currentSubstepIndex: Int

    var body: some View {
        HStack(spacing: 10) { // Adjust spacing between dots
            ForEach(0..<totalSubsteps, id: \.self) { index in
                Circle()
                    .fill(index == currentSubstepIndex ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10) // Adjust dot size
            }
        }
        .padding(.vertical) // Add padding around the progress view
    }
}

#Preview {
    SubstepProgressView(totalSubsteps: 4, currentSubstepIndex: 1)
        .previewLayout(.sizeThatFits)
}
