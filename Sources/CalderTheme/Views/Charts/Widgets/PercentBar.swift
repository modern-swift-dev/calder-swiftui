#if canImport(SwiftUI)
    import CalderStdLib
    import CalderSwiftUI
    import CalderUIKit
    import Foundation
    import SFSafeSymbols
    import SwiftUI

    /// A SwiftUI view that displays a progress bar along with numerical and percentage values.
    public struct PercentBar: View {

        /// The current theme, injected via Environment.
        @Environment(\.theme) private var theme

        /// The user's current locale, injected via Environment.
        @Environment(\.locale) var locale

        /// The number of completed items or the current value.
        public let value: UInt

        /// The total number of items or the maximum value.
        public let total: UInt

        private let unit: LocalizableText?

        /// An optional suffix text to display after the numerical values (e.g., "values").
        ///
        /// A suffix created from a `LocalizedStringResource` is resolved for the current locale.
        public var text: String? {
            unit?.resolved
        }

        /// A flag to determine if the percentage should be displayed.
        public var showPercent: Bool = true

        /// The horizontal size class of the environment.
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass

        /// The calculated percentage text, formatted for the user's locale.
        /// Returns `nil` if `showPercent` is `false` or if total is zero.
        public var percent: String? {
            guard showPercent else {
                return nil
            }
            guard total > 0 else {
                return nil
            }
            return (Double(value) / Double(total)).formatted(
                .percent
                    .precision(.integerAndFractionLength(integerLimits: 1 ... 3, fractionLimits: 0 ... 2))
                    .locale(locale)
            )
        }

        /// Initializes a `PercentBar` view.
        ///
        /// The bar shows the value and total formatted for the environment's locale, such as
        /// "1,200 / 5,000 values" in English, followed by the suffix.
        /// - Parameters:
        ///   - value: The number of completed items.
        ///   - total: The total number of items.
        ///   - text: Optional suffix text to display unchanged. Defaults to `nil`.
        ///   - percent: A boolean to control whether the percentage is shown. Defaults to `true`.
        public init(value: UInt, total: UInt, text: String? = nil, percent: Bool = true) {
            self.init(value: value, total: total, unit: text.map(LocalizableText.verbatim), percent: percent)
        }

        /// Initializes a `PercentBar` view with a localized suffix.
        ///
        /// The bar shows the value and total formatted for the environment's locale, followed by the
        /// suffix, which SwiftUI looks up in its bundle and table.
        /// - Parameters:
        ///   - value: The number of completed items.
        ///   - total: The total number of items.
        ///   - text: The localized suffix text to display.
        ///   - percent: A boolean to control whether the percentage is shown. Defaults to `true`.
        public init(value: UInt, total: UInt, text: LocalizedStringResource, percent: Bool = true) {
            self.init(value: value, total: total, unit: .localized(text), percent: percent)
        }

        private init(value: UInt, total: UInt, unit: LocalizableText?, percent: Bool) {
            self.value = value
            self.total = total
            self.unit = unit
            showPercent = percent
        }

        /// The progress text, such as "1,200 / 5,000 values", with both numbers formatted for `locale`.
        /// - Parameter locale: The locale used to format the value and total.
        /// - Returns: The text, looked up in the package's string catalog.
        func progressText(locale: Locale) -> LocalizedStringResource {
            let value = value.formatted(.number.locale(locale))
            let total = total.formatted(.number.locale(locale))
            var resource = switch unit {
                case nil:
                    LocalizedStringResource("percentBar.progress \(value) \(total)", bundle: .module)
                case let .verbatim(unit):
                    LocalizedStringResource("percentBar.progressWithUnit \(value) \(total) \(unit)", bundle: .module)
                case let .localized(unit):
                    LocalizedStringResource("percentBar.progressWithUnit \(value) \(total) \(unit)", bundle: .module)
            }
            resource.locale = locale
            return resource
        }

        /// The content and behavior of the view.
        public var body: some View {
            ProgressView(value: Double(value), total: Double(total), label: {
                HStack(spacing: .xxs) {
                    Text(progressText(locale: locale))
                        .font(.subheadline)
                        .foregroundStyle(theme.text1)

                    Spacer()

                    if showPercent, let percent {
                        Text(percent)
                            .font(.subheadline)
                            .foregroundStyle(theme.text1)
                    }
                }
                .padding(.vertical, .xxs)
            })
            .progressViewStyle(.linear)
        }
    }

#endif

#if canImport(SwiftUI)
    import CalderStdLib
    import SwiftUI

    #if DEBUG
        import SnapshotPreviews

        @MainActor enum PercentBarPreviews: PreviewProvider, SnapshotProvider {
            static let defaultLayout: PreviewSnapshotLayout = .device

            static var snapshots: [PreviewSnapshot] {
                PreviewSnapshot("with-text") {
                    PreviewContent()
                }
            }

            private struct PreviewContent: View {
                @Environment(\.theme) private var theme

                var body: some View {
                    VStack {
                        PercentBar(value: 1, total: 6, text: "values")
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(theme.backgroundGradient)
                    .environment(\.locale, .en)
                }
            }
        }
    #endif
#endif
