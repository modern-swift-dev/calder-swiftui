#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    @testable import CalderSwiftUI
    import Foundation
    import SwiftUI
    import Testing

    struct UserInterfaceSizeClassExtTests {

        // MARK: - adaptiveValue on Optional<UserInterfaceSizeClass>

        @Test func `adaptive value returns regular for regular size class`() {
            let sizeClass: UserInterfaceSizeClass? = .regular
            let result = sizeClass.adaptiveValue(compact: 100, regular: 200)
            #expect(result == 200)
        }

        @Test func `adaptive value returns compact for compact size class`() {
            let sizeClass: UserInterfaceSizeClass? = .compact
            let result = sizeClass.adaptiveValue(compact: 100, regular: 200)
            #expect(result == 100)
        }

        @Test func `adaptive value returns compact for nil size class`() {
            let sizeClass: UserInterfaceSizeClass? = nil
            let result = sizeClass.adaptiveValue(compact: 100, regular: 200)
            #expect(result == 100)
        }

        @Test func `adaptive value with same values`() {
            let sizeClass: UserInterfaceSizeClass? = .regular
            let result = sizeClass.adaptiveValue(compact: 150, regular: 150)
            #expect(result == 150)
        }

        @Test func `adaptive value with zero values`() {
            let sizeClass: UserInterfaceSizeClass? = .compact
            let result = sizeClass.adaptiveValue(compact: 0, regular: 100)
            #expect(result == 0)
        }

        @Test func `adaptive value with negative values`() {
            let sizeClass: UserInterfaceSizeClass? = .regular
            let result = sizeClass.adaptiveValue(compact: -10, regular: -20)
            #expect(result == -20)
        }

        // MARK: - AdaptiveValue struct

        @Test func `adaptive value struct initialization`() {
            let value = AdaptiveValue(sizeClass: .compact, compact: 10, regular: 20)
            #expect(value.sizeClass == .compact)
            #expect(value.compact == 10)
            #expect(value.regular == 20)
        }

        @Test func `adaptive value struct default size class`() {
            let value = AdaptiveValue(compact: 10, regular: 20)
            #expect(value.sizeClass == .compact)
        }

        @Test func `adaptive value struct value for compact`() {
            let value = AdaptiveValue(sizeClass: .compact, compact: 10, regular: 20)
            #expect(value.value == 10)
        }

        @Test func `adaptive value struct value for regular`() {
            let value = AdaptiveValue(sizeClass: .regular, compact: 10, regular: 20)
            #expect(value.value == 20)
        }

        @Test func `adaptive value struct value for nil`() {
            let value = AdaptiveValue(sizeClass: nil, compact: 10, regular: 20)
            #expect(value.value == 10)
        }

        @Test func `adaptive value struct mutable size class`() {
            var value = AdaptiveValue(sizeClass: .compact, compact: 10, regular: 20)
            #expect(value.value == 10)

            value.sizeClass = .regular
            #expect(value.value == 20)
        }

        // MARK: - AdaptiveValue with different types

        @Test func `adaptive value with string type`() {
            let value = AdaptiveValue(sizeClass: .regular, compact: "small", regular: "large")
            #expect(value.value == "large")
        }

        @Test func `adaptive value with bool type`() {
            let value = AdaptiveValue(sizeClass: .compact, compact: true, regular: false)
            #expect(value.value == true)
        }

        @Test func `adaptive value with double type`() {
            let value = AdaptiveValue(sizeClass: .regular, compact: 1.5, regular: 3.0)
            #expect(value.value == 3.0)
        }

        @Test func `adaptive value with array type`() {
            let value = AdaptiveValue(sizeClass: .compact, compact: [1, 2], regular: [1, 2, 3, 4])
            #expect(value.value == [1, 2])
        }

        @Test func `adaptive value with optional type`() {
            let value = AdaptiveValue<Int?>(sizeClass: .regular, compact: nil, regular: 42)
            #expect(value.value == 42)
        }

        // MARK: - Edge cases

        @Test func `adaptive value switching between size classes`() {
            var value = AdaptiveValue(sizeClass: .compact, compact: "phone", regular: "tablet")
            #expect(value.value == "phone")

            value.sizeClass = .regular
            #expect(value.value == "tablet")

            value.sizeClass = nil
            #expect(value.value == "phone")

            value.sizeClass = .compact
            #expect(value.value == "phone")
        }

        // MARK: - Deprecated names

        @available(*, deprecated)
        @Test func `deprecated adaptativeValue forwards to adaptiveValue`() {
            let sizeClass: UserInterfaceSizeClass? = .regular
            #expect(sizeClass.adaptativeValue(compact: 100, regular: 200) == 200)
        }

        @available(*, deprecated)
        @Test func `deprecated AdaptativeValue aliases AdaptiveValue`() {
            let value: AdaptiveValue<Int> = AdaptativeValue(sizeClass: .regular, compact: 1, regular: 2)
            #expect(value.value == 2)
        }
    }

#endif
