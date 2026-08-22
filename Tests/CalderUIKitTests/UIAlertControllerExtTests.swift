#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(watchOS) && canImport(UIKit)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct UIAlertControllerExtTests {

    // MARK: - addAlertAction Tests

    @Test func `add alert action default style`() {
        let alert = UIAlertController(title: "Test", message: "Message", preferredStyle: .alert)
        alert.addAlertAction(title: "OK")

        #expect(alert.actions.count == 1)
        #expect(alert.actions.first?.title == "OK")
        #expect(alert.actions.first?.style == .default)
    }

    @Test func `add alert action cancel style`() {
        let alert = UIAlertController(title: "Test", message: "Message", preferredStyle: .alert)
        alert.addAlertAction(title: "Cancel", style: .cancel)

        #expect(alert.actions.count == 1)
        #expect(alert.actions.first?.title == "Cancel")
        #expect(alert.actions.first?.style == .cancel)
    }

    @Test func `add alert action destructive style`() {
        let alert = UIAlertController(title: "Test", message: "Message", preferredStyle: .alert)
        alert.addAlertAction(title: "Delete", style: .destructive)

        #expect(alert.actions.count == 1)
        #expect(alert.actions.first?.title == "Delete")
        #expect(alert.actions.first?.style == .destructive)
    }

    @Test func `add alert action multiple actions`() {
        let alert = UIAlertController(title: "Test", message: "Message", preferredStyle: .alert)
        alert.addAlertAction(title: "OK")
        alert.addAlertAction(title: "Cancel", style: .cancel)
        alert.addAlertAction(title: "Delete", style: .destructive)

        #expect(alert.actions.count == 3)
    }

    @Test func `add alert action action sheet`() {
        let alert = UIAlertController(title: "Test", message: "Message", preferredStyle: .actionSheet)
        alert.addAlertAction(title: "Option 1")
        alert.addAlertAction(title: "Option 2")
        alert.addAlertAction(title: "Cancel", style: .cancel)

        #expect(alert.actions.count == 3)
    }

    @Test func `add alert action with nil handler`() {
        let alert = UIAlertController(title: "Test", message: "Message", preferredStyle: .alert)
        alert.addAlertAction(title: "OK", action: nil)

        #expect(alert.actions.count == 1)
    }

    @Test func `add alert action with handler`() {
        let alert = UIAlertController(title: "Test", message: "Message", preferredStyle: .alert)
        var handlerCalled = false
        alert.addAlertAction(title: "OK") { _ in
            handlerCalled = true
        }

        #expect(alert.actions.count == 1)
        // Note: We can't easily test handler execution without presenting the alert
        #expect(handlerCalled == false) // Handler not called yet
    }
}
#endif

#endif
