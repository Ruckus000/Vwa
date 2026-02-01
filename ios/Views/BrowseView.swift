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

            VStack(alignment: .leading, spacing: .space0) {
                // Back Button
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: .space2) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                        Text("BACK")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(colors.primary)
                }
                .accessibilityLabel("Back to main view")
                .accessibilityHint("Returns to the main phrase screen")
                .padding(.horizontal, .space5)
                .padding(.top, .space2)
                .padding(.bottom, .space4)

                // Title
                Text("BROWSE")
                    .font(.typeDisplayMd)
                    .foregroundColor(colors.text)
                    .tracking(.trackingTight)
                    .padding(.horizontal, .space5)

                Text("\(store.termCount) TERMS AVAILABLE")
                    .font(.typeMono)
                    .foregroundColor(colors.textMuted)
                    .padding(.horizontal, .space5)
                    .padding(.top, .space1)
                    .padding(.bottom, .space4)

                // Search
                SearchBar(text: $searchText, colors: colors)
                    .padding(.horizontal, .space5)
                    .padding(.bottom, .space4)

                // List
                ScrollView {
                    LazyVStack(spacing: .space3) {
                        ForEach(Array(filteredTerms.enumerated()), id: \.element.id) { index, term in
                            listItemView(term: term, index: index)
                        }

                        if filteredTerms.isEmpty && !searchText.isEmpty {
                            emptyStateView
                        }
                    }
                    .padding(.horizontal, .space5)
                    .padding(.bottom, .space6)
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
            HStack(alignment: .center, spacing: .space3) {
                // Index Badge
                ZStack {
                    Rectangle()
                        .fill(colors.accent)
                        .frame(width: 48, height: 48)
                        .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: .borderStandard))

                    Text(String(format: "%02d", index + 1))
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(Color(hex: "0D0D0D"))
                }

                VStack(alignment: .leading, spacing: .space1) {
                    Text(term.term.uppercased())
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(colors.text)
                        .tracking(-0.5)

                    Text(term.definition)
                        .font(.typeBodySm)
                        .foregroundColor(colors.textMuted)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(colors.textMuted)
            }
            .padding(.space4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(colors.surface)
            .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: .borderStandard))
        }
        .accessibilityLabel("Phrase \(index + 1): \(term.term). \(term.definition)")
        .accessibilityHint("Tap to view this phrase")
    }

    private var emptyStateView: some View {
        VStack(spacing: .space2) {
            Text("NO RESULTS FOR \"\(searchText.uppercased())\"")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(colors.textSecondary)

            Text("TRY A DIFFERENT TERM")
                .font(.typeMono)
                .foregroundColor(colors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.space6)
        .background(colors.surface)
        .overlay(Rectangle().stroke(colors.border, lineWidth: .borderStandard))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No search results for \(searchText)")
}
