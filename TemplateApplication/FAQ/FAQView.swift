import Spezi
import SpeziAccount
import SwiftUI

// MARK: - Custom Pill Button Component
private struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(FontTheme.button)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? ColorTheme.buttonLarge : ColorTheme.listItemBackground)
                .foregroundColor(isSelected ? .white : ColorTheme.title)
                .cornerRadius(20)
                .shadowStyle(isSelected ? ShadowTheme.card : ShadowTheme.none)
        }
    }
}

// MARK: - FAQ View
struct FAQView: View {
    @Environment(FAQModule.self) private var faqModule
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool

    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All"

    private let categories = [
        "All", "Getting Started", "Daily Routine", "Using the Pump",
        "Troubleshooting", "Line Care & Hygiene", "Health & Safety",
        "Privacy & Security", "Empowerment"
    ]

    var body: some View {
        NavigationStack {
            PrimaryBackgroundView(title: "FAQ") {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: Layout.Spacing.medium) {
                        searchBar
                        categoryFilterPills
                        faqList
                    }
                    .padding(.horizontal, Layout.Spacing.large)
                    .padding(.bottom, Layout.Spacing.xLarge + 10)
                }
                .scrollDismissesKeyboard(.interactively)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: Layout.Spacing.xLarge + 15)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if account?.signedIn ?? false {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
            }
        }
    }

    // MARK: - Components
    private var searchBar: some View {
        SearchBarView(text: $searchText)
            .padding(.top, Layout.Spacing.large)
    }

    private var categoryFilterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    CategoryPill(
                        title: category,
                        isSelected: selectedCategory == category,
                        onTap: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, Layout.Spacing.large)
    }

    private var faqList: some View {
        ForEach(filteredFAQItems) { item in
            FAQRowView(item: item)
        }
    }

    // MARK: - Filter Logic
    private var filteredFAQItems: [FAQItem] {
        faqModule.faqItems.filter { item in
            let matchesSearch = searchText.isEmpty
                || item.question.localizedCaseInsensitiveContains(searchText)
                || item.answer.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == "All"
                || item.tags.contains(selectedCategory)
            return matchesSearch && matchesCategory
        }
    }
}
