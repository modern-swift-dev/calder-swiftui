import CalderStdLib
import Testing

struct DoubleDistanceTests {
    @Test func `distance conversions`() {
        #expect(1.0.degreesToMeters == 111_120.00071117)
        #expect(1000.0.metersToDegrees == 1000.0 / 111_120.00071117)
    }

    @Test func `angle conversions`() {
        #expect(180.0.degreesToRadians == .pi)
        #expect(Double.pi.radiansToDegrees == 180)
    }
}
