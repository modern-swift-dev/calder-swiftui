#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(SwiftUI)
@testable import CalderSwiftUI
import Foundation
import SwiftUI
import Testing

@MainActor struct ViewExtensionsTests {

    // MARK: - eraseToAnyView

    @Test func `erase to any view returns any view`() {
        let view = Text("Hello")
        let anyView = view.eraseToAnyView()
        #expect(type(of: anyView) == AnyView.self)
    }

    @Test func `erase to any view with V stack`() {
        let view = VStack {
            Text("Line 1")
            Text("Line 2")
        }
        let anyView = view.eraseToAnyView()
        #expect(type(of: anyView) == AnyView.self)
    }

    @Test func `erase to any view with empty view`() {
        let view = EmptyView()
        let anyView = view.eraseToAnyView()
        #expect(type(of: anyView) == AnyView.self)
    }

    @Test func `erase to any view with image`() {
        let view = Image(systemName: "star")
        let anyView = view.eraseToAnyView()
        #expect(type(of: anyView) == AnyView.self)
    }

    @Test func `erase to any view preserves content`() {
        let originalText = "Test Content"
        let view = Text(originalText)
        _ = view.eraseToAnyView()
        // The AnyView wraps the original view - this test verifies compilation
    }

    // MARK: - modify

    @Test func `modify applies modification`() {
        let view = Text("Hello")
        let modified = view.modify { text in
            text.foregroundStyle(.red)
        }
        // Verify that modify returns a view (compilation test)
        _ = modified
    }

    @Test func `modify with conditional logic`() {
        let showBold = true
        let view = Text("Hello")
        let modified = view.modify { text in
            if showBold {
                text.bold()
            } else {
                text
            }
        }
        _ = modified
    }

    @Test func `modify with multiple modifiers`() {
        let view = Text("Hello")
        let modified = view.modify { text in
            text
                .font(.headline)
                .foregroundStyle(.blue)
        }
        _ = modified
    }

    @Test func `modify chained`() {
        let view = Text("Hello")
        let modified = view
            .modify { $0.bold() }
            .modify { $0.italic() }
        _ = modified
    }

    // MARK: - padding extensions

    @Test func `padding vertical`() {
        let view = Text("Hello")
        let padded = view.padding(vertical: 10)
        _ = padded
    }

    @Test func `padding horizontal`() {
        let view = Text("Hello")
        let padded = view.padding(horizontal: 20)
        _ = padded
    }

    @Test func `padding vertical and horizontal`() {
        let view = Text("Hello")
        let padded = view.padding(vertical: 10, horizontal: 20)
        _ = padded
    }

    @Test func `padding vertical with zero`() {
        let view = Text("Hello")
        let padded = view.padding(vertical: 0)
        _ = padded
    }

    @Test func `padding horizontal with zero`() {
        let view = Text("Hello")
        let padded = view.padding(horizontal: 0)
        _ = padded
    }

    @Test func `padding chained`() {
        let view = Text("Hello")
        let padded = view
            .padding(vertical: 5)
            .padding(horizontal: 10)
        _ = padded
    }

    // MARK: - ToolbarContent modify

    @Test func `toolbar content modify`() {
        _ = NavigationStack {
            Text("Content")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button("Action") {}
                    }
                    .modify { item in
                        item
                    }
                }
        }
    }

    @Test func `toolbar content modify with modification`() {
        _ = NavigationStack {
            Text("Content")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button("Action") {}
                    }
                    .modify { $0 }
                }
        }
    }

    // MARK: - ToolbarContent disableSharedbackground

    @Test func `toolbar content disable sharedbackground true`() {
        _ = NavigationStack {
            Text("Content")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button("Action") {}
                    }
                    .disableSharedbackground(disable: true)
                }
        }
    }

    @Test func `toolbar content disable sharedbackground false`() {
        _ = NavigationStack {
            Text("Content")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button("Action") {}
                    }
                    .disableSharedbackground(disable: false)
                }
        }
    }
}
#endif

#endif
