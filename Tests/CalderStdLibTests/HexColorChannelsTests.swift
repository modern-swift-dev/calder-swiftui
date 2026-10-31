@testable import CalderStdLib
import Testing

struct HexColorChannelsTests {

    @Test func `format does not trap on nan`() {
        #expect(HexColorChannels.format([.nan, 1, .nan], prefix: "#") == "#00FF00")
    }

    @Test func `format clamps and rounds`() {
        #expect(HexColorChannels.format([-0.5, 2, 0.5, .infinity, -.infinity], prefix: "") == "00FF80FF00")
    }
}
