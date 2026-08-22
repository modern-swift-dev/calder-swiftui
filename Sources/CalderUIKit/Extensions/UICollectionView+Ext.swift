#if canImport(Darwin)
#if !os(macOS) && !os(watchOS)
import Foundation
import UIKit

public extension UICollectionView {

    /// Safely scrolls to a potentially invalid `IndexPath`.
    /// This method checks if the `indexPath` is valid before attempting to scroll, preventing crashes.
    /// - Parameters:
    ///   - indexPath: The target `IndexPath` to scroll to.
    ///   - scrollPosition: The position to scroll the item to within the collection view.
    ///   - animated: A boolean indicating whether to animate the scroll.
    func safeScrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard indexPath.item >= 0,
              indexPath.section >= 0,
              indexPath.section < numberOfSections,
              indexPath.item < numberOfItems(inSection: indexPath.section) else {
            return
        }
        scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }

    /// Scrolls to the specified cell.
    /// This method is designed to bypass potential bugs where horizontal collection views with paging enabled
    /// might not scroll correctly. It uses layout attributes for more precise scrolling.
    /// - Parameters:
    ///   - indexPath: The `IndexPath` of the cell to scroll to.
    ///   - translateX: The horizontal translation to apply to the scroll position. Defaults to 0.0.
    ///   - translateY: The vertical translation to apply to the scroll position. Defaults to 0.0.
    ///   - animated: A boolean indicating whether the scroll should be animated. Defaults to `true`.
    /// - Returns: `true` if the scroll occurred, `false` otherwise.
    func scrollToCell(at indexPath: IndexPath, translateX: CGFloat = 0.0, translateY: CGFloat = 0.0, animated: Bool = true) -> Bool {
        if let rect = layoutAttributesForItem(at: indexPath)?.frame.applying(.init(translationX: translateX, y: translateY)) {
            scrollRectToVisible(rect, animated: animated)
            return true
        }
        return false
    }

    /// Safely scrolls the collection view to the bottom.
    /// - Parameter animated: A boolean indicating whether the scroll should be animated. Defaults to `false`.
    func safeScrollToBottom(animated: Bool = false) {
        guard let indexPath = indexPathForLastItem else {
            return
        }
        safeScrollToItem(at: indexPath, at: .bottom, animated: animated)
    }

    /// Reloads the collection view, either specific items or the entire data.
    /// - Parameters:
    ///   - indexPath: An array of `IndexPath`s to reload. If empty, the entire collection view is reloaded. Defaults to an empty array.
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
                reloadItems(at: indexPath)
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
                    self.reloadItems(at: indexPath)
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

public extension UICollectionView {
    /// The `IndexPath` of the last item in the collection view.
    var indexPathForLastItem: IndexPath? {
        indexPathForLastItem(inSection: lastSection)
    }

    /// The index of the last section in the collection view. Returns 0 if there are no sections.
    var lastSection: Int {
        numberOfSections > 0 ? numberOfSections - 1 : 0
    }
}

// MARK: - Methods

public extension UICollectionView {

    /// Returns the `IndexPath` for the last item in a specific section.
    /// - Parameter section: The section to get the last item in.
    /// - Returns: An optional `IndexPath` for the last item in the section, or `nil` if the section is invalid.
    func indexPathForLastItem(inSection section: Int) -> IndexPath? {
        guard section >= 0 else {
            return nil
        }
        guard section < numberOfSections else {
            return nil
        }
        guard numberOfItems(inSection: section) > 0 else {
            return IndexPath(item: 0, section: section)
        }
        return IndexPath(item: numberOfItems(inSection: section) - 1, section: section)
    }

    /// Checks whether an `IndexPath` is valid within the collection view.
    /// - Parameter indexPath: An `IndexPath` to check.
    /// - Returns: `true` if the `IndexPath` is valid, `false` otherwise.
    func isValidIndexPath(_ indexPath: IndexPath) -> Bool {
        indexPath.section >= 0 &&
            indexPath.item >= 0 &&
            indexPath.section < numberOfSections &&
            indexPath.item < numberOfItems(inSection: indexPath.section)
    }
}

#endif
#endif

#endif
