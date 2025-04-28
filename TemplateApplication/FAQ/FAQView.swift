import SwiftUI
import Spezi

struct FAQView: View {
    @Environment(FAQModule.self) private var faqModule
    @State private var searchText: String = ""

    private var filteredFAQItems: [FAQItem] { // Assuming FAQItem is Identifiable
        let sourceItems = faqModule.faqItems
        if searchText.isEmpty {
            return sourceItems
        } else {
            return sourceItems.filter { item in
                item.question.localizedCaseInsensitiveContains(searchText) ||
                item.answer.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
            PrimaryBackgroundView(title: "FAQ") {
                VStack(spacing: 0) {  
                    SearchBarView(text: $searchText)
                        .padding(.top, Layout.Spacing.large)
                        .padding(.bottom, Layout.Spacing.xLarge)

                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: Layout.Spacing.medium) {
                            ForEach(filteredFAQItems) { item in
                                FAQRowView(item: item)

                            }
                        }
                        .padding(.bottom, Layout.Spacing.medium)
                    }
                }
            }
        }
    }

// Preview for the Main FAQ View
#if DEBUG
#Preview("FAQ View") {
    let faqModule = FAQModule()
    faqModule.configure() //  setup

    return NavigationStack { // Add NavigationStack if FAQRowView uses NavigationLink
        FAQView()
            .environment(faqModule) // Inject the module instance
    }
}
#endif
