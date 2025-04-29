//
//  ContactCard.swift
//  OPATApp
//
//  Created by Jacob Justad on 2025-04-28.
//
import Foundation
import SwiftUI

struct ContactCard: View {
    let contact: OpatContact

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.small) {
            Text(contact.name)
                .font(FontTheme.bodyBold) // Bold name
                .foregroundColor(ColorTheme.title)

            Text(contact.hospitalName)
                .font(FontTheme.body)
                .foregroundColor(ColorTheme.title.opacity(0.8))

            // Make phone number tappable
            if let phoneURL = URL(string: "tel:\(contact.phoneNumber.filter(\.isNumber))") {
                Link(destination: phoneURL) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text(contact.phoneNumber)
                    }
                    .font(FontTheme.body)
                    .foregroundColor(Color.blue) // Standard link color
                }
            } else {
                HStack { // Show even if not a valid link
                     Image(systemName: "phone")
                     Text(contact.phoneNumber)
                }
                .font(FontTheme.body)
                .foregroundColor(ColorTheme.title.opacity(0.8))
            }


            Text(contact.address)
                .font(FontTheme.body)
                .foregroundColor(ColorTheme.title.opacity(0.8))
        }
        // Apply standard card styling
        .frame(maxWidth: .infinity, alignment: .leading) // Ensure card takes full width
        .padding()
        .background(ColorTheme.listItemBackground)
        .cornerRadius(Layout.Radius.medium)
        .shadowStyle(ShadowTheme.card)
    }
}


// MARK: - Preview
#if DEBUG
#Preview {
    // Wrap in NavigationStack for title area context if needed
    // (although PrimaryBackgroundView handles title)
    NavigationStack
    {
        Contacts(presentingAccount: .constant(false))
           // Add mock Account environment if needed by AccountButton in preview
           // .environment(Account())
    }
}
#endif
