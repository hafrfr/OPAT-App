// SpeziTemplateApplication/TemplateApplication/Instructions/SuppliesChecklistView.swift
// (Simplified Header)

import SwiftUI

struct SuppliesChecklistView: View {
    @State var items: [ChecklistItem]
    @Binding var navigationPath: NavigationPath
    var onComplete: () -> Void // Kept for clarity, triggers next step append
    @State private var allItemsChecked = false

    var body: some View {
        // Use standard List
        List {
            // Section header can replace the old custom header visually
            Section("Supplies Checklist") {
                 ForEach($items) { $item in
                     HStack {
                         Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                             .foregroundColor(item.isChecked ? .accentColor : .secondary)
                             .onTapGesture {
                                 item.isChecked.toggle()
                                 checkCompletion()
                             }
                         Image(item.iconName)
                             .resizable().scaledToFit().frame(width: 25, height: 25)
                             .padding(.leading, 5)
                         Text(item.name)
                         Spacer()
                     }
                     .padding(.vertical, 2)
                 }
            } // End Section
        }
        // Removed .listStyle(.plain) - default works well with Section
        // --- Use Standard Navigation Title ---
        .navigationTitle("Supplies Checklist")
        // Removed .navigationBarHidden / .navigationBarBackButtonHidden
        .safeAreaInset(edge: .bottom) {
             Button("Get Started") {
                 print("[Checklist] Get Started Tapped")
                 onComplete() // Call the closure to append next target
             }
             .buttonStyle(.borderedProminent)
             .padding()
             .disabled(!allItemsChecked)
        }
        .onAppear {
            checkCompletion()
        }
    }

    private func checkCompletion() {
        allItemsChecked = items.allSatisfy { $0.isChecked }
        print("[Checklist] checkCompletion - allItemsChecked: \(allItemsChecked)")
    }
}

#Preview {
    // Preview needs NavigationStack and dummy data/binding
    NavigationStack {
        SuppliesChecklistView(
            items: [ChecklistItem(name: "Wipes", iconName: "icon_alcohol_wipes")], // Sample
            navigationPath: .constant(NavigationPath()), // Dummy binding
            onComplete: { print("[Preview] Checklist Complete") }
        )
    }
}
