import SwiftUI
// Removed Spezi import as it's not used here

struct FAQRowView: View {
    let item: FAQItem // Assuming FAQItem has 'question' and 'answer' strings
    @State private var isExpanded: Bool = false

    var body: some View {

        VStack(alignment: .leading, spacing: 0) { // Keep spacing 0,
            Button {
                withAnimation(.easeInOut(duration: 0.3)) { // Slightly faster animation
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(item.question)
                        .font(FontTheme.faqQuestion)
                        .foregroundColor(ColorTheme.title)
                        .multilineTextAlignment(.leading)

                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.body.weight(.medium))
                        .foregroundColor(ColorTheme.title.opacity(0.6))
                }
        
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if isExpanded {
                Text(item.answer)
                    .font(FontTheme.body)
                    .foregroundColor(ColorTheme.title.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .padding(.top, Layout.Spacing.small)
            }
        }

        .font(FontTheme.button)
        .foregroundColor(ColorTheme.title)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(ColorTheme.listItemBackground)
        .cornerRadius(Layout.Radius.medium)
        .shadowStyle(ShadowTheme.card)

    }
}

// Preview for the Row View
#if DEBUG
#Preview("FAQ Row") {
    let faqModule = FAQModule()
    faqModule.configure()
    return List {
        FAQRowView(item: faqModule.faqItems[0])
        FAQRowView(item: faqModule.faqItems[1])
    }
}
#endif
