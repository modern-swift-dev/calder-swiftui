#if canImport(SwiftUI)
    import Foundation

    extension LocalizedStringResource {
        /// The resource resolved with the resource's own locale, which defaults to the current locale.
        var resolvedText: String {
            String(localized: self)
        }
    }
#endif
