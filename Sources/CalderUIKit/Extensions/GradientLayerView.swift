#if canImport(Darwin)
    #if !os(macOS) && !os(watchOS)
        import UIKit

        /// A non-interactive view backed by a `CAGradientLayer`, used by `UIView.setViewGradient` so the gradient
        /// follows its host view's bounds through autoresizing.
        final class GradientLayerView: UIView {

            override static var layerClass: AnyClass {
                CAGradientLayer.self
            }

            /// The backing gradient layer.
            var gradientLayer: CAGradientLayer {
                guard let gradientLayer = layer as? CAGradientLayer else {
                    preconditionFailure("GradientLayerView.layerClass must be CAGradientLayer")
                }
                return gradientLayer
            }

            override init(frame: CGRect) {
                super.init(frame: frame)
                isUserInteractionEnabled = false
                autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }

            @available(*, unavailable)
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
    #endif
#endif
