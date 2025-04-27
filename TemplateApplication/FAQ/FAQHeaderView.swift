import Foundation
import Spezi
import SwiftUI

struct FAQHeaderView: View {
    var body: some View {
        ZStack {
            // you could swap this out for a wavy Shape if you like...
            Color("PetroleumBlue")
            Text("FAQ")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(height: 220)
        .ignoresSafeArea(edges: .top)
    }
}

#if DEBUG
#Preview("FAQ Header") {
    FAQHeaderView()
        .previewLayout(.sizeThatFits)
}
#endif
