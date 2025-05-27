//
// This source file is part of the Stanford Spezi Template Application open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SpeziLicense
import SwiftUI


struct AccountSheet: View {
    // MARK: - Properties
    let availableHospitals = [
        "Sahlgrenska University Hospital",
        "Östra Sjukhuset"
    ].sorted()
    @AppStorage("userSelectedHospital") private var selectedHospital: String = "Sahlgrenska University Hospital"

    private let dismissAfterSignIn: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(Account.self) private var account
    @Environment(\.accountRequired) private var accountRequired

    @State private var isInSetup = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                if account.signedIn && !isInSetup {
                    signedInView
                } else {
                    setupView
                }
            }
        }
    }

    // MARK: - Subviews
    private var signedInView: some View {
        AccountOverview(close: .showCloseButton) {
            accountOptions
        }
    }

    private var accountOptions: some View {
        Group {
            NavigationLink {
                EditHospitalView()
            } label: {
                Label {
                        Text(selectedHospital.isEmpty ? "Not Set" : selectedHospital)
                    } icon: {
                        Image(systemName: "stethoscope")
                            .foregroundColor(ColorTheme.buttonLarge)
                    }
            }
            NavigationLink {
                ManageTreatmentsView()
            } label: {
                Label {
                    Text("Manage Treatments")
                } icon: {
                    Image(systemName: "list.bullet.clipboard")
                        .foregroundColor(ColorTheme.buttonLarge)
                }
            }
            NavigationLink {
                TreatmentProgressCalendarView()
            } label: {
                Label {
                    Text("Care Plan")
                } icon: {
                    Image(systemName: "calendar.and.person")
                        .foregroundColor(ColorTheme.buttonLarge)
                }
            }
            NavigationLink {
                ContributionsList(projectLicense: .mit)
            } label: {
                Text("License Information")
            }
        }
    }

    private var setupView: some View {
        AccountSetup { _ in
            if dismissAfterSignIn {
                dismiss()
            }
        } header: {
            AccountSetupHeader()
        }
        .onAppear {
            isInSetup = true
        }
        .toolbar {
            if !accountRequired {
                closeButton
            }
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var closeButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close") {
                dismiss()
            }
        }
    }

    // MARK: - Initialization
    init(dismissAfterSignIn: Bool = true) {
        self.dismissAfterSignIn = dismissAfterSignIn
    }
}

#if DEBUG
#Preview("AccountSheet") {
    var details = AccountDetails()
    details.userId = "william@chalmers.se"
    details.name = PersonNameComponents(givenName: "William", familyName: "Chalmers")
    
    return AccountSheet()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}

#Preview("AccountSheet SignIn") {
    AccountSheet()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
