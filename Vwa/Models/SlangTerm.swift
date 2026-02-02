import Foundation

struct SlangTerm: Identifiable, Codable {
    let id: Int
    let term: String
    let category: Category
    let definition: String
    let example: String?
    let translations: Translations
    let meta: TermMeta

    struct Translations: Codable {
        let ES: Translation
        let FR: Translation
    }

    struct Translation: Codable {
        let definition: String
        let example: String?
    }

    struct TermMeta: Codable {
        let thumbsUp: Int
        let thumbsDown: Int
        let author: String
        let addedOn: String
    }

    /// Get translation for selected language
    func translation(for language: Language) -> Translation {
        switch language {
        case .ES: return translations.ES
        case .FR: return translations.FR
        }
    }
}
