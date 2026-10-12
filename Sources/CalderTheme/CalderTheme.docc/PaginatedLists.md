# Paginated lists

Load pages of results on demand and display them in a list, grouped into sections, or as a
selection.

## Overview

``PaginatedList`` is a namespace for a main-actor, observable data source and the views that
display it:

- ``PaginatedList/DataSource`` loads pages, stores the loaded items, and exposes the loading
  ``PaginatedList/DataSource/state``.
- ``PaginatedList/Results`` is one page of a paginated response. It decodes JSON with `count`,
  `next`, and `results` keys, and an optional `hasNext` key.
- ``PaginatedList/Continuous`` shows the items in one list, ``PaginatedList/Grouped`` shows them
  in sections, and ``PaginatedList/Selection`` lets people pick one or several items.

The lists request the next page when people scroll to the end, so you only describe how to load
the first page and how to load the page after a given one.

### Display a paginated list

Create the data source once, for example in `@State`, and configure its loaders when the view
appears. The next-page loader receives the most recent page, so it can follow that page's `next`
URL or cursor.

```swift
import CalderTheme
import SwiftUI

struct Article: Identifiable, Codable, Sendable {
    let id: Int
    var title: String
}

func fetchArticles(from url: URL) async throws -> PaginatedList.Results<Article> {
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(PaginatedList.Results<Article>.self, from: data)
}

struct ArticleList: View {
    @State private var dataSource = PaginatedList.DataSource<Article>(items: [])

    var body: some View {
        GenericStateView(state: dataSource.state) {
            PaginatedList.Continuous(dataSource: dataSource) { article in
                Text(article.wrappedValue.title)
            }
        }
        .task {
            await dataSource.configureAndLoad(
                firstPageLoader: {
                    try await fetchArticles(from: URL(string: "https://example.com/articles")!)
                },
                nextPageLoader: { page in
                    guard let next = page.next else {
                        return PaginatedList.Results(results: [])
                    }
                    return try await fetchArticles(from: next)
                }
            )
        }
    }
}
```

``GenericStateView`` shows a progress indicator while the first page loads, an empty or error
indicator when there are no items or the first page fails, and the list once items are available.
Call the data source's `reload()` to retry a failed first page, for example from a refresh action.

To show items in sections, pass a grouping key to ``PaginatedList/Grouped``:

```swift
struct ArticleSections: View {
    let dataSource: PaginatedList.DataSource<Article>

    var body: some View {
        PaginatedList.Grouped(
            dataSource: dataSource,
            groupBy: { article in String(article.wrappedValue.title.prefix(1)) }
        ) { article in
            Text(article.wrappedValue.title)
        }
    }
}
```

### Let people select items

``PaginatedList/Selection`` writes each change to a binding. Selecting an item in
``PaginatedList/Selection/Mode/single`` mode dismisses the view, while
``PaginatedList/Selection/Mode/multi(max:)`` keeps it presented.

```swift
struct ArticlePicker: View {
    let dataSource: PaginatedList.DataSource<Article>
    @Binding var isPresented: Bool
    @Binding var selectedArticles: [Article]

    var body: some View {
        PaginatedList.Selection(
            isPresented: $isPresented,
            selection: $selectedArticles,
            mode: .multi(max: 3),
            model: dataSource
        ) { article in
            Text(article.title)
        }
    }
}
```

`PaginatedList.Selection.Mode.multi(max:)` expresses no limit only with `nil`. A maximum of `0`
permits no new selections, while selected items can still be deselected. Once the limit is
reached, unselected items are disabled.

Selected `PaginatedList.Selection` rows carry the `isSelected` accessibility trait.

### Retry a failed next page

A failed next page in `PaginatedList.DataSource` keeps the loaded items and the current page.
Reaching the end of the list again never reloads the first page. The failure is exposed as
`nextPageError`, and the continuous and grouped lists show a row that retries the failed page.
The row's text comes from the CalderTheme string catalog.
The grouped list requests the next page when its end is reached, whichever sections the page fills.

### Cancel and replace content

Cancelling a first-page load or reload keeps the loaded items and restores the page and state
from before loading, so pagination continues and the load can be retried.

`PaginatedList.DataSource.replaceAll` discards results from requests started before it. Replacing
with a `Results` page makes it the current page; replacing with values ends pagination.

`PaginatedList.DataSource.append(item:after:)` moves and updates an item that is already
loaded instead of inserting a duplicate ID.

### Count items and decode pages

`PaginatedList.DataSource.count` is the total reported by the server. Every loaded page that
includes a count updates it, while local edits leave it unchanged. Use `items.count` for the number
of loaded items. A data source created with no items starts in the empty state.

`PaginatedList.Results` encodes `hasNext`. Decoding uses an explicit `hasNext` value when present
and otherwise derives it from `next` and `results`, so cursor-based APIs can return `hasNext`
without a `next` URL.
