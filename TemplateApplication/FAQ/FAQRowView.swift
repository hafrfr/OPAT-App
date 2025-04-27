import SwiftUI
// SPEZI view looked not as good

struct FAQRowView: View {
    let item: FAQItem
    @State private var isExpanded: Bool = false // track if the answer is shown

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // Use spacing 0 and add padding later
            // Button to toggle expansion
            Button {
                withAnimation(.easeInOut(duration: 0.5) ) { // Add animation
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    // Question Text
                    Text(item.question)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)

                    Spacer() // USED to fill out
                    // Chevron icon indicating state
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.body.weight(.medium)) // Slightly bolder chevron
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 10) // Add padding for tap area and spacing
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain) // plain b avoid default button appearance
            // Answer Text
            if isExpanded {
                Text(item.answer)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 5) // Space between question and answer
                    .padding(.bottom, 10) // Space below the answer
                    
                
            }
        }
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
