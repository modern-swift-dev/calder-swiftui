#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(macOS) && !os(watchOS)
import CalderUIKit
import Foundation
import Testing
import UIKit

/// Simple data source for testing
private class SimpleCollectionDataSource: NSObject, UICollectionViewDataSource {
    var sections: [[String]]

    init(sections: [[String]]) {
        self.sections = sections
    }

    func numberOfSections(in _: UICollectionView) -> Int {
        sections.count
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < sections.count else {
            return 0
        }
        return sections[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }
}

@Suite(.serialized)
@MainActor struct UICollectionViewExtTests {

    private func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 50)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }

    // MARK: - lastSection Tests

    @Test func `last section empty collection view returns zero`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        #expect(collectionView.lastSection == 0)
    }

    @Test func `last section single section returns zero`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["Item"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        #expect(collectionView.lastSection == 0)
    }

    @Test func `last section multiple sections returns last index`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["A"], ["B"], ["C"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        #expect(collectionView.lastSection == 2)
    }

    // MARK: - indexPathForLastItem Tests

    @Test func `index path for last item empty collection view returns nil or zero`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        let result = collectionView.indexPathForLastItem
        #expect(result == nil || result?.item == 0)
    }

    @Test func `index path for last item single item single section`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["Item"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        let lastItem = collectionView.indexPathForLastItem
        #expect(lastItem?.section == 0)
        #expect(lastItem?.item == 0)
    }

    @Test func `index path for last item multiple items multiple sections`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["A", "B"], ["C", "D", "E"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        let lastItem = collectionView.indexPathForLastItem
        #expect(lastItem?.section == 1)
        #expect(lastItem?.item == 2)
    }

    // MARK: - indexPathForLastItem(inSection:) Tests

    @Test func `index path for last item in section invalid negative section returns nil`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["Item"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        #expect(collectionView.indexPathForLastItem(inSection: -1) == nil)
    }

    @Test func `index path for last item in section out of bounds section returns nil`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["Item"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        #expect(collectionView.indexPathForLastItem(inSection: 5) == nil)
    }

    @Test func `index path for last item in section empty section returns zero item`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [[]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        let result = collectionView.indexPathForLastItem(inSection: 0)
        #expect(result?.section == 0)
        #expect(result?.item == 0)
    }

    @Test func `index path for last item in section valid section`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["A", "B", "C"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        let result = collectionView.indexPathForLastItem(inSection: 0)
        #expect(result?.section == 0)
        #expect(result?.item == 2)
    }

    // MARK: - isValidIndexPath Tests

    @Test func `is valid index path valid index path returns true`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["A", "B"], ["C"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        #expect(collectionView.isValidIndexPath(IndexPath(item: 0, section: 0)) == true)
        #expect(collectionView.isValidIndexPath(IndexPath(item: 1, section: 0)) == true)
        #expect(collectionView.isValidIndexPath(IndexPath(item: 0, section: 1)) == true)
    }

    @Test func `is valid index path negative item returns false`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["A"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        #expect(collectionView.isValidIndexPath(IndexPath(item: -1, section: 0)) == false)
    }

    @Test func `is valid index path negative section returns false`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["A"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        #expect(collectionView.isValidIndexPath(IndexPath(item: 0, section: -1)) == false)
    }

    @Test func `is valid index path item out of bounds returns false`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["A", "B"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        #expect(collectionView.isValidIndexPath(IndexPath(item: 2, section: 0)) == false)
    }

    @Test func `is valid index path section out of bounds returns false`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["A"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        #expect(collectionView.isValidIndexPath(IndexPath(item: 0, section: 1)) == false)
    }

    // MARK: - safeScrollToItem Tests

    @Test func `safe scroll to item invalid section does not crash`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["A"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        collectionView.safeScrollToItem(at: IndexPath(item: 0, section: 5), at: .top, animated: false)
        #expect(true)
    }

    @Test func `safe scroll to item invalid item does not crash`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["A"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        collectionView.safeScrollToItem(at: IndexPath(item: 10, section: 0), at: .top, animated: false)
        #expect(true)
    }

    @Test func `safe scroll to item negative item does not crash`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["A"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        collectionView.safeScrollToItem(at: IndexPath(item: -1, section: 0), at: .top, animated: false)
        #expect(true)
    }

    @Test func `safe scroll to item negative section does not crash`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["A"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        collectionView.safeScrollToItem(at: IndexPath(item: 0, section: -1), at: .top, animated: false)
        #expect(true)
    }

    // MARK: - scrollToCell Tests

    @Test func `scroll to cell valid index path returns true`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["A", "B", "C"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()
        collectionView.layoutIfNeeded()

        let result = collectionView.scrollToCell(at: IndexPath(item: 0, section: 0), animated: false)
        #expect(result == true)
    }

    @Test func `scroll to cell with translation`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["A", "B"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()
        collectionView.layoutIfNeeded()

        let result = collectionView.scrollToCell(at: IndexPath(item: 0, section: 0), translateX: 10, translateY: 20, animated: false)
        #expect(result == true)
    }

    // MARK: - safeScrollToBottom Tests

    @Test func `safe scroll to bottom empty collection does not crash`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        collectionView.safeScrollToBottom()
        #expect(true)
    }

    @Test func `safe scroll to bottom with data does not crash`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["A", "B", "C"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        collectionView.safeScrollToBottom(animated: false)
        #expect(true)
    }

    // MARK: - reload Tests

    @Test func `reload not animated reloads data`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["A"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        dataSource.sections = [["A", "B"]]
        collectionView.reload(animated: false)

        #expect(collectionView.numberOfItems(inSection: 0) == 2)
    }

    @Test func `reload specific index paths not animated`() {
        let collectionView = createCollectionView()
        let dataSource = SimpleCollectionDataSource(sections: [["A", "B"]])
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        collectionView.reload(at: [IndexPath(item: 0, section: 0)], animated: false)
        #expect(true)
    }

}
#endif

#endif
