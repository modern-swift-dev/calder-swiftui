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

    /// An optional suffix text to display after the numerical values (e.g., "values").
    public let text: String?

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
    /// - Parameters:
    ///   - value: The number of completed items.
    ///   - total: The total number of items.
    ///   - text: Optional suffix text to display. Defaults to `nil`.
    ///   - percent: A boolean to control whether the percentage is shown. Defaults to `true`.
    public init(value: UInt, total: UInt, text: String? = nil, percent: Bool = true) {
        self.value = value
        self.total = total
        self.text = text
        showPercent = percent
    }

    /// The content and behavior of the view.
    public var body: some View {
        ProgressView(value: Double(value), total: Double(total), label: {
            HStack(spacing: .xxs) {
                if let text {
                    Text(verbatim: "\(value) / \(total) \(text)")
                        .font(.subheadline)
                        .foregroundStyle(theme.text1)
                } else {
                    Text(verbatim: "\(value) / \(total)")
                        .font(.subheadline)
                        .foregroundStyle(theme.text1)
                }

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
import SnapshotPreviews
import SwiftUI

#if DEBUG
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
