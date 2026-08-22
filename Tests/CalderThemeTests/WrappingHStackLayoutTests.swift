#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
@testable import CalderTheme
import Foundation
import SwiftUI
import Testing

@Suite(.serialized)
@MainActor struct WrappingHStackLayoutTests {

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

    @Test func `cache can be created with min size and nil rows`() {
        let cache = WrappingHStackLayout.Cache(
            minSize: CGSize(width: 100, height: 50),
            rows: nil
        )

        #expect(cache.minSize.width == 100)
        #expect(cache.minSize.height == 50)
        #expect(cache.rows == nil)
    }

    @Test func `cache can be created with min size and empty rows`() {
        let cache = WrappingHStackLayout.Cache(
            minSize: CGSize(width: 100, height: 50),
            rows: (12345, [])
        )

        #expect(cache.minSize.width == 100)
        #expect(cache.minSize.height == 50)
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

        let cache = WrappingHStackLayout.Cache(
            minSize: CGSize(width: 60, height: 53),
            rows: (98765, [row1, row2])
        )

        #expect(cache.minSize.width == 60)
        #expect(cache.minSize.height == 53)
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

    @Test func `cache initialization with zero min size`() {
        let cache = WrappingHStackLayout.Cache(
            minSize: .zero,
            rows: nil
        )

        #expect(cache.minSize == .zero)
        #expect(cache.rows == nil)
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
