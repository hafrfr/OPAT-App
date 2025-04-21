//
// This source file is part of the Stanford Spezi Template Application open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SpeziScheduler
import SpeziSchedulerUI
import SpeziViews
import SwiftUI


struct OPATScheduleView: View {
    @Environment(Account.self) private var account: Account?
    @Environment(TemplateApplicationScheduler.self) private var scheduler: TemplateApplicationScheduler

    @State private var presentedEvent: Event?
    @Binding private var presentingAccount: Bool

    
    var body: some View {
        @Bindable var scheduler = scheduler

        NavigationStack {
            EventScheduleList { event in
                InstructionsTile(event) {
                    EventActionButton(event: event, "Start") {
                        presentedEvent = event
                    }
                }
            }
                .navigationTitle("Schedule")
                .viewStateAlert(state: $scheduler.viewState)
                .sheet(item: $presentedEvent) { event in
                    EventView(event)
                }
                .toolbar {
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
    @Previewable @State var presentingAccount = false

    OPATScheduleView(presentingAccount: $presentingAccount)
        .previewWith(standard: TemplateApplicationStandard()) {
            TemplateApplicationScheduler()
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
