#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if !os(watchOS) && canImport(UIKit)
        import CalderUIKit
        import Foundation
        import Testing
        import UIKit

        @Suite(.serialized)
        @MainActor struct NSLayoutXAxisAnchorExtTests {

            // MARK: - eq Tests

            @Test func `eq anchor`() {
                let view1 = UIView()
                let view2 = UIView()
                let constraint = view1.leadingAnchor.eq(view2.leadingAnchor)

                #expect(constraint.firstAnchor === view1.leadingAnchor)
                #expect(constraint.constant == 0)
            }

            @Test func `eq anchor with constant`() {
                let view1 = UIView()
                let view2 = UIView()
                let constraint = view1.trailingAnchor.eq(view2.trailingAnchor, constant: 10)

                #expect(constraint.constant == 10)
            }

            @Test func `eq center X anchors`() {
                let view1 = UIView()
                let view2 = UIView()
                let constraint = view1.centerXAnchor.eq(view2.centerXAnchor)

                #expect(constraint.firstAnchor === view1.centerXAnchor)
            }

            // MARK: - leq Tests

            @Test func `leq anchor`() {
                let view1 = UIView()
                let view2 = UIView()
                let constraint = view1.leadingAnchor.leq(view2.leadingAnchor)

                #expect(constraint.relation == .lessThanOrEqual)
                #expect(constraint.constant == 0)
            }

            @Test func `leq anchor with constant`() {
                let view1 = UIView()
                let view2 = UIView()
                let constraint = view1.trailingAnchor.leq(view2.trailingAnchor, constant: 20)

                #expect(constraint.constant == 20)
                #expect(constraint.relation == .lessThanOrEqual)
            }

            // MARK: - geq Tests

            @Test func `geq anchor`() {
                let view1 = UIView()
                let view2 = UIView()
                let constraint = view1.leadingAnchor.geq(view2.leadingAnchor)

                #expect(constraint.relation == .greaterThanOrEqual)
                #expect(constraint.constant == 0)
            }

            @Test func `geq anchor with constant`() {
                let view1 = UIView()
                let view2 = UIView()
                let constraint = view1.trailingAnchor.geq(view2.trailingAnchor, constant: 15)

                #expect(constraint.constant == 15)
                #expect(constraint.relation == .greaterThanOrEqual)
            }

            // MARK: - eqAfter Tests

            @Test func `eq after anchor`() {
                let view1 = UIView()
                let view2 = UIView()
                let constraint = view1.leadingAnchor.eqAfter(view2.trailingAnchor)

                #expect(constraint.firstAnchor === view1.leadingAnchor)
            }

            @Test func `eq after anchor with multiplier`() {
                let view1 = UIView()
                let view2 = UIView()
                let constraint = view1.leadingAnchor.eqAfter(view2.trailingAnchor, multiplier: 1.0)

                #expect(constraint.firstAnchor === view1.leadingAnchor)
            }

            // MARK: - leqAfter Tests

            @Test func `leq after anchor`() {
                let view1 = UIView()
                let view2 = UIView()
                let constraint = view1.leadingAnchor.leqAfter(view2.trailingAnchor)

                #expect(constraint.relation == .lessThanOrEqual)
            }

            @Test func `leq after anchor with multiplier`() {
                let view1 = UIView()
                let view2 = UIView()
                let constraint = view1.leadingAnchor.leqAfter(view2.trailingAnchor, multiplier: 2.0)

                #expect(constraint.relation == .lessThanOrEqual)
            }

            // MARK: - geqAfter Tests

            @Test func `geq after anchor`() {
                let view1 = UIView()
                let view2 = UIView()
                let constraint = view1.leadingAnchor.geqAfter(view2.trailingAnchor)

                #expect(constraint.relation == .greaterThanOrEqual)
            }

            @Test func `geq after anchor with multiplier`() {
                let view1 = UIView()
                let view2 = UIView()
                let constraint = view1.leadingAnchor.geqAfter(view2.trailingAnchor, multiplier: 0.5)

                #expect(constraint.relation == .greaterThanOrEqual)
            }

            // MARK: - Default System Spacing Multiplier Tests

            @Test func `eq after defaults to one system spacing`() {
                let spacing = layOutSpacing { leading, trailing in [trailing.leadingAnchor.eqAfter(leading.trailingAnchor)] }

                #expect(spacing > 0)
                #expect(spacing == oneSystemSpacing())
            }

            @Test func `leq after defaults to one system spacing`() {
                let spacing = layOutSpacing { leading, trailing in
                    [
                        trailing.leadingAnchor.leqAfter(leading.trailingAnchor),
                        lowPriority(trailing.leadingAnchor.constraint(equalTo: leading.trailingAnchor, constant: 100))
                    ]
                }

                #expect(spacing > 0)
                #expect(spacing == oneSystemSpacing())
            }

            @Test func `geq after defaults to one system spacing`() {
                let spacing = layOutSpacing { leading, trailing in
                    [
                        trailing.leadingAnchor.geqAfter(leading.trailingAnchor),
                        lowPriority(trailing.leadingAnchor.constraint(equalTo: leading.trailingAnchor))
                    ]
                }

                #expect(spacing > 0)
                #expect(spacing == oneSystemSpacing())
            }

            // MARK: - Helpers

            private func oneSystemSpacing() -> CGFloat {
                layOutSpacing { leading, trailing in [trailing.leadingAnchor.constraint(equalToSystemSpacingAfter: leading.trailingAnchor, multiplier: 1)] }
            }

            private func lowPriority(_ constraint: NSLayoutConstraint) -> NSLayoutConstraint {
                constraint.priority = .defaultLow
                return constraint
            }

            /// Lays out two side-by-side views and returns the horizontal gap between them.
            private func layOutSpacing(_ spacingConstraints: (_ leading: UIView, _ trailing: UIView) -> [NSLayoutConstraint]) -> CGFloat {
                let container = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 200))
                let leading = UIView()
                let trailing = UIView()
                for view in [leading, trailing] {
                    view.translatesAutoresizingMaskIntoConstraints = false
                    container.addSubview(view)
                    NSLayoutConstraint.activate([
                        view.topAnchor.constraint(equalTo: container.topAnchor),
                        view.widthAnchor.constraint(equalToConstant: 50),
                        view.heightAnchor.constraint(equalToConstant: 20)
                    ])
                }
                NSLayoutConstraint.activate([leading.leadingAnchor.constraint(equalTo: container.leadingAnchor)] + spacingConstraints(leading, trailing))
                container.layoutIfNeeded()
                return trailing.frame.minX - leading.frame.maxX
            }
        }
    #endif

#endif
