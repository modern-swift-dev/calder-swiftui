#if canImport(Darwin)
    #if !os(macOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)
        import UIKit

        /// Turns picker results into images.
        enum ImagePickerResults {

            /// Loads an image for each item in order, skipping items that have none.
            /// - Parameters:
            ///   - items: The picker results, such as `NSItemProvider` values.
            ///   - limit: The most images to load; zero or less means no limit.
            ///   - load: Loads one item's image, or returns `nil` when the item has no image.
            /// - Returns: The loaded images, in the order of `items`.
            /// - Throws: The first error `load` throws.
            @MainActor
            static func images<Item>(
                from items: [Item],
                limit: Int,
                load: @MainActor (Item) async throws -> UIImage?
            ) async throws -> [UIImage] {
                var images: [UIImage] = []
                for item in items {
                    if limit > 0, images.count >= limit {
                        break
                    }
                    if let image = try await load(item) {
                        images.append(image)
                    }
                }
                return images
            }
        }
    #endif

#endif
