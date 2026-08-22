#if canImport(SwiftUI)
import Foundation
import SFSafeSymbols
import SwiftUI

public struct Icon: View {
    let symbol: SFSymbol

    public init(_ symbol: SFSymbol) {
        self.symbol = symbol
    }

    public var body: some View {
        Image(systemSymbol: symbol)
    }
}

#endif
