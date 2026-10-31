#if canImport(UIKit) && canImport(Vision) && !os(visionOS) && !os(watchOS)
    /// Decides which detections of a continuously scanning ``BarcodeScannerView`` to report.
    ///
    /// A value is reported when it hasn't been reported within the cooldown. Each value has its own cooldown,
    /// which counts from the last time that value was reported, so a different code is always reported.
    struct BarcodeScanCooldown: Sendable {
        /// How long a reported value is suppressed.
        let duration: Duration

        /// When each recently reported value was last reported.
        private var reports: [String: ContinuousClock.Instant] = [:]

        /// The number of reported values still inside their cooldown.
        var trackedValueCount: Int {
            reports.count
        }

        /// Creates a cooldown.
        /// - Parameter duration: How long a reported value is suppressed.
        init(duration: Duration) {
            self.duration = duration
        }

        /// Returns whether to report a detection of `code`, and starts its cooldown when it does.
        /// - Parameters:
        ///   - code: The detected value.
        ///   - now: The time of the detection.
        /// - Returns: `true` if `code` hasn't been reported within the cooldown.
        mutating func shouldReport(_ code: String, at now: ContinuousClock.Instant) -> Bool {
            reports = reports.filter { now - $0.value < duration }
            guard reports[code] == nil else {
                return false
            }
            reports[code] = now
            return true
        }

        /// Forgets every reported value, so each is reported on its next detection.
        mutating func reset() {
            reports.removeAll()
        }
    }
#endif
