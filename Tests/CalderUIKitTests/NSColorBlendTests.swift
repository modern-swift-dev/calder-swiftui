#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
    import CalderUIKit
    import Testing

    struct NSColorBlendTests {

        @Test func `brighten preserves alpha`() {
            let color = NSColor(srgbRed: 0.2, green: 0.4, blue: 0.6, alpha: 0.4)
            #expect(abs(color.brighten(0.2).alphaComponent - 0.4) < 0.01)
        }

        @Test func `dim preserves alpha`() {
            let color = NSColor(srgbRed: 0.2, green: 0.4, blue: 0.6, alpha: 0.4)
            #expect(abs(color.dim(0.2).alphaComponent - 0.4) < 0.01)
        }
    }
#endif
