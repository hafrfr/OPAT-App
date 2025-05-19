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
        // 24/7 contacts
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
        PrimaryBackgroundView(title: "Contacts") {
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
                .padding(.bottom, Layout.Spacing.xLarge+15) // Avoid tab overlap
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: Layout.Spacing.xLarge) // Adds breathing room
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
