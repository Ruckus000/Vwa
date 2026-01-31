import SwiftUI

struct LanguageToggle: View {
    @Binding var language: Language
    let colors: AppColors

    var body: some View {
        HStack(spacing: 0) {
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

                if lang == .ES {
                    Rectangle()
                        .fill(colors.borderStrong)
                        .frame(width: 2)
                }
            }
        }
        .background(colors.surface)
        .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: 2))
        .shadow(color: colors.shadow, radius: 0, x: 2, y: 2)
    }
}
