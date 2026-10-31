#if canImport(AVFoundation) && (os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS))
    import AVFoundation
    import CalderUIKit
    import Foundation
    import Testing

    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        import AppKit
    #else
        import UIKit
    #endif

    struct AVAssetExtTests {

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

        @Test(.timeLimit(.minutes(1))) func `thumbnail of a real video returns an image`() async throws {
            let url = try await Self.makeVideo()
            defer { try? FileManager.default.removeItem(at: url) }

            let image = try await AVAsset.thumbnail(url: url)

            #expect(image.size.width > 0)
            #expect(image.size.height > 0)
        }

        @Test(.timeLimit(.minutes(1))) func `thumbnail data of a real video returns data`() async throws {
            let url = try await Self.makeVideo()
            defer { try? FileManager.default.removeItem(at: url) }

            let data = try await AVAsset.thumbnailData(url: url)

            #expect(data?.isEmpty == false)
        }

        private static func makeVideo() async throws -> URL {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("calder-video-\(UUID()).mov")
            let writer = try AVAssetWriter(outputURL: url, fileType: .mov)
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: 64,
                AVVideoHeightKey: 64
            ])
            let adaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: input,
                sourcePixelBufferAttributes: [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                    kCVPixelBufferWidthKey as String: 64,
                    kCVPixelBufferHeightKey as String: 64
                ]
            )
            writer.add(input)
            writer.startWriting()
            writer.startSession(atSourceTime: .zero)

            for frame in 0 ..< 3 {
                var buffer: CVPixelBuffer?
                CVPixelBufferCreate(nil, 64, 64, kCVPixelFormatType_32BGRA, nil, &buffer)
                while !input.isReadyForMoreMediaData {
                    try await Task.sleep(for: .milliseconds(10))
                }
                if let buffer {
                    adaptor.append(buffer, withPresentationTime: CMTime(value: CMTimeValue(frame), timescale: 10))
                }
            }
            input.markAsFinished()
            await writer.finishWriting()
            return url
        }
    }
#endif
