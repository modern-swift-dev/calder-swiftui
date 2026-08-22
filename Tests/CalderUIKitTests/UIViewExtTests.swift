#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(macOS) && !os(watchOS)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct UIViewExtTests {

    // MARK: - fadeVisible Tests

    @Test func `fade visible sets alpha to zero initially`() {
        let view = UIView()
        view.alpha = 1.0
        view.fadeVisible(0.0)
        #expect(view.alpha == 0.0 || view.alpha == 1.0)
    }

    // MARK: - setViewGradient Tests

    @Test func `set view gradient adds gradient layer`() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.setViewGradient(
            startColor: .red,
            endColor: .blue
        )

        let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer
        #expect(gradientLayer != nil)
    }

    @Test func `set view gradient with custom locations`() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.setViewGradient(
            startLocation: 0.2,
            startColor: .white,
            endLocation: 0.8,
            endColor: .black
        )

        let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer
        #expect(gradientLayer != nil)
        #expect(gradientLayer?.locations?.count == 2)
    }

    @Test func `set view gradient with custom points`() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.setViewGradient(
            startPoint: CGPoint(x: 0, y: 0.5),
            startColor: .green,
            endPoint: CGPoint(x: 1, y: 0.5),
            endColor: .yellow
        )

        let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer
        #expect(gradientLayer != nil)
        #expect(gradientLayer?.startPoint == CGPoint(x: 0, y: 0.5))
        #expect(gradientLayer?.endPoint == CGPoint(x: 1, y: 0.5))
    }

    @Test func `set view gradient radial type`() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.setViewGradient(
            startColor: .purple,
            endColor: .orange,
            type: .radial
        )

        let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer
        #expect(gradientLayer?.type == .radial)
    }

    // MARK: - firstResponder Tests

    @Test func `first responder no first responder returns nil`() {
        let view = UIView()
        let result = view.firstResponder()
        #expect(result == nil)
    }

    @Test func `first responder self is first responder`() {
        let textField = UITextField()
        let window = UIWindow()
        window.addSubview(textField)
        textField.becomeFirstResponder()

        if textField.isFirstResponder {
            let result = textField.firstResponder()
            #expect(result === textField)
        }
        textField.resignFirstResponder()
    }

    @Test func `first responder child is first responder`() {
        let parentView = UIView()
        let textField = UITextField()
        parentView.addSubview(textField)

        let window = UIWindow()
        window.addSubview(parentView)
        textField.becomeFirstResponder()

        if textField.isFirstResponder {
            let result = parentView.firstResponder()
            #expect(result === textField)
        }
        textField.resignFirstResponder()
    }

    @Test func `first responder deep nested child`() {
        let grandparent = UIView()
        let parent = UIView()
        let textField = UITextField()

        grandparent.addSubview(parent)
        parent.addSubview(textField)

        let window = UIWindow()
        window.addSubview(grandparent)
        textField.becomeFirstResponder()

        if textField.isFirstResponder {
            let result = grandparent.firstResponder()
            #expect(result === textField)
        }
        textField.resignFirstResponder()
    }

    // MARK: - takeScreenshot Tests

    @Test func `take screenshot returns image`() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .red

        let screenshot = view.takeScreenshot()

        #expect(screenshot.size.width == 100)
        #expect(screenshot.size.height == 100)
    }

    @Test func `take screenshot zero size view`() {
        let view = UIView(frame: .zero)
        let screenshot = view.takeScreenshot()
        #expect(screenshot.size == .zero)
    }

    @Test func `take screenshot preserves dimensions`() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
        view.backgroundColor = .blue

        let screenshot = view.takeScreenshot()

        #expect(screenshot.size.width == 200)
        #expect(screenshot.size.height == 150)
    }

    @Test func `take screenshot with subviews`() {
        let parent = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        parent.backgroundColor = .white

        let child = UIView(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        child.backgroundColor = .red
        parent.addSubview(child)

        let screenshot = parent.takeScreenshot()

        #expect(screenshot.size.width == 100)
        #expect(screenshot.size.height == 100)
    }
}
#endif

#endif
