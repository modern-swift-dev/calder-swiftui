#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
    import CalderUIKit
    import Foundation
    import Testing

    @MainActor struct NSViewConstraintsTests {

        // MARK: - Pinnable

        @Test func `ns view is pinnable`() {
            let view = NSView()
            let pinnable: any Pinnable = view
            #expect(pinnable.leadingAnchor === view.leadingAnchor)
            #expect(pinnable.trailingAnchor === view.trailingAnchor)
            #expect(pinnable.topAnchor === view.topAnchor)
            #expect(pinnable.bottomAnchor === view.bottomAnchor)
            #expect(pinnable.widthAnchor === view.widthAnchor)
            #expect(pinnable.heightAnchor === view.heightAnchor)
            #expect(pinnable.centerXAnchor === view.centerXAnchor)
            #expect(pinnable.centerYAnchor === view.centerYAnchor)
        }

        @Test func `ns layout guide is pinnable`() {
            let view = NSView()
            let guide = NSLayoutGuide()
            view.addLayoutGuide(guide)
            let pinnable: any Pinnable = guide
            #expect(pinnable.leadingAnchor === guide.leadingAnchor)
            #expect(pinnable.trailingAnchor === guide.trailingAnchor)
            #expect(pinnable.topAnchor === guide.topAnchor)
            #expect(pinnable.bottomAnchor === guide.bottomAnchor)
            #expect(pinnable.widthAnchor === guide.widthAnchor)
            #expect(pinnable.heightAnchor === guide.heightAnchor)
            #expect(pinnable.centerXAnchor === guide.centerXAnchor)
            #expect(pinnable.centerYAnchor === guide.centerYAnchor)
        }

        // MARK: - MultiConstrainable

        @Test func `ns view is multi constrainable`() {
            let view = NSView()
            #expect(view is any MultiConstrainable)
        }

        @Test func `pinned to a view creates four constraints with margins`() {
            let superview = NSView()
            let view = NSView()
            superview.addSubview(view)

            let constraints = view.pinned(to: superview, margin: .init(top: 1, leading: 2, bottom: 3, trailing: 4)).asConstraints

            #expect(constraints.count == 4)
            #expect(constraints[0].firstAnchor == view.topAnchor)
            #expect(constraints[0].constant == 1)
            #expect(constraints[1].firstAnchor == view.bottomAnchor)
            #expect(constraints[1].constant == -3)
            #expect(constraints[2].constant == 2)
            #expect(constraints[3].constant == -4)
            #expect(constraints.allSatisfy { $0.priority == .required })
        }

        @Test func `pinned to a layout guide`() {
            let superview = NSView()
            let guide = NSLayoutGuide()
            superview.addLayoutGuide(guide)
            let view = NSView()
            superview.addSubview(view)

            let constraints = view.pinned(to: guide).asConstraints

            #expect(constraints.count == 4)
            #expect(constraints[0].secondAnchor == guide.topAnchor)
        }

        @Test func `pinned with trailing priority`() {
            let superview = NSView()
            let view = NSView()
            superview.addSubview(view)

            let constraints = view.pinned(to: superview, margin: .zero, trailingConstraintPriority: .defaultHigh).asConstraints

            #expect(constraints[0].priority == .required)
            #expect(constraints[1].priority == .defaultHigh)
            #expect(constraints[2].priority == .required)
            #expect(constraints[3].priority == .defaultHigh)
        }

        @Test func `size and centering helpers create constraints`() {
            let superview = NSView()
            let view = NSView()
            superview.addSubview(view)

            #expect(view.size(equals: CGSize(width: 100, height: 50)).asConstraints.map(\.constant) == [100, 50])
            #expect(view.size(equals: 75).asConstraints.map(\.constant) == [75, 75])
            #expect(view.size(equals: superview).asConstraints.count == 2)
            #expect(view.centered(on: superview).asConstraints.count == 2)
            #expect(view.centered(on: superview, size: CGSize(width: 10, height: 10)).asConstraints.count == 4)
            #expect(view.verticallyCentered(on: superview, topMargin: 1, bottomMargin: 2).asConstraints.map(\.constant) == [1, -2])
            #expect(view.horizontallyCentered(on: superview, leadingMargin: 3, trailingMargin: 4).asConstraints.map(\.constant) == [3, -4])
        }

        // MARK: - with(priority:)

        @Test func `with priority sets the priority`() {
            let view = NSView()
            let constraint = view.widthAnchor.constraint(equalToConstant: 10).with(priority: .defaultLow)
            #expect(constraint.priority == .defaultLow)
        }
    }
#endif
