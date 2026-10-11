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
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
                cell.accessibilityLabel = sections[indexPath.section][indexPath.item]
                return cell
            }
        }

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

            @Test func `index path for last item empty collection view returns nil`() {
                let collectionView = createCollectionView()
                let dataSource = SimpleCollectionDataSource(sections: [])
                collectionView.dataSource = dataSource
                collectionView.reloadData()

                #expect(collectionView.indexPathForLastItem == nil)
            }

            @Test func `index path for last item empty last section returns nil`() {
                let collectionView = createCollectionView()
                let dataSource = SimpleCollectionDataSource(sections: [["A"], []])
                collectionView.dataSource = dataSource
                collectionView.reloadData()

                #expect(collectionView.indexPathForLastItem == nil)
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

            @Test func `index path for last item in section empty section returns nil`() {
                let collectionView = createCollectionView()
                let dataSource = SimpleCollectionDataSource(sections: [[]])
                collectionView.dataSource = dataSource
                collectionView.reloadData()

                #expect(collectionView.indexPathForLastItem(inSection: 0) == nil)
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

            @Test func `safe scroll to item valid index path scrolls`() {
                let (collectionView, dataSource) = makeScrollableCollectionView()

                collectionView.safeScrollToItem(at: IndexPath(item: 99, section: 0), at: .bottom, animated: false)

                #expect(collectionView.contentOffset.y > 0)
                withExtendedLifetime(dataSource) {}
            }

            @Test(arguments: [
                IndexPath(item: 0, section: 5),
                IndexPath(item: 100, section: 0),
                IndexPath(item: -1, section: 0),
                IndexPath(item: 0, section: -1)
            ])
            func `safe scroll to item invalid index path is ignored`(indexPath: IndexPath) {
                let (collectionView, dataSource) = makeScrollableCollectionView()

                collectionView.safeScrollToItem(at: indexPath, at: .top, animated: false)

                #expect(collectionView.contentOffset == .zero)
                withExtendedLifetime(dataSource) {}
            }

            // MARK: - scrollToCell Tests

            @Test func `scroll to cell valid index path returns true`() {
                let (collectionView, dataSource) = makeScrollableCollectionView()

                let result = collectionView.scrollToCell(at: IndexPath(item: 99, section: 0), animated: false)

                #expect(result == true)
                #expect(collectionView.contentOffset.y > 0)
                withExtendedLifetime(dataSource) {}
            }

            @Test func `scroll to cell with translation`() {
                let (collectionView, dataSource) = makeScrollableCollectionView()
                let target = IndexPath(item: 99, section: 0)
                let frame = collectionView.layoutAttributesForItem(at: target)?.frame ?? .null

                let result = collectionView.scrollToCell(at: target, translateX: 0, translateY: -60, animated: false)

                // The shifted rect ends 60 points above the item, so the item's bottom stays hidden.
                #expect(result == true)
                #expect(collectionView.bounds.maxY == frame.maxY - 60)
                withExtendedLifetime(dataSource) {}
            }

            @Test func `scroll to cell missing index path returns false`() {
                let (collectionView, dataSource) = makeScrollableCollectionView()

                let result = collectionView.scrollToCell(at: IndexPath(item: 0, section: 3), animated: false)

                #expect(result == false)
                #expect(collectionView.contentOffset == .zero)
                withExtendedLifetime(dataSource) {}
            }

            // MARK: - safeScrollToBottom Tests

            @Test func `safe scroll to bottom with an empty last section does not scroll`() {
                let (collectionView, dataSource) = makeScrollableCollectionView(trailingEmptySection: true)

                collectionView.safeScrollToBottom()

                #expect(collectionView.contentOffset == .zero)
                withExtendedLifetime(dataSource) {}
            }

            @Test func `safe scroll to bottom reveals the last item`() throws {
                let (collectionView, dataSource) = makeScrollableCollectionView()

                collectionView.safeScrollToBottom(animated: false)

                let lastItem = try #require(collectionView.layoutAttributesForItem(at: IndexPath(item: 99, section: 0)))
                #expect(collectionView.contentOffset.y > 0)
                #expect(collectionView.bounds.contains(lastItem.frame))
                withExtendedLifetime(dataSource) {}
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

            @Test func `reload specific index paths not animated reloads only those items`() {
                let collectionView = createCollectionView()
                let dataSource = SimpleCollectionDataSource(sections: [["A", "B"]])
                collectionView.dataSource = dataSource
                collectionView.reloadData()
                collectionView.layoutIfNeeded()

                dataSource.sections = [["Y", "Z"]]
                collectionView.reload(at: [IndexPath(item: 0, section: 0)], animated: false)
                collectionView.layoutIfNeeded()

                #expect(collectionView.cellForItem(at: IndexPath(item: 0, section: 0))?.accessibilityLabel == "Y")
                #expect(collectionView.cellForItem(at: IndexPath(item: 1, section: 0))?.accessibilityLabel == "B")
            }

            /// A laid-out collection with 100 items, taller than its 480 point frame.
            private func makeScrollableCollectionView(trailingEmptySection: Bool = false) -> (UICollectionView, SimpleCollectionDataSource) {
                let collectionView = createCollectionView()
                let items = (0 ..< 100).map { "Item \($0)" }
                let dataSource = SimpleCollectionDataSource(sections: trailingEmptySection ? [items, []] : [items])
                collectionView.dataSource = dataSource
                collectionView.reloadData()
                collectionView.layoutIfNeeded()
                return (collectionView, dataSource)
            }
        }
    #endif

#endif
