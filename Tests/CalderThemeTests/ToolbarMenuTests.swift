#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(watchOS)
@testable import CalderTheme
import SFSafeSymbols
import SwiftUI
import Testing

@Suite(.serialized)
@MainActor struct ToolbarMenuTests {

    @Test func `custom label menu constructs body`() {
        let menu = ToolbarMenu(placement: .primaryAction, enabled: true, variant: .regular, content: {
            Text("Action")
        }, label: {
            Label("Menu", systemImage: "ellipsis")
        })

        _ = menu.body
    }

    @Test func `text menu constructs body`() {
        let menu = ToolbarMenu(placement: .primaryAction, enabled: false, variant: .title, content: {
            Text("Action")
        }, text: "Menu")

        _ = menu.body
    }

    @Test func `image menu constructs body`() {
        let menu = ToolbarMenu(placement: .primaryAction, enabled: true, variant: .regular, content: {
            Text("Action")
        }, icon: Image(systemName: "ellipsis"))

        _ = menu.body
    }

    @Test func `symbol menu constructs body`() {
        let menu = ToolbarMenu(placement: .primaryAction, enabled: true, variant: .regular, content: {
            Text("Action")
        }, symbol: .ellipsisCircle)

        _ = menu.body
    }
}
#endif

#endif
