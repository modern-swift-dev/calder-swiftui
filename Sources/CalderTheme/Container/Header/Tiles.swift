#if canImport(SwiftUI)
import CalderStdLib
import CalderSwiftUI
import CalderUIKit
import SFSafeSymbols
import SnapshotPreviews
import SwiftUI

/// A SwiftUI view that arranges a primary `Tile` and a collection of secondary `Tile` views
/// in an adaptive layout, suitable for display within headers.
///
/// The layout adjusts based on the `UserInterfaceSizeClass`, allowing for flexible
/// presentation on different device sizes.
public struct Tiles: View {

    /// A closure that returns the primary `Tile` view. It receives the current
    /// `UserInterfaceSizeClass` to allow for adaptive configuration of the tile.
    public let primaryTile: (UserInterfaceSizeClass) -> Tile
    /// A closure that returns an array of secondary `Tile` views. It also receives
    /// the current `UserInterfaceSizeClass` for adaptive tile configuration.
    public let secondaryTiles: (UserInterfaceSizeClass) -> [Tile]

    /// Initializes a new `Tiles` view.
    ///
    /// - Parameters:
    ///   - primaryTile: A closure that provides the main tile for the layout.
    ///   - secondaryTiles: A closure that provides an array of supporting tiles.
    public init(
        primaryTile: @escaping (UserInterfaceSizeClass) -> Tile,
        secondaryTiles: @escaping (UserInterfaceSizeClass) -> [Tile]
    ) {
        self.primaryTile = primaryTile
        self.secondaryTiles = secondaryTiles
    }

    public var body: some View {
        AdaptativeStack { hclass in
            primaryTile(hclass ?? .compact)
                .modify {
                    if hclass == .regular {
                        $0.containerRelativeFrame(
                            .horizontal,
                            count: 3,
                            span: 2,
                            spacing: 0
                        )
                    } else {
                        $0
                    }
                }

            VStack(alignment: .leading, spacing: .xs) {
                ForEach(Array(secondaryTiles(hclass ?? .compact).enumerated()), id: \.offset) { tile in
                    tile.element
                }
            }
        }
    }
}

#endif

#if DEBUG
@MainActor enum TilesPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("Tiles") {
            List {
                Header(mode: .plain) {
                    VStack(alignment: .leading, spacing: .xs) {
                        Tiles { hclass in
                            Tile(icon: Image(systemSymbol: .checkmarkCircle), label: "To-Do", text: "12", variant: .info, expand: hclass == .regular, action: {})
                        } secondaryTiles: { _ in
                            [
                                Tile(icon: Image(systemSymbol: .xmarkOctagon), label: "Overdue", text: "12", variant: .error, action: {}),
                                Tile(icon: Image(systemSymbol: .xmarkOctagon), label: "Loading", text: "12", variant: .loading, action: {}),
                                Tile(icon: Image(systemSymbol: .xmarkOctagon), label: "Loading", text: "12", variant: .loading, action: {})
                            ]
                        }
                        MessageBox(variant: .info, icon: Image(systemSymbol: .exclamationmarkCircle), title: "This is important", message: .lorem(250))
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
#endif
