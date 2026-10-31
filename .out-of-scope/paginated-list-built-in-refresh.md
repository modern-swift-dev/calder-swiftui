# Built-in pull-to-refresh in PaginatedList

`PaginatedList` views don't take a refresh parameter or install `.refreshable` themselves.

## Why this is out of scope

SwiftUI passes the refresh action down through the environment, so the `List` inside every `PaginatedList` view already picks up a `.refreshable` modifier applied from outside. `DataSource.reload()` is `async`, which is exactly what `.refreshable` expects, and since #108 the loaded items stay on screen while a refresh runs and a failed refresh keeps them and reports `refreshError`.

```swift
PaginatedList.Continuous(dataSource: dataSource) { $item in
    Text(item.title)
}
.refreshable {
    await dataSource.reload()
}
```

A built-in parameter would only rename this one line, and callers would lose control over what a refresh does (for example, refreshing other state at the same time). The pattern is documented in the PaginatedList DocC article.

## Prior requests

- #176: "Built-in refreshable in PaginatedList"
