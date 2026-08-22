#if canImport(SwiftUI)
import Foundation
import SwiftUI

public extension String {

    /// Return the localized string key
    var localizedKey: LocalizedStringKey {
        LocalizedStringKey(self)
    }
}

#endif
