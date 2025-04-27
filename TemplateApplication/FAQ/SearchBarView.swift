//
//  SearchBarView.swift
//  OPATApp
//
//  Created by Jacob Justad on 2025-04-27.
//
import SwiftUI
import Spezi
struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search Help", text: $text)
                .autocorrectionDisabled()
        }
        .padding(10)
        .background(Color(.systemGray6))
        .overlay(
                    // BORDER
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
    }
}

#if DEBUG
#Preview("FAQ Row") {
    SearchBarView(text: .constant(""))
}
#endif
