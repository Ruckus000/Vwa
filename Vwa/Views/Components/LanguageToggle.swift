import SwiftUI

struct LanguageToggle: View {
    @Binding var language: Language
    let colors: AppColors

    var body: some View {
        HStack(spacing: .space0) {
            ForEach(Language.allCases, id: \.self) { lang in
                Button {
                    language = lang
                } label: {
                    Text(lang.code)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(language == lang ? .white : colors.textSecondary)
                        .frame(width: 50, height: 36)
                        .background(language == lang ? colors.primary : Color.clear)
                }
                .accessibilityLabel("\(lang.displayName) translation")
                .accessibilityHint("Switch to \(lang.displayName) translations")
                .accessibilityAddTraits(language == lang ? [.isSelected] : [])

                if lang == .ES {
                    Rectangle()
                        .fill(colors.borderStrong)
                        .frame(width: .borderStandard, height: 36)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .background(colors.surface)
        .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: .borderStandard))
        .fixedSize()  // Prevent expansion - size to content only
        .brutalShadowSm(colors)
    }
}
