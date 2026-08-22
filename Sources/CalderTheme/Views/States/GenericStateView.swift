#if canImport(SwiftUI)
import CalderUIKit
import SFSafeSymbols
import SwiftUI

/// An enumeration of UI presentation states for a generic view,
/// covering initial, loading, empty, error, and displaying scenarios.
public enum GenericState {
    /// The initial state before any content is loaded.
    /// - Parameters:
    ///   - msg: An optional message to display.
    ///   - icon: An optional image shown alongside the message.
    case pristine(String? = nil, Image = Image(systemSymbol: .sparkles))
    /// Indicates that content is being loaded.
    case loading
    /// Indicates that content is ready and should be displayed.
    case displaying
    /// Indicates that no content is available.
    /// - Parameters:
    ///   - msg: An optional message to display.
    ///   - icon: An optional image shown alongside the message.
    case empty(String? = nil, Image = Image(systemSymbol: .binoculars))
    /// Indicates that an error occurred.
    /// - Parameters:
    ///   - msg: An optional error message.
    ///   - icon: An optional image shown alongside the error message.
    case error(String? = nil, Image = Image(systemSymbol: .exclamationmarkTriangle))
}

/// A SwiftUI view that adapts its layout and content based on a provided `GenericState`.
///
/// Provides built-in handling for loading indicators, empty or error messages,
/// and a customizable content view for the `.displaying` state.
public struct GenericStateView<BodyType: View>: View {
    @Environment(\.theme) var theme

    /// The current state driving the view's appearance.
    let state: GenericState

    /// A closure that builds the view to display when `state` is `.displaying`.
    @ViewBuilder let displayingBuilder: () -> BodyType

    /// Initializes a `GenericStateView` with a given state and content builder.
    ///
    /// - Parameters:
    ///   - state: The `GenericState` value that controls which UI is shown.
    ///   - displayingBuilder: A view builder closure that provides the content for the `.displaying` case.
    public init(state: GenericState, @ViewBuilder displayingBuilder: @escaping () -> BodyType) {
        self.state = state
        self.displayingBuilder = displayingBuilder
    }

    /// The view’s body, which switches on `state` to render the appropriate UI.
    public var body: some View {
        switch state {
            case let .pristine(msg, icon):
                VStack(spacing: .small) {
                    Spacer()

                    icon
                        .foregroundStyle(theme.primary)
                        .font(.title)

                    if let msg {
                        Text(verbatim: msg)
                            .font(.body)
                            .foregroundStyle(theme.text1)
                    }

                    Spacer()
                }
            case let .empty(msg, icon):
                VStack(spacing: .small) {
                    Spacer()

                    icon
                        .foregroundStyle(theme.warning)
                        .font(.title)

                    if let msg {
                        Text(verbatim: msg)
                            .font(.body)
                            .foregroundStyle(theme.text1)
                    }

                    Spacer()
                }
            case .displaying:
                displayingBuilder()
            case let .error(msg, icon):
                VStack(spacing: .small) {
                    Spacer()

                    icon
                        .foregroundStyle(theme.error)
                        .font(.title)

                    if let msg {
                        Text(verbatim: msg)
                            .font(.body)
                            .foregroundStyle(theme.text1)
                    }

                    Spacer()
                }
            case .loading:
                VStack(spacing: .small) {
                    Spacer()
                    ProgressView().progressViewStyle(.circular)
                    Spacer()
                }
        }
    }
}

#endif

#if canImport(SwiftUI)
import SFSafeSymbols
import SnapshotPreviews
import SwiftUI

#if DEBUG
@MainActor enum GenericStateViewPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("pristine") {
            GenericStateView(state: .pristine("Nothing to see yet", Image(systemSymbol: .binocularsFill))) {
                Text("Displaying")
            }
        }

        PreviewSnapshot("empty") {
            GenericStateView(state: .empty("Message", Image(systemSymbol: .binocularsFill))) {
                Text("Displaying")
            }
        }

        PreviewSnapshot("error") {
            GenericStateView(state: .error("Error", Image(systemSymbol: .exclamationmarkTriangle))) {
                Text("Displaying")
            }
        }

        PreviewSnapshot("loading") {
            GenericStateView(state: .loading) {
                Text("Displaying")
            }
        }

        PreviewSnapshot("displaying") {
            GenericStateView(state: .displaying) {
                Text("Displaying")
            }
        }
    }
}
#endif
#endif
