#if os(macOS)
import AppKit
import CalderTheme
import Observation
import SwiftUI
import Testing

@Suite(.serialized)
@MainActor struct InputNumericHostedTests {
    @Observable fileprivate final class Model {
        var integer: Int64? = 12
        var decimal: Double? = 12.5
    }

    private struct Content: View {
        let model: Model

        var body: some View {
            VStack {
                InputNumber(value: Binding(get: { model.integer }, set: { model.integer = $0 }), placeholder: "Integer")
                InputDecimal(value: Binding(get: { model.decimal }, set: { model.decimal = $0 }), placeholder: "Decimal", maxFractionDigits: 2)
            }
        }
    }

    @Test func `parent binding changes update mounted numeric fields`() async throws {
        let model = Model()
        let window = makeWindow(model: model)
        defer { window.close() }
        let content = try #require(window.contentView)
        try #require(await settles(content) { textField(in: content, placeholder: "Integer") != nil })
        let integer = try #require(textField(in: content, placeholder: "Integer"))
        let decimal = try #require(textField(in: content, placeholder: "Decimal"))
        #expect(integer.stringValue == "12")
        #expect(decimal.stringValue == "12.5")

        model.integer = 34
        model.decimal = 34.25
        #expect(await settles(content) { integer.stringValue == "34" && decimal.stringValue == "34.25" })

        model.integer = nil
        model.decimal = nil
        #expect(await settles(content) { integer.stringValue.isEmpty && decimal.stringValue.isEmpty })

        model.decimal = 12.346
        #expect(await settles(content) { decimal.stringValue == "12.35" })
        await drainUpdates(content)
        #expect(model.decimal == 12.346)
    }

    @Test func `mounted numeric fields preserve a minus sign while typing`() async throws {
        let model = Model()
        model.integer = nil
        model.decimal = nil
        let window = makeWindow(model: model)
        defer { window.close() }
        let content = try #require(window.contentView)
        try #require(await settles(content) { textField(in: content, placeholder: "Integer") != nil })
        let integer = try #require(textField(in: content, placeholder: "Integer"))
        let decimal = try #require(textField(in: content, placeholder: "Decimal"))

        edit(integer, text: "-")
        edit(decimal, text: "-")
        await drainUpdates(content)
        #expect(integer.stringValue == "-")
        #expect(decimal.stringValue == "-")
        #expect(model.integer == nil)
        #expect(model.decimal == nil)

        edit(integer, text: "-1")
        edit(decimal, text: "-1")
        #expect(await settles(content) { model.integer == -1 && model.decimal == -1 })
        edit(integer, text: "-12")
        edit(decimal, text: "-12.5")
        #expect(await settles(content) { model.integer == -12 && model.decimal == -12.5 })
        #expect(integer.stringValue == "-12")
        #expect(decimal.stringValue == "-12.5")
    }

    private func makeWindow(model: Model) -> NSWindow {
        _ = NSApplication.shared
        let window = NSWindow(contentRect: CGRect(x: 0, y: 0, width: 320, height: 160), styleMask: .borderless, backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: Content(model: model))
        window.contentView?.layoutSubtreeIfNeeded()
        return window
    }

    private func textField(in view: NSView, placeholder: String) -> NSTextField? {
        if let field = view as? NSTextField, field.placeholderString == placeholder {
            return field
        }
        for subview in view.subviews {
            if let field = textField(in: subview, placeholder: placeholder) {
                return field
            }
        }
        return nil
    }

    private func edit(_ field: NSTextField, text: String) {
        field.stringValue = text
        field.delegate?.controlTextDidChange?(Notification(name: NSControl.textDidChangeNotification, object: field))
    }

    private func settles(_ content: NSView, until condition: () -> Bool) async -> Bool {
        for _ in 0 ..< 50 {
            content.layoutSubtreeIfNeeded()
            if condition() {
                return true
            }
            try? await Task.sleep(for: .milliseconds(10))
        }
        return condition()
    }

    private func drainUpdates(_ content: NSView) async {
        for _ in 0 ..< 5 {
            content.layoutSubtreeIfNeeded()
            try? await Task.sleep(for: .milliseconds(10))
        }
    }
}
#endif
