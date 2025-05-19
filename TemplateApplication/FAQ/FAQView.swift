import Spezi
import SwiftUI

struct FAQView: View {
    @Environment(FAQModule.self) private var faqModule
    @State private var searchText: String = ""

    private var filteredFAQItems: [FAQItem] {
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
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: Layout.Spacing.medium, pinnedViews: []) {
                    SearchBarView(text: $searchText)
                        .padding(.top, Layout.Spacing.large)
                        .padding(.bottom, Layout.Spacing.xLarge)

                    ForEach(filteredFAQItems) { item in
                        FAQRowView(item: item)
                    }
                }
                .padding(.horizontal, Layout.Spacing.large)
                .padding(.bottom, Layout.Spacing.xLarge) // Additional bottom padding for safe area
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: Layout.Spacing.xLarge+15) // Prevents tab bar overlap
            }
        }
    }
}

#if DEBUG
#Preview("FAQ View") {
    let faqModule = FAQModule()
    faqModule.configure()

    return NavigationStack {
        FAQView()
            .environment(faqModule)
    }
}
#endif
