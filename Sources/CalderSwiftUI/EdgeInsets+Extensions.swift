#if canImport(SwiftUI)
import CalderUIKit
import Foundation
import SwiftUI

public extension EdgeInsets {

    static let zero = EdgeInsets(all: 0)

    init(vertical: CGFloat) {
        self.init(top: vertical, leading: 0, bottom: vertical, trailing: 0)
    }

    init(vertical: CGFloat, horizontal: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }

    init(horizontal: CGFloat) {
        self.init(top: 0, leading: horizontal, bottom: 0, trailing: horizontal)
    }

    init(all: CGFloat) {
        self.init(top: all, leading: all, bottom: all, trailing: all)
    }
}

public extension CGFloat {

    var asEdgeInsets: EdgeInsets {
        .init(all: self)
    }
}

public extension View {

    func padding(vertical: CGFloat) -> some View {
        padding(.init(vertical: vertical))
    }

    func padding(horizontal: CGFloat) -> some View {
        padding(.init(horizontal: horizontal))
    }

    func padding(vertical: CGFloat, horizontal: CGFloat) -> some View {
        padding(.init(vertical: vertical, horizontal: horizontal))
    }
}

#endif
