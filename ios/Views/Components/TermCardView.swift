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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Category Tag
                Text(term.category.rawValue)
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(Color(hex: "0D0D0D"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(colors.accent)
                    .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: 2))

                // Term
                Text(term.term.uppercased())
                    .font(.system(size: 42, weight: .black))
                    .foregroundColor(colors.text)
                    .tracking(-2)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                Text(term.definition)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(colors.textMuted)

                // Divider
                Rectangle()
                    .fill(colors.borderStrong)
                    .frame(height: 3)

                // Translation
                Text(language.displayName)
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(colors.primary)
                    .tracking(1)

                Text(translation.definition)
                    .font(.system(size: 16))
                    .foregroundColor(colors.text)
                    .lineSpacing(6)

                // Example
                if let example = term.example {
                    exampleView(example: example)
                }

                Spacer(minLength: 16)

                // Progress
                ProgressIndicator(
                    current: currentIndex,
                    total: totalTerms,
                    colors: colors
                )
            }
            .padding(16)
        }
        .brutalistCard(colors, heavy: true)
    }

    @ViewBuilder
    private func exampleView(example: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("EXAMPLE")
                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                .foregroundColor(colors.textMuted)
                .tracking(1)

            Text("\"\(example)\"")
                .font(.system(size: 14))
                .italic()
                .foregroundColor(colors.textSecondary)

            if let translatedExample = translation.example {
                Rectangle()
                    .fill(colors.border)
                    .frame(height: 1)
                    .padding(.vertical, 6)

                HStack(alignment: .top, spacing: 8) {
                    Text("->")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(colors.primary)

                    Text(translatedExample)
                        .font(.system(size: 14))
                        .foregroundColor(colors.text)
                }
            }
        }
        .padding(16)
        .background(colors.surfaceRaised)
        .overlay(Rectangle().stroke(colors.border, lineWidth: 2))
    }
}
