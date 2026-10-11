#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if !os(macOS) && !os(watchOS)
        import CalderUIKit
        import Foundation
        import Testing
        import UIKit

        // Test cell class
        private class TestTableViewCell: UITableViewCell {}
        private class AnotherTestCell: UITableViewCell {}

        /// Simple data source for testing
        private class SimpleTableDataSource: NSObject, UITableViewDataSource {
            var sections: [[String]]

            init(sections: [[String]]) {
                self.sections = sections
            }

            func numberOfSections(in _: UITableView) -> Int {
                sections.count
            }

            func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
                guard section < sections.count else {
                    return 0
                }
                return sections[section].count
            }

            func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.textLabel?.text = sections[indexPath.section][indexPath.row]
                return cell
            }
        }

        @MainActor struct UITableViewExtTests {

            // MARK: - registerReusableCell Tests

            @Test func `register reusable cell registers with class name`() {
                let tableView = UITableView()
                tableView.registerReusableCell(type: TestTableViewCell.self)

                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
                let dataSource = SimpleTableDataSource(sections: [["Item"]])
                tableView.dataSource = dataSource

                tableView.reloadData()

                let cell = tableView.dequeueReusableCell(type: TestTableViewCell.self, for: IndexPath(row: 0, section: 0))
                #expect(cell.reuseIdentifier == String(describing: TestTableViewCell.self))
            }

            @Test func `register reusable cell multiple types`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
                tableView.registerReusableCell(type: TestTableViewCell.self)
                tableView.registerReusableCell(type: AnotherTestCell.self)

                let dataSource = SimpleTableDataSource(sections: [["First item", "Second item"]])
                tableView.dataSource = dataSource
                tableView.reloadData()

                let cell1 = tableView.dequeueReusableCell(type: TestTableViewCell.self, for: IndexPath(row: 0, section: 0))
                let cell2 = tableView.dequeueReusableCell(type: AnotherTestCell.self, for: IndexPath(row: 1, section: 0))

                #expect(cell1.reuseIdentifier == String(describing: TestTableViewCell.self))
                #expect(cell2.reuseIdentifier == String(describing: AnotherTestCell.self))
            }

            // MARK: - lastSection Tests

            @Test func `last section empty table view returns nil`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

                let dataSource = SimpleTableDataSource(sections: [])
                tableView.dataSource = dataSource
                tableView.reloadData()

                #expect(tableView.lastSection == nil)
            }

            @Test func `last section single section returns zero`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

                let dataSource = SimpleTableDataSource(sections: [["Item"]])
                tableView.dataSource = dataSource
                tableView.reloadData()

                #expect(tableView.lastSection == 0)
            }

            @Test func `last section multiple sections returns last index`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

                let dataSource = SimpleTableDataSource(sections: [["A"], ["B"], ["C"]])
                tableView.dataSource = dataSource
                tableView.reloadData()

                #expect(tableView.lastSection == 2)
            }

            // MARK: - indexPathForLastRow Tests

            @Test func `index path for last row empty table view returns nil`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

                let dataSource = SimpleTableDataSource(sections: [])
                tableView.dataSource = dataSource
                tableView.reloadData()

                #expect(tableView.indexPathForLastRow == nil)
            }

            @Test func `index path for last row single row single section`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

                let dataSource = SimpleTableDataSource(sections: [["Item"]])
                tableView.dataSource = dataSource
                tableView.reloadData()

                let lastRow = tableView.indexPathForLastRow
                #expect(lastRow?.section == 0)
                #expect(lastRow?.row == 0)
            }

            @Test func `index path for last row multiple rows multiple sections`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

                let dataSource = SimpleTableDataSource(sections: [["A", "B"], ["C", "D", "E"]])
                tableView.dataSource = dataSource
                tableView.reloadData()

                let lastRow = tableView.indexPathForLastRow
                #expect(lastRow?.section == 1)
                #expect(lastRow?.row == 2)
            }

            // MARK: - indexPathForLastRow(inSection:) Tests

            @Test func `index path for last row in section invalid section returns nil`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

                let dataSource = SimpleTableDataSource(sections: [["Item"]])
                tableView.dataSource = dataSource
                tableView.reloadData()

                #expect(tableView.indexPathForLastRow(inSection: -1) == nil)
            }

            @Test func `index path for last row in section out of range section returns nil`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

                let dataSource = SimpleTableDataSource(sections: [["Item"]])
                tableView.dataSource = dataSource
                tableView.reloadData()

                #expect(tableView.indexPathForLastRow(inSection: 1) == nil)
            }

            @Test func `index path for last row in section empty section returns nil`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

                let dataSource = SimpleTableDataSource(sections: [[]])
                tableView.dataSource = dataSource
                tableView.reloadData()

                #expect(tableView.indexPathForLastRow(inSection: 0) == nil)
            }

            @Test func `index path for last row empty last section returns nil`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

                let dataSource = SimpleTableDataSource(sections: [["A"], []])
                tableView.dataSource = dataSource
                tableView.reloadData()

                #expect(tableView.indexPathForLastRow == nil)
            }

            @Test func `index path for last row in section valid section`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

                let dataSource = SimpleTableDataSource(sections: [["A", "B", "C"]])
                tableView.dataSource = dataSource
                tableView.reloadData()

                let result = tableView.indexPathForLastRow(inSection: 0)
                #expect(result?.section == 0)
                #expect(result?.row == 2)
            }

            // MARK: - isValidIndexPath Tests

            @Test func `is valid index path valid index path returns true`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

                let dataSource = SimpleTableDataSource(sections: [["A", "B"], ["C"]])
                tableView.dataSource = dataSource
                tableView.reloadData()

                #expect(tableView.isValidIndexPath(IndexPath(row: 0, section: 0)) == true)
                #expect(tableView.isValidIndexPath(IndexPath(row: 1, section: 0)) == true)
                #expect(tableView.isValidIndexPath(IndexPath(row: 0, section: 1)) == true)
            }

            @Test func `is valid index path negative row returns false`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

                let dataSource = SimpleTableDataSource(sections: [["A"]])
                tableView.dataSource = dataSource
                tableView.reloadData()

                #expect(tableView.isValidIndexPath(IndexPath(row: -1, section: 0)) == false)
            }

            @Test func `is valid index path negative section returns false`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

                let dataSource = SimpleTableDataSource(sections: [["A"]])
                tableView.dataSource = dataSource
                tableView.reloadData()

                #expect(tableView.isValidIndexPath(IndexPath(row: 0, section: -1)) == false)
            }

            @Test func `is valid index path row out of bounds returns false`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

                let dataSource = SimpleTableDataSource(sections: [["A", "B"]])
                tableView.dataSource = dataSource
                tableView.reloadData()

                #expect(tableView.isValidIndexPath(IndexPath(row: 2, section: 0)) == false)
            }

            @Test func `is valid index path section out of bounds returns false`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

                let dataSource = SimpleTableDataSource(sections: [["A"]])
                tableView.dataSource = dataSource
                tableView.reloadData()

                #expect(tableView.isValidIndexPath(IndexPath(row: 0, section: 1)) == false)
            }

            // MARK: - safeScrollToRow Tests

            @Test func `safe scroll to row valid index path scrolls`() {
                let (tableView, dataSource) = makeScrollableTableView()

                tableView.safeScrollToRow(at: IndexPath(row: 99, section: 0), at: .bottom, animated: false)

                #expect(tableView.contentOffset.y > 0)
                withExtendedLifetime(dataSource) {}
            }

            @Test(arguments: [IndexPath(row: 0, section: 5), IndexPath(row: 100, section: 0)])
            func `safe scroll to row out of bounds index is ignored`(indexPath: IndexPath) {
                let (tableView, dataSource) = makeScrollableTableView()

                tableView.safeScrollToRow(at: indexPath, at: .top, animated: false)

                #expect(tableView.contentOffset == .zero)
                withExtendedLifetime(dataSource) {}
            }

            @Test(arguments: [IndexPath(row: -1, section: 0), IndexPath(row: 0, section: -1)])
            func `safe scroll to row negative index is ignored`(indexPath: IndexPath) {
                let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

                let dataSource = SimpleTableDataSource(sections: [["A"]])
                tableView.dataSource = dataSource
                tableView.reloadData()
                let initialOffset = tableView.contentOffset

                tableView.safeScrollToRow(at: indexPath, at: .top, animated: false)

                #expect(tableView.contentOffset == initialOffset)
            }

            // MARK: - safeScrollToBottom Tests

            @Test func `safe scroll to bottom with an empty last section does not scroll`() {
                let (tableView, dataSource) = makeScrollableTableView(trailingEmptySection: true)

                tableView.safeScrollToBottom()

                #expect(tableView.contentOffset == .zero)
                withExtendedLifetime(dataSource) {}
            }

            @Test func `safe scroll to bottom reveals the last row`() {
                let (tableView, dataSource) = makeScrollableTableView()

                tableView.safeScrollToBottom(animated: false)

                let lastRow = tableView.rectForRow(at: IndexPath(row: 99, section: 0))
                #expect(tableView.contentOffset.y > 0)
                #expect(tableView.bounds.contains(lastRow))
                withExtendedLifetime(dataSource) {}
            }

            // MARK: - reload Tests

            @Test func `reload not animated reloads data`() {
                let tableView = UITableView()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
                let dataSource = SimpleTableDataSource(sections: [["A"]])
                tableView.dataSource = dataSource
                tableView.reloadData()

                dataSource.sections = [["A", "B"]]
                tableView.reload(animated: false)

                #expect(tableView.numberOfRows(inSection: 0) == 2)
            }

            @Test func `reload specific index paths not animated reloads only those rows`() {
                let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
                let dataSource = SimpleTableDataSource(sections: [["A", "B"]])
                tableView.dataSource = dataSource
                tableView.reloadData()
                tableView.layoutIfNeeded()

                dataSource.sections = [["Y", "Z"]]
                tableView.reload(at: [IndexPath(row: 0, section: 0)], animated: false)
                tableView.layoutIfNeeded()

                #expect(tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.textLabel?.text == "Y")
                #expect(tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.textLabel?.text == "B")
            }

            /// A laid-out table with 100 rows, taller than its 480 point frame.
            private func makeScrollableTableView(trailingEmptySection: Bool = false) -> (UITableView, SimpleTableDataSource) {
                let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
                let rows = (0 ..< 100).map { "Row \($0)" }
                let dataSource = SimpleTableDataSource(sections: trailingEmptySection ? [rows, []] : [rows])
                tableView.dataSource = dataSource
                tableView.reloadData()
                tableView.layoutIfNeeded()
                return (tableView, dataSource)
            }
        }
    #endif

#endif
