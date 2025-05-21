import Spezi
import SwiftUI
import SpeziAccount

struct FAQView: View {
    @Environment(FAQModule.self) private var faqModule
    @State private var searchText: String = ""
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool

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
            // Wrap your view's content in a NavigationStack
            NavigationStack {
                PrimaryBackgroundView(title: "FAQ") { // PrimaryBackgroundView is now inside the NavigationStack
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
                        Color.clear.frame(height: Layout.Spacing.xLarge + 15) // Prevents tab bar overlap
                    }
                }
                // Add the toolbar modifier here, attached to PrimaryBackgroundView
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if account?.signedIn ?? false { // Check if the account exists and user is signed in
                            AccountButton(isPresented: $presentingAccount)
                        }
                       
                    }
                }
 
            }
        }
    
       
    }


