#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(watchOS) && canImport(UIKit)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct PinnableTests {

    // MARK: - UIView Pinnable Conformance Tests

    @Test func `ui view has leading anchor`() {
        let view = UIView()
        let pinnable: Pinnable = view
        #expect(pinnable.leadingAnchor === view.leadingAnchor)
    }

    @Test func `ui view has trailing anchor`() {
        let view = UIView()
        let pinnable: Pinnable = view
        #expect(pinnable.trailingAnchor === view.trailingAnchor)
    }

    @Test func `ui view has top anchor`() {
        let view = UIView()
        let pinnable: Pinnable = view
        #expect(pinnable.topAnchor === view.topAnchor)
    }

    @Test func `ui view has bottom anchor`() {
        let view = UIView()
        let pinnable: Pinnable = view
        #expect(pinnable.bottomAnchor === view.bottomAnchor)
    }

    @Test func `ui view has width anchor`() {
        let view = UIView()
        let pinnable: Pinnable = view
        #expect(pinnable.widthAnchor === view.widthAnchor)
    }

    @Test func `ui view has height anchor`() {
        let view = UIView()
        let pinnable: Pinnable = view
        #expect(pinnable.heightAnchor === view.heightAnchor)
    }

    @Test func `ui view has center X anchor`() {
        let view = UIView()
        let pinnable: Pinnable = view
        #expect(pinnable.centerXAnchor === view.centerXAnchor)
    }

    @Test func `ui view has center Y anchor`() {
        let view = UIView()
        let pinnable: Pinnable = view
        #expect(pinnable.centerYAnchor === view.centerYAnchor)
    }

    // MARK: - UILayoutGuide Pinnable Conformance Tests

    @Test func `ui layout guide has leading anchor`() {
        let guide = UILayoutGuide()
        let pinnable: Pinnable = guide
        #expect(pinnable.leadingAnchor === guide.leadingAnchor)
    }

    @Test func `ui layout guide has trailing anchor`() {
        let guide = UILayoutGuide()
        let pinnable: Pinnable = guide
        #expect(pinnable.trailingAnchor === guide.trailingAnchor)
    }

    @Test func `ui layout guide has top anchor`() {
        let guide = UILayoutGuide()
        let pinnable: Pinnable = guide
        #expect(pinnable.topAnchor === guide.topAnchor)
    }

    @Test func `ui layout guide has bottom anchor`() {
        let guide = UILayoutGuide()
        let pinnable: Pinnable = guide
        #expect(pinnable.bottomAnchor === guide.bottomAnchor)
    }

    @Test func `ui layout guide has width anchor`() {
        let guide = UILayoutGuide()
        let pinnable: Pinnable = guide
        #expect(pinnable.widthAnchor === guide.widthAnchor)
    }

    @Test func `ui layout guide has height anchor`() {
        let guide = UILayoutGuide()
        let pinnable: Pinnable = guide
        #expect(pinnable.heightAnchor === guide.heightAnchor)
    }

    @Test func `ui layout guide has center X anchor`() {
        let guide = UILayoutGuide()
        let pinnable: Pinnable = guide
        #expect(pinnable.centerXAnchor === guide.centerXAnchor)
    }

    @Test func `ui layout guide has center Y anchor`() {
        let guide = UILayoutGuide()
        let pinnable: Pinnable = guide
        #expect(pinnable.centerYAnchor === guide.centerYAnchor)
    }
}
#endif

#endif
