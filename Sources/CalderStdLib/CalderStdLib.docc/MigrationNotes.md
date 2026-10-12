# Behavior changes and migration

Adapt code that relies on string and collection helper behavior that changed.

## Overview

The [changelog](https://github.com/modern-swift-dev/calder-swiftui/blob/main/CHANGELOG.md) lists
the changes in each release across all Calder modules.

### Substrings

`String.substr(start:len:)` counts characters, including extended grapheme clusters. Negative
offsets or lengths return the original string. A range extending beyond the end of the string
returns only its in-range part, which is empty when the start is at or beyond the end. For example,
`"Hello".substr(start: 4, len: 2)` returns `"o"`.

### Hash maps

`Array.hashMap(predicate:)` rethrows errors from `predicate` instead of silently dropping the
element; callers that pass a throwing transform must now use `try`. When several elements produce
the same key, the last element wins.
