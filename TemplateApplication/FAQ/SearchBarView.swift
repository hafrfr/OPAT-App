// SearchBarView.swift
// Updated to improve hit-testing for the clear button.

import SwiftUI
// Removed Spezi import as it's not used here

struct SearchBarView: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: Layout.Spacing.small) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ColorTheme.title.opacity(0.6))

            TextField("Search Help", text: $text)
                .font(FontTheme.body)
                .foregroundColor(ColorTheme.title)
                .autocorrectionDisabled()


            if !text.isEmpty {
                Button {
                    print("Clear button tapped!")
                    // -----------------------------------------
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ColorTheme.title.opacity(0.4))
                        .padding(5)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .contentShape(Rectangle()) // Define the tappable shape explicitly
                        // ------------------------------
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Layout.Spacing.medium)
        .background(ColorTheme.listItemBackground)
        .cornerRadius(Layout.Radius.medium)
        .shadowStyle(ShadowTheme.card)
    }
}

#if DEBUG
#Preview("Search Bar View") {
    SearchBarView(text: .constant("Test"))
        
}

#Preview("Search Bar Empty") {
    SearchBarView(text: .constant(""))
        
}
#endif
