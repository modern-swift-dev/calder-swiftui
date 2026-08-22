import Foundation

public extension Locale {
    /// The POSIX locale used for stable, locale-independent formatting.
    static let posix = Locale(identifier: "en_US_POSIX")

    // swiftlint:disable:next identifier_name
    /// The English locale used by component previews.
    static let en = Locale(identifier: "en")
}
