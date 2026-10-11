#if canImport(SwiftUI)
    import Foundation
    import SwiftUI

    /// A SwiftUI view that displays a percentage value within a circular progress indicator.
    ///
    /// The view is a single accessibility element whose value is the percentage, formatted for the
    /// environment's locale. Zero or negative values are announced as zero percent rather than "-".
    public struct PercentageCircle: View {
        /// The theme of the environment.
        @Environment(\.theme) private var theme

        /// The user's locale, used to format the accessibility value.
        @Environment(\.locale) private var locale

        /// The percentage value, from 0.0 to 1.0.
        public let percent: Double

        /// The radius of the circle.
        public let radius: CGFloat

        /// The width of the circle's border.
        public let width: CGFloat

        /// Formatted percentage text for the current locale. Returns "-" if percent is 0 or less.
        ///
        /// The circle itself displays the percentage formatted for the environment's locale.
        public var text: String {
            displayText(locale: .current)
        }

        /// Formats the percentage displayed inside the circle.
        /// - Parameter locale: The locale used to format the percentage.
        /// - Returns: The localised percentage, such as "25%", or "-" if percent is 0 or less.
        func displayText(locale: Locale) -> String {
            if percent <= 0 {
                return "-"
            }

            return percent.formatted(.percent.locale(locale))
        }

        /// Initializes a `PercentageCircle` view.
        /// - Parameters:
        ///   - percent: The percentage value (0.0 to 1.0).
        ///   - radius: The radius of the circle. Defaults to 50.
        ///   - width: The width of the circle's border. Defaults to 4.0.
        public init(percent: Double, radius: CGFloat = 50, width: CGFloat = 4.0) {
            self.percent = percent
            self.radius = radius
            self.width = width
        }

        /// The content and behavior of the view.
        public var body: some View {

            Text(verbatim: displayText(locale: locale))
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(theme.text1)
                .frame(width: radius * 2.0, height: radius * 2.0)
                .overlay(
                    Circle()
                        .stroke(theme.background3, style: StrokeStyle(lineWidth: width))
                        .overlay(
                            Circle()
                                .trim(from: max(0.0, 1.0 - percent), to: 1.0)
                                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: width))
                        )

                )
                .accessibilityElement(children: .ignore)
                .accessibilityValue(Text(verbatim: accessibilityPercent(locale: locale)))
        }

        /// Formats the percentage for assistive technologies, using zero in place of the visible "-".
        /// - Parameter locale: The locale used to format the percentage.
        /// - Returns: The localised percentage, such as "0%" or "25%".
        func accessibilityPercent(locale: Locale) -> String {
            max(0, percent).formatted(.percent.locale(locale))
        }
    }

#endif

#if canImport(SwiftUI)
    import SwiftUI

    #if DEBUG
        import SnapshotPreviews

        @MainActor enum PercentageCirclePreviews: PreviewProvider, SnapshotProvider {
            static let defaultLayout: PreviewSnapshotLayout = .device

            static var snapshots: [PreviewSnapshot] {
                PreviewSnapshot("zero") {
                    PreviewContent(percent: 0)
                }

                PreviewSnapshot("25") {
                    PreviewContent(percent: 0.25)
                }

                PreviewSnapshot("25-green") {
                    PreviewContent(percent: 0.25, accentColor: .green)
                }

                PreviewSnapshot("100") {
                    PreviewContent(percent: 1)
                }
            }

            private struct PreviewContent: View {
                @Environment(\.theme) private var theme

                let percent: Double
                var accentColor: Color?

                var body: some View {
                    VStack {
                        PercentageCircle(percent: percent)
                            .accentColor(accentColor)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(theme.backgroundGradient)
                }
            }
        }
    #endif
#endif
