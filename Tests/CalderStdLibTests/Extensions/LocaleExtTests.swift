import CalderStdLib
import Foundation
import Testing

struct LocaleExtTests {
    @Test func locales() {
        #expect(Locale.posix.identifier == "en_US_POSIX")
        #expect(Locale.en.identifier == "en")
    }
}
