#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst) || os(watchOS) || os(visionOS)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct UIBezierPathExtTests {

    // MARK: - ovalOf Tests

    @Test func `init oval of centered`() {
        let size = CGSize(width: 100, height: 50)
        let path = UIBezierPath(ovalOf: size, centered: true)
        let bounds = path.bounds
        #expect(bounds.origin.x == -50)
        #expect(bounds.origin.y == -25)
        #expect(bounds.width == 100)
        #expect(bounds.height == 50)
    }

    @Test func `init oval of not centered`() {
        let size = CGSize(width: 100, height: 50)
        let path = UIBezierPath(ovalOf: size, centered: false)
        let bounds = path.bounds
        #expect(bounds.origin.x == 0)
        #expect(bounds.origin.y == 0)
        #expect(bounds.width == 100)
        #expect(bounds.height == 50)
    }

    @Test func `init oval of square centered`() {
        let size = CGSize(width: 60, height: 60)
        let path = UIBezierPath(ovalOf: size, centered: true)
        let bounds = path.bounds
        #expect(bounds.origin.x == -30)
        #expect(bounds.origin.y == -30)
    }

    @Test func `init oval of zero size`() {
        let size = CGSize.zero
        let path = UIBezierPath(ovalOf: size, centered: true)
        #expect(path.bounds.size == .zero)
    }

    // MARK: - rectOf Tests

    @Test func `init rect of centered`() {
        let size = CGSize(width: 100, height: 50)
        let path = UIBezierPath(rectOf: size, centered: true)
        let bounds = path.bounds
        #expect(bounds.origin.x == -50)
        #expect(bounds.origin.y == -25)
        #expect(bounds.width == 100)
        #expect(bounds.height == 50)
    }

    @Test func `init rect of not centered`() {
        let size = CGSize(width: 100, height: 50)
        let path = UIBezierPath(rectOf: size, centered: false)
        let bounds = path.bounds
        #expect(bounds.origin.x == 0)
        #expect(bounds.origin.y == 0)
        #expect(bounds.width == 100)
        #expect(bounds.height == 50)
    }

    @Test func `init rect of square centered`() {
        let size = CGSize(width: 80, height: 80)
        let path = UIBezierPath(rectOf: size, centered: true)
        let bounds = path.bounds
        #expect(bounds.origin.x == -40)
        #expect(bounds.origin.y == -40)
    }

    @Test func `init rect of zero size`() {
        let size = CGSize.zero
        let path = UIBezierPath(rectOf: size, centered: true)
        #expect(path.bounds.size == .zero)
    }
}
#endif

#endif
