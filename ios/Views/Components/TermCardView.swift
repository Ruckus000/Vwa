import SwiftUI

struct TermCardView: View {
    let term: SlangTerm
    let language: Language
    let colors: AppColors
    let currentIndex: Int
    let totalTerms: Int

    var translation: SlangTerm.Translation {
        term.translation(for: language)
    }

    var termAccessibilityLabel: String {
        let categoryLabel = "Category: \(term.category.rawValue)"
        let termLabel = "Term: \(term.term)"
        let definitionLabel = "Definition: \(term.definition)"
        let translationLabel = "\(language.displayName) translation: \(translation.definition)"
        let progressLabel = "Term \(currentIndex + 1) of \(totalTerms)"

        return "\(categoryLabel). \(termLabel). \(definitionLabel). \(translationLabel). \(progressLabel)"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .space3) {
                // Category Tag
                Text(term.category.rawValue)
                    .font(.typeLabel)
                    .foregroundColor(Color(hex: "0D0D0D"))
                    .padding(.horizontal, .space3)
                    .padding(.vertical, .space1)
                    .background(colors.accent)
                    .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: .borderStandard))

                // Term
                Text(term.term.uppercased())
                    .font(.typeDisplayLg)
                    .foregroundColor(colors.text)
                    .tracking(.trackingTight)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                Text(term.definition)
                    .font(.typeBodyLg)
                    .lineSpacing(8)  // 1.5 line height ≈ 8pt spacing for 16pt font
                    .foregroundColor(colors.text)  // Primary text, not muted

                // Divider
                Rectangle()
                    .fill(colors.borderStrong)
                    .frame(height: .borderHeavy)

                // Translation
                Text(language.displayName)
                    .font(.typeLabel)
                    .foregroundColor(colors.primary)
                    .tracking(.trackingLoose)

                Text(translation.definition)
                    .font(.typeBodyLg)
                    .foregroundColor(colors.text)
                    .lineSpacing(6)

                // Example
                if let example = term.example {
                    exampleView(example: example)
                }

                Spacer(minLength: .space4)

                // Progress
                ProgressIndicator(
                    current: currentIndex,
                    total: totalTerms,
                    colors: colors
                )
            }
            .padding(.space4)
        }
        .brutalistCard(colors, heavy: true)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(termAccessibilityLabel)
    }

    @ViewBuilder
    private func exampleView(example: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("EXAMPLE")
                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                .foregroundColor(colors.textMuted)
                .tracking(.trackingLoose)

            Text("\"\(example)\"")
                .font(.typeBody)
                .italic()
                .foregroundColor(colors.textSecondary)

            if let translatedExample = translation.example {
                Rectangle()
                    .fill(colors.border)
                    .frame(height: .borderSubtle)
                    .padding(.vertical, 6)

                HStack(alignment: .top, spacing: .space2) {
                    Text("->")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(colors.primary)

                    Text(translatedExample)
                        .font(.typeBody)
                        .foregroundColor(colors.text)
                }
            }
        }
        .padding(.space4)
        .background(colors.surfaceRaised)
        .overlay(Rectangle().stroke(colors.border, lineWidth: .borderSubtle))
    }
}
