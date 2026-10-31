# PaginatedList selection by a set of IDs

`PaginatedList.Selection` keeps binding to an array of selected values, `Binding<[DataType]>`, rather than a `Set` of IDs.

## Why this is out of scope

Switching the binding to `Set<DataType.ID>` would break every caller of `Selection`, and the problem it was meant to solve is handled without that: since #119, selected items that disappear from the data source after a removal or reload are dropped from the selection, and the stored values are refreshed when items reload. Callers that only need IDs can map the array (`selection.map(\.id)`).

Keeping values in the selection also lets callers show selected items that are not currently loaded, such as items pre-selected from later pages.

## Prior requests

- #177: "PaginatedList selection by Set of IDs"
