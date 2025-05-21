//
// This source file is part of the Stanford Spezi Template Application open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziAccount
import SpeziContact
import SwiftUI


struct Contacts: View {
    private let contactsData: [OpatContact] = [
        OpatContact(
            name: "OPAT Nurse Hotline",
            phoneNumber: "031-123-4567",
            hospitalName: "Sahlgrenska University Hospital",
            address: "Blå stråket 5, 413 45 Göteborg",
            availability: "Available 24/7"
        ),
        OpatContact(
            name: "Emergency Services",
            phoneNumber: "112",
            hospitalName: "National Emergency",
            address: "Sweden",
            availability: "Available 24/7"
        ),
        OpatContact(
            name: "Dr. Eva Chalmers",
            phoneNumber: "031-987-6543",
            hospitalName: "Östra Sjukhuset",
            address: "Journalvägen 10, 416 50 Göteborg",
            availability: "Weekdays 8 AM - 4 PM"
        ),
        OpatContact(
            name: "Clinic Front Desk",
            phoneNumber: "031-112-2334",
            hospitalName: "Sahlgrenska University Hospital",
            address: "Blå stråket 5, 413 45 Göteborg",
            availability: "Weekdays 8 AM - 4 PM"
        )
    ]

    private var groupedContacts: [(availability: String, contacts: [OpatContact])] {
        let dictionary = Dictionary(grouping: contactsData, by: { $0.availability })
        return dictionary.map { (key, value) in
            (availability: key, contacts: value.sorted { $0.name < $1.name })
        }.sorted {
            if $0.availability.contains("24/7") { return true }
            if $1.availability.contains("24/7") { return false }
            return $0.availability < $1.availability
        }
    }

    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool
    

    var body: some View {
        // Wrap your view's content in a NavigationStack
        NavigationStack {
            PrimaryBackgroundView(title: "Contacts") { // PrimaryBackgroundView is now inside the NavigationStack
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: Layout.Spacing.large) {
                        ForEach(groupedContacts, id: \.availability) { group in
                            Text(group.availability)
                                .font(FontTheme.title.weight(.semibold))
                                .foregroundColor(ColorTheme.title)
                                .padding(.top)
                                .padding(.horizontal)

                            VStack(spacing: Layout.Spacing.medium) {
                                ForEach(group.contacts) { contact in
                                    ContactCard(contact: contact)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, Layout.Spacing.xLarge + 15) // Avoid tab overlap
                }
                .scrollDismissesKeyboard(.interactively)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: Layout.Spacing.xLarge) // Adds breathing room
                }
            }
            // The .toolbar is attached to PrimaryBackgroundView.
            // Since PrimaryBackgroundView is now a child of NavigationStack,
            // its toolbar items will populate the NavigationStack's navigation bar.
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // The AccountButton itself usually checks if the user is signed in.
                    // Your `if account != nil` is an additional safeguard.
                    if account?.signedIn ?? false { // More robust check for SpeziAccount
                        AccountButton(isPresented: $presentingAccount)
                    } else if account != nil { // Fallback if signedIn is not immediately available but account exists
                         // You might want to log or handle this case differently
                         // For now, let's assume AccountButton handles non-signed-in state gracefully
                         // or you might want to hide it if not signedIn
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
            }
            // If PrimaryBackgroundView's "title" prop is for its own internal display
            // and you want a standard navigation bar title, uncomment and use this:
            // .navigationTitle("Contacts")
            // If you use .navigationTitle, you might need to adjust PrimaryBackgroundView
            // to not show its own title to avoid duplication.
        }
    }

    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        Contacts(presentingAccount: .constant(false))
    }
}
#endif
