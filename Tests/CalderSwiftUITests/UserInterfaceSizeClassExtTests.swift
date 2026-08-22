#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
@testable import CalderSwiftUI
import Foundation
import SwiftUI
import Testing

@Suite(.serialized) struct UserInterfaceSizeClassExtTests {

    // MARK: - adaptativeValue on Optional<UserInterfaceSizeClass>

    @Test func `adaptative value returns regular for regular size class`() {
        let sizeClass: UserInterfaceSizeClass? = .regular
        let result = sizeClass.adaptativeValue(compact: 100, regular: 200)
        #expect(result == 200)
    }

    @Test func `adaptative value returns compact for compact size class`() {
        let sizeClass: UserInterfaceSizeClass? = .compact
        let result = sizeClass.adaptativeValue(compact: 100, regular: 200)
        #expect(result == 100)
    }

    @Test func `adaptative value returns compact for nil size class`() {
        let sizeClass: UserInterfaceSizeClass? = nil
        let result = sizeClass.adaptativeValue(compact: 100, regular: 200)
        #expect(result == 100)
    }

    @Test func `adaptative value with same values`() {
        let sizeClass: UserInterfaceSizeClass? = .regular
        let result = sizeClass.adaptativeValue(compact: 150, regular: 150)
        #expect(result == 150)
    }

    @Test func `adaptative value with zero values`() {
        let sizeClass: UserInterfaceSizeClass? = .compact
        let result = sizeClass.adaptativeValue(compact: 0, regular: 100)
        #expect(result == 0)
    }

    @Test func `adaptative value with negative values`() {
        let sizeClass: UserInterfaceSizeClass? = .regular
        let result = sizeClass.adaptativeValue(compact: -10, regular: -20)
        #expect(result == -20)
    }

    // MARK: - AdaptativeValue struct

    @Test func `adaptative value struct initialization`() {
        let value = AdaptativeValue(sizeClass: .compact, compact: 10, regular: 20)
        #expect(value.sizeClass == .compact)
        #expect(value.compact == 10)
        #expect(value.regular == 20)
    }

    @Test func `adaptative value struct default size class`() {
        let value = AdaptativeValue(compact: 10, regular: 20)
        #expect(value.sizeClass == .compact)
    }

    @Test func `adaptative value struct value for compact`() {
        let value = AdaptativeValue(sizeClass: .compact, compact: 10, regular: 20)
        #expect(value.value == 10)
    }

    @Test func `adaptative value struct value for regular`() {
        let value = AdaptativeValue(sizeClass: .regular, compact: 10, regular: 20)
        #expect(value.value == 20)
    }

    @Test func `adaptative value struct value for nil`() {
        let value = AdaptativeValue(sizeClass: nil, compact: 10, regular: 20)
        #expect(value.value == 10)
    }

    @Test func `adaptative value struct mutable size class`() {
        var value = AdaptativeValue(sizeClass: .compact, compact: 10, regular: 20)
        #expect(value.value == 10)

        value.sizeClass = .regular
        #expect(value.value == 20)
    }

    // MARK: - AdaptativeValue with different types

    @Test func `adaptative value with string type`() {
        let value = AdaptativeValue(sizeClass: .regular, compact: "small", regular: "large")
        #expect(value.value == "large")
    }

    @Test func `adaptative value with bool type`() {
        let value = AdaptativeValue(sizeClass: .compact, compact: true, regular: false)
        #expect(value.value == true)
    }

    @Test func `adaptative value with double type`() {
        let value = AdaptativeValue(sizeClass: .regular, compact: 1.5, regular: 3.0)
        #expect(value.value == 3.0)
    }

    @Test func `adaptative value with array type`() {
        let value = AdaptativeValue(sizeClass: .compact, compact: [1, 2], regular: [1, 2, 3, 4])
        #expect(value.value == [1, 2])
    }

    @Test func `adaptative value with optional type`() {
        let value = AdaptativeValue<Int?>(sizeClass: .regular, compact: nil, regular: 42)
        #expect(value.value == 42)
    }

    // MARK: - Edge cases

    @Test func `adaptative value switching between size classes`() {
        var value = AdaptativeValue(sizeClass: .compact, compact: "phone", regular: "tablet")
        #expect(value.value == "phone")

        value.sizeClass = .regular
        #expect(value.value == "tablet")

        value.sizeClass = nil
        #expect(value.value == "phone")

        value.sizeClass = .compact
        #expect(value.value == "phone")
    }
}

#endif
