import Spezi
import Observation
import Foundation

@Observable
final class FAQModule : Module, DefaultInitializable, EnvironmentAccessible  {
    var faqItems: [FAQItem] = []
    
    init() {}
    
    func configure() {
            loadFAQs()
            print("FAQModule configured with \(faqItems.count) items.")
        }
    private func loadFAQs() {
        self.faqItems = [
            FAQItem(
                question: "What is OPAT?",
                answer: """
                OPAT stands for Outpatient Parenteral Antimicrobial Therapy. It means you receive intravenous (IV) antibiotics \
                without needing to stay in the hospital, often in the comfort of your own home. This app helps guide you \
                through the process.
                """
            ),
            FAQItem(
                question: "When should I contact the doctor?",
                answer: """
                You should contact your doctor or care team immediately if you experience any of the following:
                • Fever or chills
                • Increased redness, swelling, pain, or discharge at your IV site
                • Difficulty breathing or shortness of breath
                • Severe headache or dizziness
                • Any other symptoms that concern you.
                """
            ),
            FAQItem(
                question: "How do I use the infusion pump?",
                answer: """
                Detailed instructions and videos on using your specific infusion pump can be found in the 'Instructions' \
                section of this app. Always refer to the guidance provided by your nurse or care team.
                """
            ),
            FAQItem(
                question: "What if I miss a dose?",
                answer: """
                Contact your OPAT care team as soon as possible if you miss a dose or have issues administering your \
                medication. Do not double up on doses unless specifically instructed to do so.
                """
            )
        ]
    }
}
