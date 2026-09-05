# ``CalderStdLib``

Swift type helpers used by Calder's UIKit and SwiftUI components.

The module contains only shared collection, date, numeric conversion, and string helpers required by those components.

`String.substr(start:len:)` counts characters, including extended grapheme clusters. Negative offsets or lengths and ranges extending beyond the string return the original string. A zero-length range at a valid position returns an empty string.
