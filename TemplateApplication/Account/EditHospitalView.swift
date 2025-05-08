//
//  EditHospitalView.swift
//  OPATApp
//
//  Created by Jacob Justad on 2025-05-03.
//


import SwiftUI

struct EditHospitalView: View {
    let availableHospitals = [ // Or get this from a shared constants file
        "Sahlgrenska University Hospital",
        "Östra Sjukhuset"
    ].sorted()

    // Access the same @AppStorage variable used in AccountSheet
    @AppStorage("userSelectedHospital") private var selectedHospital: String = "Sahlgrenska University Hospital"
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Section("Select Your Hospital") {
                Picker("Hospital", selection: $selectedHospital) {
                    ForEach(availableHospitals, id: \.self) { hospital in
                        Text(hospital).tag(hospital)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }

            Section {
                 Text("Your selection is saved automatically on this device.")
                     .font(.caption)
                     .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Select Hospital")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    // Preview requires NavigationStack to show title and toolbar
    NavigationStack {
        EditHospitalView()
    }
}
#endif
