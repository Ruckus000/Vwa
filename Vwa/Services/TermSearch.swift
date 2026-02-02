import Foundation

struct TermSearch {

    // MARK: - Transcription Corrections

    /// Common voice transcription errors for slang terms
    private static let transcriptionCorrections: [String: String] = [
        // "no cap" variations
        "no cat": "no cap",
        "no cab": "no cap",
        "no calf": "no cap",
        "knock up": "no cap",
        "no clap": "no cap",

        // "bussin" variations
        "bussing": "bussin",
        "busting": "bussin",
        "buzzing": "bussin",
        "bus in": "bussin",
        "blessing": "bussin",

        // "lowkey" variations
        "low key": "lowkey",
        "low-key": "lowkey",
        "low ski": "lowkey",
        "loki": "lowkey",

        // "highkey" variations
        "high key": "highkey",
        "high-key": "highkey",
        "hi key": "highkey",

        // "deadass" variations
        "dead ass": "deadass",
        "dead as": "deadass",
        "that ass": "deadass",

        // "goated" variations
        "go to": "goated",
        "go did": "goated",
        "coated": "goated",
        "quoted": "goated",

        // "sus" variations
        "sauce": "sus",
        "suss": "sus",
        "such": "sus",

        // "fr fr" variations
        "for real for real": "fr fr",
        "far far": "fr fr",
        "fur fur": "fr fr",
        "efar efar": "fr fr",

        // "periodt" variations
        "period": "periodt",
        "period t": "periodt",

        // "rizz" variations
        "riz": "rizz",
        "rise": "rizz",
        "rizzle": "rizz",

        // "delulu" variations
        "the lulu": "delulu",
        "de lulu": "delulu",
    ]

    // MARK: - Public API

    /// Search for a term with fuzzy matching (for voice input)
    /// Returns the best match or nil if no good match found
    static func search(
        query: String,
        in terms: [SlangTerm]
    ) -> SlangTerm? {
        let normalizedQuery = normalize(query)

        guard !normalizedQuery.isEmpty else { return nil }

        // Step 1: Check transcription corrections first
        if let corrected = transcriptionCorrections[normalizedQuery],
           let match = terms.first(where: { normalize($0.term) == corrected }) {
            return match
        }

        // Step 2: Exact match
        if let exact = terms.first(where: { normalize($0.term) == normalizedQuery }) {
            return exact
        }

        // Step 3: Prefix match (user said start of term)
        if let prefix = terms.first(where: { normalize($0.term).hasPrefix(normalizedQuery) }) {
            return prefix
        }

        // Step 4: Contains match
        if let contains = terms.first(where: { normalize($0.term).contains(normalizedQuery) }) {
            return contains
        }

        // Step 5: Phonetic matching (sounds similar)
        if let phonetic = findPhoneticMatch(query: normalizedQuery, in: terms) {
            return phonetic
        }

        // Step 6: Levenshtein fuzzy match with SCALED threshold
        // Short terms need tighter matching to avoid false positives
        let threshold = calculateThreshold(for: normalizedQuery)

        var bestMatch: SlangTerm?
        var bestDistance = Int.max

        for term in terms {
            let termNormalized = normalize(term.term)
            let distance = levenshteinDistance(normalizedQuery, termNormalized)

            if distance <= threshold && distance < bestDistance {
                bestDistance = distance
                bestMatch = term
            }
        }

        return bestMatch
    }

    /// Filter terms for browse/search UI with debounce-friendly design
    /// Returns scored and sorted results
    static func filter(query: String, in terms: [SlangTerm]) -> [SlangTerm] {
        let normalizedQuery = normalize(query)

        guard !normalizedQuery.isEmpty else { return terms }

        // Use a more efficient single-pass scoring
        var results: [(term: SlangTerm, score: Int)] = []
        results.reserveCapacity(terms.count / 4) // Estimate ~25% will match

        let threshold = calculateThreshold(for: normalizedQuery)

        for term in terms {
            let termNormalized = normalize(term.term)

            // Exact match - highest priority
            if termNormalized == normalizedQuery {
                results.append((term, 100))
                continue
            }

            // Prefix match - high priority
            if termNormalized.hasPrefix(normalizedQuery) {
                results.append((term, 80))
                continue
            }

            // Contains match - medium priority
            if termNormalized.contains(normalizedQuery) {
                results.append((term, 60))
                continue
            }

            // Fuzzy match - lower priority, scaled by distance
            let distance = levenshteinDistance(normalizedQuery, termNormalized)
            if distance <= threshold {
                let score = 40 - (distance * 10)
                results.append((term, max(score, 10)))
                continue
            }

            // Definition contains query - lowest priority
            if normalize(term.definition).contains(normalizedQuery) {
                results.append((term, 20))
            }
        }

        // Sort by score descending
        results.sort { $0.score > $1.score }

        return results.map { $0.term }
    }

    // MARK: - Threshold Calculation

    /// Calculate appropriate Levenshtein threshold based on term length
    /// Short terms need stricter matching to avoid false positives
    private static func calculateThreshold(for query: String) -> Int {
        let length = query.count

        switch length {
        case 0...2:
            return 0  // "fr", "W", "L" - must be exact
        case 3:
            return 1  // "bet", "sus", "mid" - allow 1 error
        case 4...5:
            return 1  // "slay", "fire" - allow 1 error
        case 6...8:
            return 2  // "bussin", "lowkey" - allow 2 errors
        default:
            return 3  // longer terms - allow 3 errors
        }
    }

    // MARK: - Phonetic Matching

    /// Simple phonetic matching using Soundex-like approach
    /// Catches cases where transcription sounds right but spelled wrong
    private static func findPhoneticMatch(query: String, in terms: [SlangTerm]) -> SlangTerm? {
        let queryCode = simplePhoneticCode(query)

        for term in terms {
            let termCode = simplePhoneticCode(term.term)
            if queryCode == termCode && queryCode.count >= 2 {
                return term
            }
        }

        return nil
    }

    /// Very simple phonetic coding (not full Soundex, just key patterns)
    private static func simplePhoneticCode(_ text: String) -> String {
        var result = text.lowercased()

        // Normalize common sound patterns
        let replacements: [(String, String)] = [
            ("ph", "f"),
            ("ck", "k"),
            ("gh", ""),
            ("tion", "shun"),
            ("sion", "shun"),
            ("ss", "s"),
            ("ee", "e"),
            ("oo", "u"),
            ("ou", "u"),
            ("ow", "o"),
            ("ay", "a"),
            ("ey", "e"),
            ("ie", "e"),
            ("ea", "e"),
        ]

        for (pattern, replacement) in replacements {
            result = result.replacingOccurrences(of: pattern, with: replacement)
        }

        // Remove vowels except first character
        if result.count > 1 {
            let first = String(result.prefix(1))
            let rest = String(result.dropFirst())
            let consonantsOnly = rest.filter { !"aeiou".contains($0) }
            result = first + consonantsOnly
        }

        return result
    }

    // MARK: - Private Helpers

    private static func normalize(_ text: String) -> String {
        text
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "'", with: "'")
            .replacingOccurrences(of: "'", with: "'")
            .replacingOccurrences(of: "-", with: " ")
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// Optimized Levenshtein using two-row approach (O(min(m,n)) space)
    private static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Chars = Array(s1)
        let s2Chars = Array(s2)
        let m = s1Chars.count
        let n = s2Chars.count

        if m == 0 { return n }
        if n == 0 { return m }

        // Ensure s1 is the shorter string for space optimization
        if m > n {
            return levenshteinDistance(s2, s1)
        }

        // Use two rows instead of full matrix
        var previousRow = [Int](0...m)
        var currentRow = [Int](repeating: 0, count: m + 1)

        for j in 1...n {
            currentRow[0] = j

            for i in 1...m {
                let cost = s1Chars[i - 1] == s2Chars[j - 1] ? 0 : 1
                currentRow[i] = min(
                    previousRow[i] + 1,      // deletion
                    currentRow[i - 1] + 1,   // insertion
                    previousRow[i - 1] + cost // substitution
                )
            }

            swap(&previousRow, &currentRow)
        }

        return previousRow[m]
    }
}
