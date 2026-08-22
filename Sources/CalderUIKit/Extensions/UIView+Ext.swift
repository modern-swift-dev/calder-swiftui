#if canImport(Darwin)
#if !os(macOS) && !os(watchOS)
import CalderStdLib
import Foundation
import UIKit

public extension UIView {
    /// Fades the view in, making it visible.
    /// - Parameters:
    ///   - duration: The duration of the animation. Defaults to 0.4 seconds.
    ///   - options: The animation options. Defaults to `.curveEaseIn`.
    ///   - completion: An optional block to execute when the animation finishes.
    func fadeVisible(_ duration: TimeInterval = 0.4, options: UIView.AnimationOptions = .curveEaseIn, completion: ((Bool) -> Void)? = nil) {
        alpha = 0
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options,
            animations: {
                self.alpha = 1
            },
            completion: completion
        )
    }

    /// Fades the view out, making it invisible.
    /// - Parameters:
    ///   - duration: The duration of the animation. Defaults to 0.4 seconds.
    ///   - options: The animation options. Defaults to `.curveEaseOut`.
    ///   - completion: An optional block to execute when the animation finishes.
    func fadeInvisible(_ duration: TimeInterval = 0.4, options: UIView.AnimationOptions = .curveEaseOut, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options,
            animations: {
                self.alpha = 0
            },
            completion: completion
        )
    }

}

public extension UIView {
    /// Applies a gradient to the view's layer.
    /// - Parameters:
    ///   - startLocation: The normalized start location of the gradient (0.0 to 1.0). Defaults to 0.0.
    ///   - startPoint: The starting point of the gradient in the layer's coordinate space. Defaults to (0, 0).
    ///   - startColor: The starting color of the gradient.
    ///   - endLocation: The normalized end location of the gradient (0.0 to 1.0). Defaults to 1.0.
    ///   - endPoint: The ending point of the gradient in the layer's coordinate space. Defaults to (1, 1).
    ///   - endColor: The ending color of the gradient.
    ///   - type: The type of gradient. Defaults to `.axial`.
    func setViewGradient(
        startLocation: Double = 0.0,
        startPoint: CGPoint = CGPoint(x: 0, y: 0),
        startColor: UIColor,
        endLocation: Double = 1.0,
        endPoint: CGPoint = CGPoint(x: 1, y: 1),
        endColor: UIColor,
        type: CAGradientLayerType = .axial
    ) {
        let layer = CAGradientLayer()
        layer.type = type
        layer.masksToBounds = true
        layer.needsDisplayOnBoundsChange = true
        layer.frame = bounds
        layer.startPoint = startPoint
        layer.endPoint = endPoint
        layer.locations = [startLocation.asNumber, endLocation.asNumber]
        layer.colors = [startColor.cgColor, endColor.cgColor]

        self.layer.masksToBounds = true
        self.layer.needsDisplayOnBoundsChange = true
        self.layer.insertSublayer(layer, at: 0)
    }
}

public extension UIView {
    /// Finds and returns the first responder view within the view hierarchy.
    /// - Returns: The first responder `UIView`, or `nil` if no view is currently the first responder.
    func firstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }

        if let view = subviews.first(where: { $0.isFirstResponder }) {
            return view
        }

        for view in subviews {
            if let responder = view.firstResponder() {
                return responder
            }
        }

        return nil
    }
}

public extension UIView {
    /// Takes a screenshot of the view.
    /// - Returns: An `UIImage` representing the screenshot of the view.
    func takeScreenshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: frame.size, format: UIGraphicsImageRendererFormat.transparent())
        return renderer.image { [weak self] context in
            self?.layer.render(in: context.cgContext)
        }
    }
}
#endif

#endif
