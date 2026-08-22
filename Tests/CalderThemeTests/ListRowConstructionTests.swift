#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
@testable import CalderTheme
import SFSafeSymbols
import SwiftUI
import Testing

@Suite(.serialized)
@MainActor struct ListRowConstructionTests {

    @Test func `compact trailing detail body constructs with image accessory`() {
        let row = ListRow(content: {
            Text("Body")
        }, header: {
            Text("Header")
        }, detail: {
            Text("Detail")
        }, accessory: Image(systemName: "chevron.right"))

        #expect(row.compactDetailPositioning == .trailing)
        #expect(row.accessory != nil)
        _ = row.body
    }

    @Test func `compact top leading detail body constructs with symbol accessory`() {
        let row = ListRow(content: {
            Text("Body")
        }, header: {
            Text("Header")
        }, detail: {
            Text("Detail")
        }, symbol: .chevronRight, compactDetailPositioning: .topLeading)

        #expect(row.compactDetailPositioning == .topLeading)
        #expect(row.accessory != nil)
        _ = row.body
    }

    @Test func `compact top trailing detail body constructs without optional views`() {
        let row = ListRow<Text, EmptyView, Text>(content: {
            Text("Body")
        }, detail: {
            Text("Detail")
        }, compactDetailPositioning: .topTrailing)

        #expect(row.compactDetailPositioning == .topTrailing)
        #expect(row.accessory == nil)
        _ = row.body
    }
}

#endif
