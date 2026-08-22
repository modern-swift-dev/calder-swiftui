@testable import CalderStdLib
import Testing

struct CharacterExtTests {
    @Test func `integer conversion`() {
        #expect(Character("5").int == 5)
        #expect(Character("A").int == nil)
    }
}
