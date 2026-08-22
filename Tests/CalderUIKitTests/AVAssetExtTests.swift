#if canImport(AVFoundation) && (os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS))
import AVFoundation
import CalderUIKit
import Foundation
import Testing

@Suite(.serialized) struct AVAssetExtTests {

    @Test func `thumbnail with missing file throws`() async {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("missing-video-\(UUID()).mov")

        do {
            _ = try await AVAsset.thumbnail(url: url)
            Issue.record("Expected thumbnail generation to throw")
        } catch {
            #expect(error is AVAsset.ThumbnailError)
        }
    }

    @Test func `thumbnail data with missing file throws`() async {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("missing-video-\(UUID()).mov")

        do {
            _ = try await AVAsset.thumbnailData(url: url)
            Issue.record("Expected thumbnail data generation to throw")
        } catch {
            #expect(error is AVAsset.ThumbnailError)
        }
    }
}
#endif
