#if canImport(Darwin)
    #if os(iOS) || targetEnvironment(macCatalyst)
        import AVFoundation
        @testable import CalderUIKit
        import CoreGraphics
        import Testing
        import UIKit

        @MainActor struct AVMetadataMachineReadableCodeObjectExtTests {

            @Test func `code rect spans the x and y extents of its corners`() {
                let corners = [CGPoint(x: 100, y: 300), CGPoint(x: 200, y: 310), CGPoint(x: 190, y: 400), CGPoint(x: 90, y: 390)]

                let rect = AVMetadataMachineReadableCodeObject.boundingRect(of: corners)

                #expect(rect == CGRect(x: 90, y: 300, width: 110, height: 100))
            }

            @Test func `code rect without corners is empty`() {
                #expect(AVMetadataMachineReadableCodeObject.boundingRect(of: []) == .zero)
            }

            @Test func `code path cuts the code out of the preview with the even odd rule`() {
                let corners = [CGPoint(x: 40, y: 40), CGPoint(x: 60, y: 40), CGPoint(x: 60, y: 60), CGPoint(x: 40, y: 60)]

                let path = AVMetadataMachineReadableCodeObject.cutOutPath(in: CGRect(x: 0, y: 0, width: 100, height: 100), around: corners)
                path.usesEvenOddFillRule = true

                #expect(path.contains(CGPoint(x: 10, y: 10)))
                #expect(!path.contains(CGPoint(x: 50, y: 50)))
                #expect(!path.contains(CGPoint(x: 150, y: 150)))
            }
        }
    #endif

#endif
