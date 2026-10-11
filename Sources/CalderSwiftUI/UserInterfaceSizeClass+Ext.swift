#if canImport(SwiftUI)
    import Foundation
    import SwiftUI

    public extension UserInterfaceSizeClass? {

        /// Returns the value that matches this size class.
        ///
        /// - Parameters:
        ///   - compact: The value to use for a compact or unknown (`nil`) size class.
        ///   - regular: The value to use for a regular size class.
        /// - Returns: `regular` when the size class is `.regular`; otherwise, `compact`.
        func adaptiveValue(compact: CGFloat, regular: CGFloat) -> CGFloat {
            if self == .regular {
                return regular
            }

            return compact
        }

        /// The previous, misspelled name of ``adaptiveValue(compact:regular:)``.
        @available(*, deprecated, renamed: "adaptiveValue(compact:regular:)")
        func adaptativeValue(compact: CGFloat, regular: CGFloat) -> CGFloat {
            adaptiveValue(compact: compact, regular: regular)
        }

    }

    /// A pair of values for the compact and regular size classes, resolved for the current size class.
    public struct AdaptiveValue<DataType> {

        /// The size class that ``value`` resolves against. `nil` resolves to ``compact``.
        public var sizeClass: UserInterfaceSizeClass?
        /// The value for a compact or unknown size class.
        public let compact: DataType
        /// The value for a regular size class.
        public let regular: DataType

        /// Creates a size-class-dependent value.
        ///
        /// - Parameters:
        ///   - sizeClass: The size class to resolve against. Defaults to `.compact`.
        ///   - compact: The value for a compact or unknown size class.
        ///   - regular: The value for a regular size class.
        public init(sizeClass: UserInterfaceSizeClass? = .compact, compact: DataType, regular: DataType) {
            self.sizeClass = sizeClass
            self.compact = compact
            self.regular = regular
        }

        /// The value that matches ``sizeClass``: ``regular`` for `.regular`, otherwise ``compact``.
        public var value: DataType {
            if sizeClass == .regular {
                return regular
            }

            return compact
        }
    }

    /// The previous, misspelled name of ``AdaptiveValue``.
    @available(*, deprecated, renamed: "AdaptiveValue")
    public typealias AdaptativeValue<DataType> = AdaptiveValue<DataType>

#endif
