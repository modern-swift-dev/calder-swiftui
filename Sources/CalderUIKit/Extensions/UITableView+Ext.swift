#if canImport(Darwin)
#if !os(macOS) && !os(watchOS)
import Foundation
import UIKit

public extension UITableView {

    /// Registers a reusable `UITableViewCell` subclass with the table view.
    /// The reuse identifier is automatically derived from the class name.
    /// - Parameter type: The `UITableViewCell` subclass to register.
    func registerReusableCell(type: (some UITableViewCell).Type) {
        register(type, forCellReuseIdentifier: String(describing: type))
    }

    /// Dequeues a reusable `UITableViewCell` for a given `IndexPath`.
    /// - Parameters:
    ///   - type: The `UITableViewCell` subclass to dequeue.
    ///   - indexPath: The `IndexPath` for which to dequeue the cell.
    /// - Returns: An instance of the specified `UITableViewCell` subclass.
    /// - FatalError: If the cell with the derived identifier is not registered or cannot be cast to the specified type.
    func dequeueReusableCell<T: UITableViewCell>(type: T.Type, for indexPath: IndexPath) -> T {
        let identifier = String(describing: type)
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("\(identifier) not registered!")
        }
        return cell
    }

    /// Safely scrolls the table view to the bottom.
    /// - Parameter animated: A boolean indicating whether the scroll should be animated. Defaults to `false`.
    func safeScrollToBottom(animated: Bool = false) {
        guard let indexPath = indexPathForLastRow else {
            return
        }
        safeScrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    /// Safely scrolls to a potentially invalid `IndexPath`.
    /// This method checks if the `indexPath` is valid before attempting to scroll, preventing crashes.
    /// - Parameters:
    ///   - indexPath: The target `IndexPath` to scroll to.
    ///   - scrollPosition: The position to scroll the row to within the table view.
    ///   - animated: A boolean indicating whether to animate the scroll.
    func safeScrollToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        guard indexPath.section < numberOfSections else {
            return
        }
        guard indexPath.row < numberOfRows(inSection: indexPath.section) else {
            return
        }
        scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
    }

    /// Reloads the table view, either specific rows or the entire data.
    /// - Parameters:
    ///   - indexPath: An array of `IndexPath`s to reload. If empty, the entire table view is reloaded. Defaults to an empty array.
    ///   - animated: A boolean indicating whether to animate the reload. Defaults to `true`.
    ///   - duration: The duration of the reload animation. Defaults to 0.3 seconds.
    ///   - options: The animation options for the reload. Defaults to `.transitionCrossDissolve`.
    ///   - completion: An optional completion handler to call after the animation finishes.
    func reload(
        at indexPath: [IndexPath] = [],
        animated: Bool = true,
        duration: TimeInterval = 0.3,
        options: UIView.AnimationOptions = .transitionCrossDissolve,
        completion: ((Bool) -> Void)? = nil
    ) {
        guard animated else {
            if !indexPath.isEmpty {
                reloadRows(at: indexPath, with: .automatic)
            } else {
                reloadData()
            }
            return
        }

        UIView.transition(
            with: self,
            duration: duration,
            options: options,
            animations: { [weak self] in
                guard let self else {
                    return
                }
                if !indexPath.isEmpty {
                    self.reloadRows(at: indexPath, with: .automatic)
                } else {
                    self.reloadData()
                }
            },
            completion: completion
        )
    }
}

#if canImport(UIKit) && !os(watchOS)

// MARK: - Properties

public extension UITableView {
    /// The `IndexPath` of the last row in the table view.
    var indexPathForLastRow: IndexPath? {
        guard let lastSection else {
            return nil
        }
        return indexPathForLastRow(inSection: lastSection)
    }

    /// The index of the last section in the table view. Returns `nil` if there are no sections.
    var lastSection: Int? {
        numberOfSections > 0 ? numberOfSections - 1 : nil
    }
}

// MARK: - Methods

public extension UITableView {

    /// Returns the `IndexPath` for the last row in a specific section.
    /// - Parameter section: The section to get the last row in.
    /// - Returns: An optional `IndexPath` for the last row in the section, or `nil` if the section is invalid.
    func indexPathForLastRow(inSection section: Int) -> IndexPath? {
        guard numberOfSections > 0, section >= 0 else {
            return nil
        }
        guard numberOfRows(inSection: section) > 0 else {
            return IndexPath(row: 0, section: section)
        }
        return IndexPath(row: numberOfRows(inSection: section) - 1, section: section)
    }

    /// Checks whether an `IndexPath` is valid within the table view.
    /// - Parameter indexPath: An `IndexPath` to check.
    /// - Returns: `true` if the `IndexPath` is valid, `false` otherwise.
    func isValidIndexPath(_ indexPath: IndexPath) -> Bool {
        indexPath.section >= 0 &&
            indexPath.row >= 0 &&
            indexPath.section < numberOfSections &&
            indexPath.row < numberOfRows(inSection: indexPath.section)
    }
}

#endif
#endif

#endif
