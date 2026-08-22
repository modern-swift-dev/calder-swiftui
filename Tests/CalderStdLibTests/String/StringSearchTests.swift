import CalderStdLib
import Testing

struct StringSearchTests {
    @Test func `prefix search`() {
        #expect("Hello World".startingWith("Hello"))
        #expect(!"Hello World".startingWith("World"))
    }
}
