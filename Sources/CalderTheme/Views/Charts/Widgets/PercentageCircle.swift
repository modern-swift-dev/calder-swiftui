#if canImport(SwiftUI)
import Foundation
import SwiftUI

/// A SwiftUI view that displays a percentage value within a circular progress indicator.
public struct PercentageCircle: View {
    /// The theme of the environment.
    @Environment(\.theme) private var theme

    /// The percentage value, from 0.0 to 1.0.
    public let percent: Double

    /// The radius of the circle.
    public let radius: CGFloat

    /// The width of the circle's border.
    public let width: CGFloat

    /// Formatted percentage text to display inside the circle. Returns "-" if percent is 0 or less.
    public var text: String {
        if percent <= 0 {
            return "-"
        }

        return percent.formatted(.percent)
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

        Text(text)
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

    }
}

#endif

#if canImport(SwiftUI)
import SnapshotPreviews
import SwiftUI

#if DEBUG
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
