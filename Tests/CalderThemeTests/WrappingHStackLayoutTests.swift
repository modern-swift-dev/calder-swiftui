#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    @testable import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    @Suite(.serialized)
    @MainActor struct WrappingHStackLayoutTests {

        // MARK: - Layout harness

        /// Records the placement proposals and bounds each probe receives during layout.
        ///
        /// SwiftUI runs layout on the main thread, so probes record through `MainActor.assumeIsolated`.
        @MainActor final class Recorder {
            var placementProposals: [Int: ProposedViewSize] = [:]
            var frames: [Int: CGRect] = [:]
            var minimumSize: CGSize?
        }

        /// A leaf view that reports an ideal size and records how the container lays it out.
        ///
        /// A flexible-height probe takes any proposed height and falls back to its ideal height.
        struct Probe: Layout {
            let id: Int
            let size: CGSize
            var flexibleHeight = false
            let recorder: Recorder

            func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
                guard flexibleHeight else {
                    return size
                }
                return CGSize(width: size.width, height: proposal.height ?? size.height)
            }

            func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
                MainActor.assumeIsolated {
                    recorder.placementProposals[id] = proposal
                    recorder.frames[id] = bounds
                }
                for subview in subviews {
                    subview.place(at: bounds.origin, proposal: ProposedViewSize(bounds.size))
                }
            }
        }

        /// A container that records the minimum size its single child reports.
        struct MinimumSizeProbe: Layout {
            let recorder: Recorder

            func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
                let minimumSize = subviews.first?.sizeThatFits(.zero)
                MainActor.assumeIsolated {
                    recorder.minimumSize = minimumSize
                }
                return subviews.first?.sizeThatFits(proposal) ?? .zero
            }

            func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
                subviews.first?.place(at: bounds.origin, proposal: proposal)
            }
        }

        /// Lays out probes of the given sizes in a wrapping stack inside a fixed frame.
        private static func content(
            _ sizes: [CGSize],
            horizontalSpacing: CGFloat,
            verticalSpacing: CGFloat = 0,
            width: CGFloat,
            height: CGFloat = 400,
            recorder: Recorder
        ) -> some View {
            WrappingHStackLayout(alignment: .topLeading, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing) {
                ForEach(sizes.indices, id: \.self) { index in
                    Probe(id: index, size: sizes[index], recorder: recorder) {
                        Color.clear
                    }
                }
            }
            .frame(width: width, height: height, alignment: .topLeading)
        }

        // MARK: - Layout behaviour

        @Test func `changing horizontal spacing re-lays out rows`() {
            let recorder = Recorder()
            let sizes = [CGSize(width: 40, height: 10), CGSize(width: 40, height: 10)]
            let renderer = ImageRenderer(content: AnyView(Self.content(sizes, horizontalSpacing: 0, width: 100, recorder: recorder)))
            _ = renderer.cgImage
            let firstRowY = recorder.frames[0]?.minY
            #expect(recorder.frames[1]?.minY == firstRowY)

            renderer.content = AnyView(Self.content(sizes, horizontalSpacing: 30, width: 100, recorder: recorder))
            _ = renderer.cgImage

            // 40 + 30 + 40 exceeds 100, so the second probe must wrap to a new row.
            #expect(recorder.frames[1]?.minY == (firstRowY ?? 0) + 10)
            #expect(recorder.frames[1]?.minX == recorder.frames[0]?.minX)
        }

        @Test func `children are proposed their own measured size`() {
            let recorder = Recorder()
            let sizes = [CGSize(width: 40, height: 10), CGSize(width: 30, height: 20)]
            _ = ImageRenderer(content: Self.content(sizes, horizontalSpacing: 0, width: 100, recorder: recorder)).cgImage

            #expect(recorder.placementProposals[0] == ProposedViewSize(width: 40, height: 10))
            #expect(recorder.placementProposals[1] == ProposedViewSize(width: 30, height: 20))
        }

        @Test func `flexible height children do not fill the container height`() {
            let recorder = Recorder()
            let content = WrappingHStackLayout(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 0) {
                Probe(id: 0, size: CGSize(width: 40, height: 10), flexibleHeight: true, recorder: recorder) { Color.clear }
                Probe(id: 1, size: CGSize(width: 40, height: 10), flexibleHeight: true, recorder: recorder) { Color.clear }
            }
            .frame(width: 50, height: 400, alignment: .topLeading)
            _ = ImageRenderer(content: content).cgImage

            #expect(recorder.frames[0]?.height == 10)
            #expect(recorder.frames[1]?.minY == (recorder.frames[0]?.minY ?? 0) + 10)
        }

        @Test func `undersized proposals still place every child`() {
            let recorder = Recorder()
            let sizes = [CGSize(width: 40, height: 10), CGSize(width: 40, height: 10)]
            _ = ImageRenderer(content: Self.content(sizes, horizontalSpacing: 0, width: 30, height: 5, recorder: recorder)).cgImage

            let firstFrame = recorder.frames[0] ?? .null
            #expect(recorder.frames[1] == CGRect(x: firstFrame.minX, y: firstFrame.minY + 10, width: 40, height: 10))
        }

        @Test func `minimum size stacks every row`() {
            let recorder = Recorder()
            let content = MinimumSizeProbe(recorder: recorder) {
                WrappingHStackLayout(horizontalSpacing: 0, verticalSpacing: 5) {
                    Probe(id: 0, size: CGSize(width: 40, height: 10), recorder: recorder) { Color.clear }
                    Probe(id: 1, size: CGSize(width: 30, height: 20), recorder: recorder) { Color.clear }
                }
            }
            .frame(width: 100, height: 100)
            _ = ImageRenderer(content: content).cgImage

            #expect(recorder.minimumSize == CGSize(width: 40, height: 35))
        }

        @Test func `changing vertical spacing re-lays out rows`() {
            let recorder = Recorder()
            let sizes = [CGSize(width: 80, height: 10), CGSize(width: 80, height: 10)]
            let renderer = ImageRenderer(content: AnyView(Self.content(sizes, horizontalSpacing: 0, verticalSpacing: 0, width: 100, recorder: recorder)))
            _ = renderer.cgImage
            let firstRowY = recorder.frames[0]?.minY ?? 0
            #expect(recorder.frames[1]?.minY == firstRowY + 10)

            renderer.content = AnyView(Self.content(sizes, horizontalSpacing: 0, verticalSpacing: 15, width: 100, recorder: recorder))
            _ = renderer.cgImage

            #expect(recorder.frames[1]?.minY == firstRowY + 25)
        }

        // MARK: - Initialization

        @Test func `initializes with default values`() {
            let layout = WrappingHStackLayout()

            #expect(layout.alignment == .center)
            #expect(layout.horizontalSpacing == nil)
            #expect(layout.verticalSpacing == nil)
        }

        @Test func `initializes with custom alignment`() {
            let layout = WrappingHStackLayout(alignment: .leading)

            #expect(layout.alignment == .leading)
            #expect(layout.horizontalSpacing == nil)
            #expect(layout.verticalSpacing == nil)
        }

        @Test func `initializes with custom horizontal spacing`() {
            let layout = WrappingHStackLayout(horizontalSpacing: 10)

            #expect(layout.alignment == .center)
            #expect(layout.horizontalSpacing == 10)
            #expect(layout.verticalSpacing == nil)
        }

        @Test func `initializes with custom vertical spacing`() {
            let layout = WrappingHStackLayout(verticalSpacing: 8)

            #expect(layout.alignment == .center)
            #expect(layout.horizontalSpacing == nil)
            #expect(layout.verticalSpacing == 8)
        }

        @Test func `initializes with all custom parameters`() {
            let layout = WrappingHStackLayout(
                alignment: .topLeading,
                horizontalSpacing: 12,
                verticalSpacing: 16
            )

            #expect(layout.alignment == .topLeading)
            #expect(layout.horizontalSpacing == 12)
            #expect(layout.verticalSpacing == 16)
        }

        // MARK: - Alignment Variations

        @Test func `accepts leading alignment`() {
            let layout = WrappingHStackLayout(alignment: .leading)
            #expect(layout.alignment == .leading)
        }

        @Test func `accepts trailing alignment`() {
            let layout = WrappingHStackLayout(alignment: .trailing)
            #expect(layout.alignment == .trailing)
        }

        @Test func `accepts top alignment`() {
            let layout = WrappingHStackLayout(alignment: .top)
            #expect(layout.alignment == .top)
        }

        @Test func `accepts bottom alignment`() {
            let layout = WrappingHStackLayout(alignment: .bottom)
            #expect(layout.alignment == .bottom)
        }

        @Test func `accepts top leading alignment`() {
            let layout = WrappingHStackLayout(alignment: .topLeading)
            #expect(layout.alignment == .topLeading)
        }

        @Test func `accepts top trailing alignment`() {
            let layout = WrappingHStackLayout(alignment: .topTrailing)
            #expect(layout.alignment == .topTrailing)
        }

        @Test func `accepts bottom leading alignment`() {
            let layout = WrappingHStackLayout(alignment: .bottomLeading)
            #expect(layout.alignment == .bottomLeading)
        }

        @Test func `accepts bottom trailing alignment`() {
            let layout = WrappingHStackLayout(alignment: .bottomTrailing)
            #expect(layout.alignment == .bottomTrailing)
        }

        @Test func `accepts center alignment`() {
            let layout = WrappingHStackLayout(alignment: .center)
            #expect(layout.alignment == .center)
        }

        // MARK: - Static Properties

        @Test func `layout properties has horizontal stack orientation`() {
            let properties = WrappingHStackLayout.layoutProperties
            #expect(properties.stackOrientation == .horizontal)
        }

        // MARK: - Cache Structure

        @Test func `cache can be created with nil rows`() {
            let cache = WrappingHStackLayout.Cache(rows: nil)

            #expect(cache.rows == nil)
        }

        @Test func `cache can be created with empty rows`() {
            let cache = WrappingHStackLayout.Cache(rows: (12345, []))

            #expect(cache.rows?.0 == 12345)
            #expect(cache.rows?.1.isEmpty == true)
        }

        @Test func `cache can store multiple rows`() {
            let row1 = WrappingHStackLayout.Row(
                elements: [(0, CGSize(width: 50, height: 20), 0)],
                yOffset: 0,
                width: 50,
                height: 20
            )

            let row2 = WrappingHStackLayout.Row(
                elements: [(1, CGSize(width: 60, height: 25), 0)],
                yOffset: 28,
                width: 60,
                height: 25
            )

            let cache = WrappingHStackLayout.Cache(rows: (98765, [row1, row2]))

            #expect(cache.rows?.0 == 98765)
            #expect(cache.rows?.1.count == 2)
        }

        // MARK: - Row Structure

        @Test func `row can be created with defaults`() {
            let row = WrappingHStackLayout.Row()

            #expect(row.elements.isEmpty)
            #expect(row.yOffset == 0)
            #expect(row.width == 0)
            #expect(row.height == 0)
        }

        @Test func `row can store element information`() {
            let row = WrappingHStackLayout.Row(
                elements: [(0, CGSize(width: 100, height: 50), 10)],
                yOffset: 20,
                width: 110,
                height: 50
            )

            #expect(row.elements.count == 1)
            #expect(row.elements[0].index == 0)
            #expect(row.elements[0].size.width == 100)
            #expect(row.elements[0].size.height == 50)
            #expect(row.elements[0].xOffset == 10)
            #expect(row.yOffset == 20)
            #expect(row.width == 110)
            #expect(row.height == 50)
        }

        @Test func `row can store multiple elements`() {
            let row = WrappingHStackLayout.Row(
                elements: [
                    (0, CGSize(width: 50, height: 30), 0),
                    (1, CGSize(width: 60, height: 25), 58),
                    (2, CGSize(width: 40, height: 35), 126)
                ],
                yOffset: 0,
                width: 166,
                height: 35
            )

            #expect(row.elements.count == 3)
            #expect(row.elements[0].index == 0)
            #expect(row.elements[1].index == 1)
            #expect(row.elements[2].index == 2)
            #expect(row.width == 166)
            #expect(row.height == 35)
        }

        // MARK: - Spacing Values

        @Test func `zero horizontal spacing is valid`() {
            let layout = WrappingHStackLayout(horizontalSpacing: 0)
            #expect(layout.horizontalSpacing == 0)
        }

        @Test func `zero vertical spacing is valid`() {
            let layout = WrappingHStackLayout(verticalSpacing: 0)
            #expect(layout.verticalSpacing == 0)
        }

        @Test func `negative horizontal spacing is valid`() {
            let layout = WrappingHStackLayout(horizontalSpacing: -5)
            #expect(layout.horizontalSpacing == -5)
        }

        @Test func `negative vertical spacing is valid`() {
            let layout = WrappingHStackLayout(verticalSpacing: -10)
            #expect(layout.verticalSpacing == -10)
        }

        @Test func `large horizontal spacing is valid`() {
            let layout = WrappingHStackLayout(horizontalSpacing: 1000)
            #expect(layout.horizontalSpacing == 1000)
        }

        @Test func `large vertical spacing is valid`() {
            let layout = WrappingHStackLayout(verticalSpacing: 2000)
            #expect(layout.verticalSpacing == 2000)
        }

        @Test func `fractional horizontal spacing is valid`() {
            let layout = WrappingHStackLayout(horizontalSpacing: 5.5)
            #expect(layout.horizontalSpacing == 5.5)
        }

        @Test func `fractional vertical spacing is valid`() {
            let layout = WrappingHStackLayout(verticalSpacing: 8.25)
            #expect(layout.verticalSpacing == 8.25)
        }

        // MARK: - Independent Property Modifications

        @Test func `alignment can be modified independently`() {
            var layout = WrappingHStackLayout(alignment: .leading, horizontalSpacing: 10)
            #expect(layout.alignment == .leading)
            #expect(layout.horizontalSpacing == 10)

            layout.alignment = .trailing
            #expect(layout.alignment == .trailing)
            #expect(layout.horizontalSpacing == 10)
        }

        @Test func `horizontal spacing can be modified independently`() {
            var layout = WrappingHStackLayout(alignment: .center, horizontalSpacing: 10)
            #expect(layout.alignment == .center)
            #expect(layout.horizontalSpacing == 10)

            layout.horizontalSpacing = 20
            #expect(layout.alignment == .center)
            #expect(layout.horizontalSpacing == 20)
        }

        @Test func `vertical spacing can be modified independently`() {
            var layout = WrappingHStackLayout(alignment: .center, verticalSpacing: 10)
            #expect(layout.alignment == .center)
            #expect(layout.verticalSpacing == 10)

            layout.verticalSpacing = 15
            #expect(layout.alignment == .center)
            #expect(layout.verticalSpacing == 15)
        }

        @Test func `spacing can be set to nil after being set`() {
            var layout = WrappingHStackLayout(horizontalSpacing: 10, verticalSpacing: 8)
            #expect(layout.horizontalSpacing == 10)
            #expect(layout.verticalSpacing == 8)

            layout.horizontalSpacing = nil
            layout.verticalSpacing = nil
            #expect(layout.horizontalSpacing == nil)
            #expect(layout.verticalSpacing == nil)
        }

        // MARK: - Edge Cases

        @Test func `all properties can be set to extreme values`() {
            let layout = WrappingHStackLayout(
                alignment: .bottomTrailing,
                horizontalSpacing: .greatestFiniteMagnitude,
                verticalSpacing: -.greatestFiniteMagnitude
            )

            #expect(layout.alignment == .bottomTrailing)
            #expect(layout.horizontalSpacing == .greatestFiniteMagnitude)
            #expect(layout.verticalSpacing == -.greatestFiniteMagnitude)
        }

        @Test func `layout can be created multiple times`() {
            let layout1 = WrappingHStackLayout(alignment: .leading)
            let layout2 = WrappingHStackLayout(alignment: .trailing)
            let layout3 = WrappingHStackLayout(alignment: .center)

            #expect(layout1.alignment == .leading)
            #expect(layout2.alignment == .trailing)
            #expect(layout3.alignment == .center)
        }

        @Test func `row with zero width and height`() {
            let row = WrappingHStackLayout.Row(
                elements: [],
                yOffset: 0,
                width: 0,
                height: 0
            )

            #expect(row.elements.isEmpty)
            #expect(row.width == 0)
            #expect(row.height == 0)
        }
    }

#endif
