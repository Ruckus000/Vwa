import SwiftUI

struct BrowseView: View {
    @EnvironmentObject private var store: TermStore
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var colors: AppColors {
        AppColors.forTheme(store.theme)
    }

    var filteredTerms: [SlangTerm] {
        TermSearch.filter(query: searchText, in: store.terms)
    }

    var body: some View {
        ZStack {
            colors.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Back Button
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                        Text("BACK")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(colors.primary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)

                // Title
                Text("BROWSE")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(colors.text)
                    .tracking(-2)
                    .padding(.horizontal, 20)

                Text("\(store.termCount) TERMS AVAILABLE")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(colors.textMuted)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 16)

                // Search
                SearchBar(text: $searchText, colors: colors)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                // List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(filteredTerms.enumerated()), id: \.element.id) { index, term in
                            listItemView(term: term, index: index)
                        }

                        if filteredTerms.isEmpty && !searchText.isEmpty {
                            emptyStateView
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func listItemView(term: SlangTerm, index: Int) -> some View {
        BrutalButton(colors: colors) {
            store.setTerm(term)
            dismiss()
        } content: {
            HStack(alignment: .center, spacing: 12) {
                // Index Badge
                ZStack {
                    Rectangle()
                        .fill(colors.accent)
                        .frame(width: 48, height: 48)
                        .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: 2))

                    Text(String(format: "%02d", index + 1))
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(Color(hex: "0D0D0D"))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(term.term.uppercased())
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(colors.text)
                        .tracking(-0.5)

                    Text(term.definition)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(colors.textMuted)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(colors.textMuted)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(colors.surface)
            .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: 2))
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Text("NO RESULTS FOR \"\(searchText.uppercased())\"")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(colors.textSecondary)

            Text("TRY A DIFFERENT TERM")
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(colors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(colors.surface)
        .overlay(Rectangle().stroke(colors.border, lineWidth: 2))
    }
}
