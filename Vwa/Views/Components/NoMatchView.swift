import SwiftUI

struct NoMatchView: View {
    let searchedTerm: String
    let colors: AppColors
    let onBrowse: () -> Void
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(colors.textMuted)

            Text("NO MATCH FOR")
                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                .foregroundColor(colors.textMuted)
                .tracking(1)

            Text("\"\(searchedTerm)\"")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(colors.text)

            HStack(spacing: 12) {
                Button("Try Again") {
                    onRetry()
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(colors.textSecondary)

                Button("Browse") {
                    onBrowse()
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(colors.primary)
                .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: 2))
            }
        }
        .padding(20)
        .background(colors.surface)
        .overlay(Rectangle().stroke(colors.border, lineWidth: 2))
    }
}
