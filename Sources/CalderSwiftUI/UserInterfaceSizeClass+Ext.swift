#if canImport(SwiftUI)
import Foundation
import SwiftUI

public extension UserInterfaceSizeClass? {

    func adaptativeValue(compact: CGFloat, regular: CGFloat) -> CGFloat {
        if self == .regular {
            return regular
        }

        return compact
    }

}

public struct AdaptativeValue<DataType> {

    public var sizeClass: UserInterfaceSizeClass?
    public let compact: DataType
    public let regular: DataType

    public init(sizeClass: UserInterfaceSizeClass? = .compact, compact: DataType, regular: DataType) {
        self.sizeClass = sizeClass
        self.compact = compact
        self.regular = regular
    }

    public var value: DataType {
        if sizeClass == .regular {
            return regular
        }

        return compact
    }
}

#endif
