import Spezi
import SpeziAccount
import SwiftUI

struct InstructionsListView: View {
    @Environment(GuideModule.self) private var guideModule
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool

    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }

    var body: some View {
        NavigationStack {
            PrimaryBackgroundView(title: "Instructions") {
                ScrollView {
                    instructionListContent
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if account != nil {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var instructionListContent: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.large) { // more space *between* sections
            Spacer(minLength: Layout.Spacing.small) // tighter top

            ForEach(sortedCategories, id: \.self) { category in
                let guidesForCategory = guideModule.guides.filter { ($0.category ?? "Other") == category }

                if !guidesForCategory.isEmpty {
                    VStack(alignment: .leading, spacing: Layout.Spacing.small) {
                        Text(category)
                            .font(FontTheme.bodyBold)
                            .foregroundColor(ColorTheme.title)
                            .padding(.horizontal)
                            .padding(.top, Layout.Spacing.small)

                        VStack(spacing: Layout.Spacing.small) {
                            ForEach(guidesForCategory) { guide in
                                NavigationLink(destination: GuideOverviewView(guide: guide)) {
                                    Text(guide.title)
                                        .font(FontTheme.button)
                                        .foregroundColor(ColorTheme.title)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(ColorTheme.listItemBackground)
                                        .cornerRadius(Layout.Radius.medium)
                                        .shadowStyle(ShadowTheme.card)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            Spacer(minLength: Layout.Spacing.large) // consistent bottom padding
        }
    }


    // MARK: - Custom Category Order
    private var sortedCategories: [String] {
        let preferredOrder = [
            "Before Your Infusion",
            "During Infusion",
            "After Your Infusion",
            "Staying Safe"
        ]
        let available = Set(guideModule.guides.map { $0.category ?? "Other" })
        return preferredOrder.filter { available.contains($0) }
    }
}
