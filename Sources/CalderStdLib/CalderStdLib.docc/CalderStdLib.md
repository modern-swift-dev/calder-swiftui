# ``CalderStdLib``

Swift type helpers used by Calder's UIKit and SwiftUI components.

The module contains only shared collection, date, numeric conversion, and string helpers required by those components.

`String.substr(start:len:)` counts characters, including extended grapheme clusters. Negative offsets or lengths return the original string. A range extending beyond the end of the string returns only its in-range part, which is empty when the start is at or beyond the end. For example, `"Hello".substr(start: 4, len: 2)` returns `"o"`.

`Array.hashMap(predicate:)` rethrows errors from `predicate` instead of silently dropping the element; callers that pass a throwing transform must now use `try`. When several elements produce the same key, the last element wins.
