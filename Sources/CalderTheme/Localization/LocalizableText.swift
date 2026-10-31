#if canImport(SwiftUI)
    import Foundation
    import SwiftUI

    /// Text that a component displays either verbatim or by looking it up in a string catalog.
    ///
    /// Components store this instead of a `String` so their `String` initializers keep rendering
    /// the text unchanged, while their `LocalizedStringResource` initializers are localized by
    /// SwiftUI using the environment's locale.
    enum LocalizableText: Equatable, Sendable {
        /// Text displayed exactly as given.
        case verbatim(String)

        /// Text looked up in the resource's bundle and table.
        case localized(LocalizedStringResource)

        /// A `Text` view displaying this text.
        var text: Text {
            switch self {
                case let .verbatim(string): Text(verbatim: string)
                case let .localized(resource): Text(resource)
            }
        }

        /// The text as a resource that resolves in any locale.
        ///
        /// Verbatim text becomes a resource that resolves to exactly that string in every locale, so callers
        /// can resolve every `LocalizableText` the same way, for example with `String(localized:)`.
        var resource: LocalizedStringResource {
            switch self {
                case let .verbatim(string): LocalizedStringResource("\(string)", bundle: .module)
                case let .localized(resource): resource
            }
        }

        /// The text resolved for the process locale, which can differ from the locale the text renders in.
        var resolved: String {
            switch self {
                case let .verbatim(string): string
                case let .localized(resource): String(localized: resource)
            }
        }
    }

    extension LocalizableText: Hashable {
        func hash(into hasher: inout Hasher) {
            switch self {
                case let .verbatim(string):
                    hasher.combine(0)
                    hasher.combine(string)
                case let .localized(resource):
                    hasher.combine(1)
                    hasher.combine(resource.key)
                    hasher.combine(resource.table)
            }
        }
    }

#endif
