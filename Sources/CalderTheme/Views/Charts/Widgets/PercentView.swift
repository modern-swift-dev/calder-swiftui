#if canImport(SwiftUI)
    import SwiftUI

    /// A SwiftUI view that displays a percentage as a filled circular segment.
    ///
    /// The view is a single accessibility element whose value is the percentage, formatted for the
    /// environment's locale.
    public struct PercentView: View {
        /// The user's locale, used to format the accessibility value.
        @Environment(\.locale) private var locale

        /// The percentage value, from 0.0 to 1.0 (will be clamped internally).
        let value: Double
        /// The overall radius of the circle.
        let radius: CGFloat
        /// The width of the circle's border.
        let borderWidth: CGFloat

        /// The value clamped to the documented 0.0 to 1.0 range.
        var clampedValue: Double {
            min(max(0, value), 1)
        }

        /// Initializes a `PercentView`.
        /// - Parameters:
        ///   - value: The percentage value (0.0 to 1.0). Values outside this range are clamped.
        ///   - radius: The overall radius of the circle. Defaults to 40.
        ///   - borderWidth: The width of the circle's border. Defaults to 1.0.
        public init(value: Double, radius: CGFloat = 40, borderWidth: CGFloat = 1.0) {
            self.value = value
            self.radius = radius
            self.borderWidth = borderWidth
        }

        /// The content and behavior of the view.
        public var body: some View {
            Circle()
                .strokeBorder(Color.accentColor, lineWidth: borderWidth)
                .overlay {
                    Path { path in
                        let center = CGPoint(x: radius * 0.5, y: radius * 0.5)

                        path.move(to: center)

                        path.addArc(
                            center: center,
                            radius: radius * 0.5,
                            startAngle: Angle(degrees: -90.0),
                            endAngle: Angle(degrees: -90.0) + Angle(degrees: clampedValue * 360),
                            clockwise: false
                        )

                    }
                    .fill(Color.accentColor.opacity(0.75))
                    .flipsForRightToLeftLayoutDirection(true)
                }
                .frame(width: radius, height: radius)
                .accessibilityElement(children: .ignore)
                .accessibilityValue(Text(verbatim: accessibilityPercent(locale: locale)))
        }

        /// Formats the clamped value as a percentage for assistive technologies.
        /// - Parameter locale: The locale used to format the percentage.
        /// - Returns: The localised percentage, such as "25%".
        func accessibilityPercent(locale: Locale) -> String {
            clampedValue.formatted(.percent.locale(locale))
        }
    }

#endif

#if canImport(SwiftUI)
    import SnapshotPreviews
    import SwiftUI

    #if DEBUG
        @MainActor enum PercentViewPreviews: PreviewProvider, SnapshotProvider {
            static let defaultLayout: PreviewSnapshotLayout = .device

            static var snapshots: [PreviewSnapshot] {
                PreviewSnapshot("default") {
                    PreviewContent()
                }
            }

            private struct PreviewContent: View {
                @Environment(\.theme) private var theme

                var body: some View {
                    HStack {
                        PercentView(value: 0)
                        PercentView(value: 0.25)
                        PercentView(value: 0.5)
                        PercentView(value: 0.75)
                        PercentView(value: 1)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(theme.backgroundGradient)
                }
            }
        }
    #endif
#endif
