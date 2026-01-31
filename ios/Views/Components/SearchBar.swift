import SwiftUI
import Combine

struct SearchBar: View {
    @Binding var text: String
    let colors: AppColors
    let debounceInterval: TimeInterval

    @State private var localText: String = ""
    @State private var debounceTask: Task<Void, Never>?

    init(text: Binding<String>, colors: AppColors, debounceInterval: TimeInterval = 0.3) {
        self._text = text
        self.colors = colors
        self.debounceInterval = debounceInterval
        self._localText = State(initialValue: text.wrappedValue)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(colors.textMuted)

            TextField("SEARCH...", text: $localText)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(colors.text)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onChangeCompat(of: localText) { newValue in
                    debounceSearch(newValue)
                }

            if !localText.isEmpty {
                Button {
                    localText = ""
                    text = ""
                    debounceTask?.cancel()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(colors.surface)
                        .frame(width: 24, height: 24)
                        .background(colors.textMuted)
                }
            }
        }
        .padding(12)
        .background(colors.surface)
        .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: 2))
        .shadow(color: colors.shadow, radius: 0, x: 2, y: 2)
    }

    private func debounceSearch(_ query: String) {
        debounceTask?.cancel()

        debounceTask = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(debounceInterval * 1_000_000_000))

                await MainActor.run {
                    text = query
                }
            } catch {
                // Cancelled - that's fine
            }
        }
    }
}
