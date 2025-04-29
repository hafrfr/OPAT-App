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
        // 24/7 Contacts
        OpatContact(
            name: "OPAT Nurse Hotline",
            phoneNumber: "031-123-4567", // Replace with actual number
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
        // Weekday Contacts
        OpatContact(
            name: "Dr. Eva Läkare",
            phoneNumber: "031-987-6543", // Replace with actual number
            hospitalName: "Östra Sjukhuset",
            address: "Journalvägen 10, 416 50 Göteborg",
            availability: "Weekdays 8 AM - 4 PM"
        ),
        OpatContact(
            name: "Clinic Front Desk",
            phoneNumber: "031-112-2334", // Replace with actual number
            hospitalName: "Sahlgrenska University Hospital",
            address: "Blå stråket 5, 413 45 Göteborg",
            availability: "Weekdays 8 AM - 4 PM"
        )
        // Add more contacts here...
    ]

    private var groupedContacts: [(availability: String, contacts: [OpatContact])] {

        let dictionary = Dictionary(grouping: contactsData, by: { $0.availability })
        return dictionary.map { (key, value) in
            (availability: key, contacts: value.sorted { $0.name < $1.name })
        }.sorted {
            // Custom sort order for groups if needed
            if $0.availability.contains("24/7") { return true }
            if $1.availability.contains("24/7") { return false }
            return $0.availability < $1.availability // Alphabetical otherwise
        }
    }

    // Environment and State (keep if needed)
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool

    // MARK: - Body
    var body: some View {
        // 4. Use PrimaryBackgroundView
        PrimaryBackgroundView(title: "Contacts") {
            // Use ScrollView for content
            ScrollView {
                // LazyVStack for efficient loading if list gets long
                LazyVStack(alignment: .leading, spacing: Layout.Spacing.large) {
                    // Iterate through the grouped contacts
                    ForEach(groupedContacts, id: \.availability) { group in
                        // Section Header (Availability)
                        Text(group.availability)
                            .font(FontTheme.title.weight(.semibold)) // Make header bold
                            .foregroundColor(ColorTheme.title)
                            .padding(.top) // Add space above headers
                            .padding(.horizontal) // Padding for the header text

                        // Contacts within this group
                        VStack(spacing: Layout.Spacing.medium) { // Stack cards vertically
                            ForEach(group.contacts) { contact in
                                ContactCard(contact: contact) // Use the helper view
                            }
                        }
                        .padding(.horizontal) // Padding for the group of cards
                    }
                }
                .padding(.bottom) // Padding below the last group
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

    // MARK: - Initialization
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
}




// MARK: - Preview
#if DEBUG
#Preview {

    NavigationStack{
        Contacts(presentingAccount: .constant(false))
           // .environment(Account())
    }

}
#endif
