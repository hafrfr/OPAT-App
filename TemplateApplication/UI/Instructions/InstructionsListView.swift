// InstructionsListView.swift
// Part of the OPAT @ Home application
//
// A clean, dynamic list of available instruction guides.
// Created by harre on 2025-04-27.
import Spezi
import SwiftUI
import SpeziAccount

struct InstructionsListView: View {
    @Environment(GuideModule.self) private var guideModule
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool
    
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
    
    var body: some View {
        NavigationStack { // Your existing NavigationStack
            PrimaryBackgroundView(title: "Instructions") { // This is the main content view
                GeometryReader { geometry in
                    ScrollView {
                        VStack {
                            Spacer(minLength: geometry.size.height * 0.1) // Adjust center starting point
                            VStack(spacing: Layout.Spacing.large) {
                                ForEach(guideModule.guides) { guide in
                                    NavigationLink(destination: GuideOverviewView(guide: guide)) {
                                        Text(guide.title)
                                            .font(FontTheme.button)
                                            .foregroundColor(ColorTheme.title)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(ColorTheme.listItemBackground)
                                            .cornerRadius(Layout.Radius.medium)
                                            .shadowStyle(ShadowTheme.card)
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
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
} // End of body
}


