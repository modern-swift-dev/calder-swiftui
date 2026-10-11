#if canImport(Darwin)
    import Foundation

    public extension CGFloat {

        /// A spacing value of 2 pixels.
        @inlinable static var xxxs: CGFloat {
            2.0
        }

        /// A spacing value of 4 pixels.
        @inlinable static var xxs: CGFloat {
            4.0
        }

        /// A spacing value of 8 pixels.
        @inlinable static var xs: CGFloat {
            8.0
        }

        /// A spacing value of 12 pixels.
        @inlinable static var spacingSmall: CGFloat {
            12.0
        }

        /// The previous name of ``spacingSmall``.
        ///
        /// Renamed because `.small` is a common member name that's easy to confuse with other APIs.
        @available(*, deprecated, renamed: "spacingSmall")
        @inlinable static var small: CGFloat {
            spacingSmall
        }

        /// A spacing value of 16 pixels.
        @inlinable static var spacingMedium: CGFloat {
            16.0
        }

        /// The previous name of ``spacingMedium``.
        ///
        /// Renamed because `.medium` is a common member name that's easy to confuse with other APIs.
        @available(*, deprecated, renamed: "spacingMedium")
        @inlinable static var medium: CGFloat {
            spacingMedium
        }

        /// A spacing value of 24 pixels.
        @inlinable static var spacingLarge: CGFloat {
            24.0
        }

        /// The previous name of ``spacingLarge``.
        ///
        /// Renamed because `.large` is a common member name that's easy to confuse with other APIs.
        @available(*, deprecated, renamed: "spacingLarge")
        @inlinable static var large: CGFloat {
            spacingLarge
        }

        /// A spacing value of 32 pixels.
        @inlinable static var xl: CGFloat {
            32.0
        }

        /// A spacing value of 48 pixels.
        @inlinable static var xxl: CGFloat {
            48.0
        }

        /// A spacing value of 60 pixels.
        @inlinable static var xxxl: CGFloat {
            60.0
        }
    }

#endif
