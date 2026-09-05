@testable import CalderStdLib
import Testing

struct StringManipTests {
    @Test func substring() {
        #expect("Hello World".substr(start: 6, len: 5) == "World")
        #expect("Hello".substr(start: 0, len: 10) == "Hello")
    }

    @Test(arguments: [(-1, 1), (3, -1), (-1, -1), (Int.min, 1), (0, Int.min)]) func `negative offsets return original string`(start: Int, length: Int) {
        #expect("Hello".substr(start: start, len: length) == "Hello")
    }

    @Test func `empty and boundary substrings`() {
        #expect("".substr(len: 0) == "")
        #expect("Hello".substr(start: 5, len: 0) == "")
        #expect("Hello".substr(start: 6, len: 0) == "Hello")
        #expect("Hello".substr(start: 4, len: 2) == "Hello")
    }

    @Test func `substring respects grapheme clusters`() {
        #expect("A👨‍👩‍👧‍👦éZ".substr(start: 1, len: 2) == "👨‍👩‍👧‍👦é")
    }
}
