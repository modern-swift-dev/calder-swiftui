#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
@testable import CalderSwiftUI
import Foundation
import SwiftUI
import Testing

@Suite(.serialized) struct NSImageTests {

    @Test func `ns image as swift UI image returns image`() throws {
        let nsImage = try #require(NSImage(systemSymbolName: "star", accessibilityDescription: nil))
        let swiftUIImage = nsImage.asSwiftUIImage
        #expect(type(of: swiftUIImage) == Image.self)
    }

    @Test func `ns image as swift UI image with filled symbol`() throws {
        let nsImage = try #require(NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil))
        let swiftUIImage = nsImage.asSwiftUIImage
        #expect(type(of: swiftUIImage) == Image.self)
    }

    @Test func `ns image as swift UI image can be used in view`() throws {
        let nsImage = try #require(NSImage(systemSymbolName: "gear", accessibilityDescription: nil))
        let swiftUIImage = nsImage.asSwiftUIImage
        _ = swiftUIImage
            .resizable()
            .frame(width: 50, height: 50)
    }

    @Test func `ns image as swift UI image with modifiers`() throws {
        let nsImage = try #require(NSImage(systemSymbolName: "person", accessibilityDescription: nil))
        let swiftUIImage = nsImage.asSwiftUIImage
        _ = swiftUIImage
            .renderingMode(.template)
            .foregroundStyle(.blue)
    }

    @Test func `blank NS image conversion`() {
        let nsImage = NSImage(size: NSSize(width: 1, height: 1))
        let swiftUIImage = nsImage.asSwiftUIImage
        #expect(type(of: swiftUIImage) == Image.self)
    }

    @Test func `colored NS image conversion`() {
        let size = NSSize(width: 10, height: 10)
        let nsImage = NSImage(size: size)
        nsImage.lockFocus()
        NSColor.red.setFill()
        NSRect(origin: .zero, size: size).fill()
        nsImage.unlockFocus()

        let swiftUIImage = nsImage.asSwiftUIImage
        #expect(type(of: swiftUIImage) == Image.self)
    }

    @Test func `ns image in V stack`() throws {
        let nsImage = try #require(NSImage(systemSymbolName: "star", accessibilityDescription: nil))
        _ = VStack {
            nsImage.asSwiftUIImage
            Text("Label")
        }
    }

    @Test func `ns image in H stack`() throws {
        let nsImage = try #require(NSImage(systemSymbolName: "star", accessibilityDescription: nil))
        _ = HStack {
            nsImage.asSwiftUIImage
            Text("Label")
        }
    }

    @Test func `multiple system images conversion`() throws {
        let icons = ["star", "heart", "person", "gear", "bell"]
        for iconName in icons {
            let nsImage = try #require(NSImage(systemSymbolName: iconName, accessibilityDescription: nil))
            let swiftUIImage = nsImage.asSwiftUIImage
            #expect(type(of: swiftUIImage) == Image.self)
        }
    }
}
// swiftlint:enable force_unwrapping
#endif

#endif
