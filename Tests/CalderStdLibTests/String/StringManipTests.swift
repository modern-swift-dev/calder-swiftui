@testable import CalderStdLib
import Testing

struct StringManipTests {
    @Test func substring() {
        #expect("Hello World".substr(start: 6, len: 5) == "World")
        #expect("Hello".substr(start: 0, len: 10) == "Hello")
    }
}
