#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if canImport(UIKit) && canImport(Vision) && !os(visionOS) && !os(watchOS)
        @testable import CalderTheme
        import Testing

        struct BarcodeScanCooldownTests {
            private let start = ContinuousClock.now

            /// A cooldown behind a reference, so `#expect` can call its mutating methods.
            private final class Cooldown {
                private var cooldown: BarcodeScanCooldown

                init(duration: Duration) {
                    cooldown = BarcodeScanCooldown(duration: duration)
                }

                var trackedValueCount: Int {
                    cooldown.trackedValueCount
                }

                func shouldReport(_ code: String, at now: ContinuousClock.Instant) -> Bool {
                    cooldown.shouldReport(code, at: now)
                }

                func reset() {
                    cooldown.reset()
                }
            }

            @Test func `distinct codes are each reported`() {
                let cooldown = Cooldown(duration: .seconds(2))

                #expect(cooldown.shouldReport("a", at: start))
                #expect(cooldown.shouldReport("b", at: start))
                #expect(cooldown.shouldReport("c", at: start + .milliseconds(10)))
            }

            @Test func `the same value is suppressed within the cooldown`() {
                let cooldown = Cooldown(duration: .seconds(2))

                #expect(cooldown.shouldReport("a", at: start))
                #expect(!cooldown.shouldReport("a", at: start + .milliseconds(1)))
                #expect(!cooldown.shouldReport("a", at: start + .milliseconds(1999)))
            }

            @Test func `the same value is reported again after the cooldown`() {
                let cooldown = Cooldown(duration: .seconds(2))

                #expect(cooldown.shouldReport("a", at: start))
                #expect(cooldown.shouldReport("a", at: start + .seconds(2)))
            }

            @Test func `the cooldown counts from the last report`() {
                let cooldown = Cooldown(duration: .seconds(2))

                #expect(cooldown.shouldReport("a", at: start))
                #expect(!cooldown.shouldReport("a", at: start + .seconds(1)))
                #expect(cooldown.shouldReport("a", at: start + .seconds(2)))
                #expect(!cooldown.shouldReport("a", at: start + .seconds(3)))
                #expect(cooldown.shouldReport("a", at: start + .seconds(4)))
            }

            @Test func `each value has its own cooldown`() {
                let cooldown = Cooldown(duration: .seconds(2))

                #expect(cooldown.shouldReport("a", at: start))
                #expect(cooldown.shouldReport("b", at: start + .seconds(1)))
                #expect(!cooldown.shouldReport("a", at: start + .seconds(1)))
                #expect(!cooldown.shouldReport("b", at: start + .seconds(2)))
                #expect(cooldown.shouldReport("a", at: start + .seconds(2)))
            }

            @Test func `the cooldown is configurable`() {
                let short = Cooldown(duration: .milliseconds(100))
                let long = Cooldown(duration: .seconds(10))

                #expect(short.shouldReport("a", at: start))
                #expect(short.shouldReport("a", at: start + .milliseconds(100)))
                #expect(long.shouldReport("a", at: start))
                #expect(!long.shouldReport("a", at: start + .seconds(9)))
                #expect(long.shouldReport("a", at: start + .seconds(10)))
            }

            @Test func `a zero cooldown reports every detection`() {
                let cooldown = Cooldown(duration: .zero)

                #expect(cooldown.shouldReport("a", at: start))
                #expect(cooldown.shouldReport("a", at: start))
            }

            @Test func `resetting forgets every value`() {
                let cooldown = Cooldown(duration: .seconds(2))
                #expect(cooldown.shouldReport("a", at: start))

                cooldown.reset()

                #expect(cooldown.shouldReport("a", at: start + .milliseconds(1)))
            }

            @Test func `expired values are forgotten`() {
                let cooldown = Cooldown(duration: .seconds(1))
                for index in 0 ..< 100 {
                    #expect(cooldown.shouldReport("code \(index)", at: start))
                }

                #expect(cooldown.shouldReport("fresh", at: start + .seconds(5)))

                #expect(cooldown.trackedValueCount == 1)
            }
        }
    #endif

#endif
