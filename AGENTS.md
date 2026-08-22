# Repository guidelines

## Structure

- Keep each library in its matching target under `Sources/` and tests under `Tests/`.
- Preserve the platform guards and baselines declared in `Package.swift`.
- Put one top-level Swift type in a file when adding code. Do not reorganize migrated code only to enforce this rule.
- Keep `CalderUIKit`, `CalderSwiftUI`, and `CalderTheme` platform-specific. Foundational targets must not depend on them.

## Swift practices

- Prefer type-safe generics and value types. Use the narrowest practical access level.
- Use `@MainActor` for UI state and UI operations. Do not dispatch to the main queue manually.
- Treat `@unchecked Sendable`, `nonisolated(unsafe)`, detached tasks, and lock changes as exceptional. Add focused concurrency tests when they are necessary.
- Add DocC comments to new or modified public declarations. Document parameters, return values, errors, lifecycle, and concurrency constraints where they matter.
- Update the migration guide or product documentation when public behavior changes.

## Tests and validation

- Use Swift Testing and the matching test target.
- Use `@Suite(.serialized)` for tests that mutate global or framework state.
- Do not disable failing tests or suppress lint warnings. Fix the issue or ask for direction.
- Follow `.swiftformat` and `.swiftlint.yml`; format only files in scope.
- Run `make format`, `make lint`, and `make test` for Swift changes. Run the relevant platform target for platform-specific changes.
