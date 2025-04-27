import SwiftUI
import Spezi // Import Spezi to use @Environment

/// The main view displaying the list of FAQs with search functionality.
struct FAQView: View {
    // Get the FAQ data from the environment
    @Environment(FAQModule.self) private var faqModule
    @State private var searchText: String = ""

    // Computed property to filter FAQs based on search text
    private var filteredFAQItems: [FAQItem] {
        let sourceItems = faqModule.faqItems
        if searchText.isEmpty {
            return sourceItems
        } else {
            // Filter  question or answer containing search text (case-insensitive)
            return sourceItems.filter { item in
                item.question.localizedCaseInsensitiveContains(searchText) ||
                item.answer.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemGroupedBackground)
            VStack(spacing: 16) {
                FAQHeaderView()
                SearchBarView(text: $searchText)
                    .padding(.horizontal)
                     ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredFAQItems) { item in
                            FAQRowView(item: item)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}

// Preview for the Main FAQ View
#if DEBUG
#Preview("FAQ View") {
    // 1. Create the module instance for the preview
    let faqModule = FAQModule()
    // 2. Manually call configure() to load data in the preview
    faqModule.configure()

    // 3. Return the view and inject the module
    return FAQView()
        .environment(faqModule) // Inject the module instance
}
#endif
