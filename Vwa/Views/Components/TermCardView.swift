import SwiftUI

struct TermCardView: View {
    let term: SlangTerm
    let language: Language
    let colors: AppColors

    var translation: SlangTerm.Translation {
        term.translation(for: language)
    }

    var termAccessibilityLabel: String {
        [
            "Category: \(term.category.rawValue)",
            "Term: \(term.term)",
            "Definition: \(term.definition)",
            "\(language.displayName) translation: \(translation.definition)"
        ].joined(separator: ". ")
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

// MARK: - Preview

#Preview("Term Card - Dark") {
    TermCardView(
        term: SlangTerm(
            id: 1,
            term: "no cap",
            category: .truth,
            definition: "For real, no lie, I'm being completely serious",
            example: "That concert was amazing, no cap",
            translations: SlangTerm.Translations(
                ES: SlangTerm.Translation(
                    definition: "Expresión que significa 'en serio' o 'sin mentir'. Se usa para enfatizar que algo es completamente verdad.",
                    example: "Ese concierto estuvo increíble, en serio"
                ),
                FR: SlangTerm.Translation(
                    definition: "Expression signifiant 'sérieusement' ou 'sans mentir'. Utilisée pour souligner que quelque chose est absolument vrai.",
                    example: "Ce concert était incroyable, sans mentir"
                )
            ),
            meta: SlangTerm.TermMeta(thumbsUp: 100, thumbsDown: 5, author: "preview", addedOn: "2025-01-01")
        ),
        language: .ES,
        colors: .dark
    )
    .padding()
    .background(Color(hex: "0D0D0D"))
}
