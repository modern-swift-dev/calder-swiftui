import Foundation
import Testing

/// Checks that every key of CalderTheme's string catalog ships with every supported language.
struct StringCatalogCompletenessTests {
    private static let languages = ["en", "fr", "es"]

    private struct Catalog: Decodable {
        struct Entry: Decodable {
            struct Localization: Decodable {
                struct StringUnit: Decodable {
                    let value: String
                }

                let stringUnit: StringUnit?
            }

            let localizations: [String: Localization]?
        }

        let strings: [String: Entry]
    }

    /// The catalog next to the CalderTheme sources, read straight from the repository.
    private static var catalogURL: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/CalderTheme/Resources/Localizable.xcstrings")
    }

    /// The `key (language)` pairs of the catalog that have no value or an empty one, sorted.
    private static func incompleteEntries(in data: Data) throws -> [String] {
        let catalog = try JSONDecoder().decode(Catalog.self, from: data)
        return catalog.strings.flatMap { key, entry in
            languages.compactMap { language -> String? in
                let value = entry.localizations?[language]?.stringUnit?.value
                return value?.isEmpty == false ? nil : "\(key) (\(language))"
            }
        }.sorted()
    }

    @Test func `every key has an English, French and Spanish value`() throws {
        let data = try Data(contentsOf: Self.catalogURL)

        #expect(try Self.incompleteEntries(in: data).isEmpty)
    }

    @Test func `the catalog is not empty`() throws {
        let catalog = try JSONDecoder().decode(Catalog.self, from: Data(contentsOf: Self.catalogURL))

        #expect(!catalog.strings.isEmpty)
    }

    @Test func `a missing or empty language is reported`() throws {
        let catalog = """
        {"sourceLanguage":"en","version":"1.0","strings":{
          "complete":{"localizations":{
            "en":{"stringUnit":{"state":"translated","value":"A"}},
            "fr":{"stringUnit":{"state":"translated","value":"B"}},
            "es":{"stringUnit":{"state":"translated","value":"C"}}}},
          "noSpanish":{"localizations":{
            "en":{"stringUnit":{"state":"translated","value":"A"}},
            "fr":{"stringUnit":{"state":"translated","value":"B"}}}},
          "emptyFrench":{"localizations":{
            "en":{"stringUnit":{"state":"translated","value":"A"}},
            "fr":{"stringUnit":{"state":"translated","value":""}},
            "es":{"stringUnit":{"state":"translated","value":"C"}}}},
          "noLocalizations":{}}}
        """

        #expect(try Self.incompleteEntries(in: Data(catalog.utf8)) == [
            "emptyFrench (fr)", "noLocalizations (en)", "noLocalizations (es)", "noLocalizations (fr)", "noSpanish (es)"
        ])
    }
}
