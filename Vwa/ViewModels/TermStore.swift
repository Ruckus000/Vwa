import Foundation
import Combine

final class TermStore: ObservableObject {
    // MARK: - Published State
    @Published private(set) var terms: [SlangTerm] = []
    @Published var currentIndex: Int = 0 {
        didSet { saveCurrentIndex() }
    }
    @Published var language: Language = .ES {
        didSet { saveLanguage() }
    }
    @Published var theme: Theme = .dark {
        didSet { saveTheme() }
    }
    @Published private(set) var loadError: String?

    // MARK: - Computed Properties
    var currentTerm: SlangTerm? {
        guard !terms.isEmpty, terms.indices.contains(currentIndex) else { return nil }
        return terms[currentIndex]
    }

    var termCount: Int { terms.count }

    // MARK: - UserDefaults Keys
    private enum Keys {
        static let language = "vwa.language"
        static let theme = "vwa.theme"
        static let currentIndex = "vwa.currentIndex"
    }

    // MARK: - Initialization
    init() {
        loadTerms()
        loadPreferences()
    }

    // MARK: - Data Loading
    private func loadTerms() {
        guard let url = Bundle.main.url(forResource: "terms", withExtension: "json") else {
            loadError = "Terms file not found in bundle"
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([SlangTerm].self, from: data)
            guard !decoded.isEmpty else {
                loadError = "No terms found in data file"
                return
            }
            self.terms = decoded
            self.loadError = nil
        } catch {
            loadError = "Failed to load terms: \(error.localizedDescription)"
        }
    }

    // MARK: - Navigation
    func nextTerm() {
        guard !terms.isEmpty else { return }
        currentIndex = (currentIndex + 1) % terms.count
    }

    func prevTerm() {
        guard !terms.isEmpty else { return }
        currentIndex = (currentIndex - 1 + terms.count) % terms.count
    }

    func setTerm(_ term: SlangTerm) {
        if let index = terms.firstIndex(where: { $0.id == term.id }) {
            currentIndex = index
        }
    }

    func setTermByIndex(_ index: Int) {
        guard terms.indices.contains(index) else { return }
        currentIndex = index
    }

    // MARK: - Persistence (with bounds checking)
    private func loadPreferences() {
        // Language
        if let langRaw = UserDefaults.standard.string(forKey: Keys.language),
           let savedLang = Language(rawValue: langRaw) {
            language = savedLang
        }

        // Theme
        if let themeRaw = UserDefaults.standard.string(forKey: Keys.theme),
           let savedTheme = Theme(rawValue: themeRaw) {
            theme = savedTheme
        }

        // Current index - BOUNDS CHECK to prevent crash on app updates
        let savedIndex = UserDefaults.standard.integer(forKey: Keys.currentIndex)
        if terms.isEmpty {
            currentIndex = 0
        } else {
            currentIndex = min(savedIndex, terms.count - 1)
        }
    }

    private func saveCurrentIndex() {
        UserDefaults.standard.set(currentIndex, forKey: Keys.currentIndex)
    }

    private func saveLanguage() {
        UserDefaults.standard.set(language.rawValue, forKey: Keys.language)
    }

    private func saveTheme() {
        UserDefaults.standard.set(theme.rawValue, forKey: Keys.theme)
    }
}
