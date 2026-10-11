#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    @testable import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    @MainActor struct ThemeTests {

        // MARK: - Initialization

        @Test func `initialize theme with all parameters`() {
            let definition = ThemeDefinition()
            let scheme: ColorScheme = .light
            let contrast: ColorSchemeContrast = .standard
            let dynamicTypeSize: DynamicTypeSize = .medium

            let theme = Theme(
                definition: definition,
                scheme: scheme,
                contrast: contrast,
                dynamicTypeSize: dynamicTypeSize
            )

            #expect(theme.scheme == .light)
            #expect(theme.contrast == .standard)
            #expect(theme.primary == definition.primary.getColor(scheme: .light, contrast: .standard))
        }

        @Test func `initialize theme with dark scheme`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .dark,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            #expect(theme.scheme == .dark)
            #expect(theme.primary == definition.primary.getColor(scheme: .dark))
            #expect(theme.primary != definition.primary.getColor(scheme: .light))
        }

        @Test func `initialize theme with increased contrast`() {
            var definition = ThemeDefinition()
            definition.primary = ThemeColor(light: .red, dark: .blue, lightContrast: .orange)
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .increased,
                dynamicTypeSize: .medium
            )

            #expect(theme.contrast == .increased)
            #expect(theme.primary == .orange)
        }

        @Test func `initialize theme with different dynamic type sizes`() {
            let definition = ThemeDefinition()

            let smallTheme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .small
            )

            let largeTheme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .xxxLarge
            )

            // Dynamic type sizes scale fonts, not colors.
            #expect(smallTheme.primary == largeTheme.primary)
            #expect(smallTheme.text1 == largeTheme.text1)
        }

        // MARK: - Primary Colors

        @Test func `primary color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let primary = theme.primary
            let expected = definition.primary.getColor(scheme: .light, contrast: .standard)

            #expect(primary == expected)
        }

        @Test func `text over primary color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let textOverPrimary = theme.textOverPrimary
            let expected = definition.textOverPrimary.getColor(scheme: .light, contrast: .standard)

            #expect(textOverPrimary == expected)
        }

        // MARK: - Secondary Colors

        @Test func `secondary color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let secondary = theme.secondary
            let expected = definition.secondary.getColor(scheme: .light, contrast: .standard)

            #expect(secondary == expected)
        }

        @Test func `text over secondary color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let textOverSecondary = theme.textOverSecondary
            let expected = definition.textOverSecondary.getColor(scheme: .light, contrast: .standard)

            #expect(textOverSecondary == expected)
        }

        // MARK: - Background Colors

        @Test func `background 1 color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let background1 = theme.background1
            let expected = definition.background1.getColor(scheme: .light, contrast: .standard)

            #expect(background1 == expected)
        }

        @Test func `background 2 color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let background2 = theme.background2
            let expected = definition.background2.getColor(scheme: .light, contrast: .standard)

            #expect(background2 == expected)
        }

        @Test func `background 3 color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let background3 = theme.background3
            let expected = definition.background3.getColor(scheme: .light, contrast: .standard)

            #expect(background3 == expected)
        }

        // MARK: - Text Colors

        @Test func `text 1 color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let text1 = theme.text1
            let expected = definition.text1.getColor(scheme: .light, contrast: .standard)

            #expect(text1 == expected)
        }

        @Test func `text 2 color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let text2 = theme.text2
            let expected = definition.text2.getColor(scheme: .light, contrast: .standard)

            #expect(text2 == expected)
        }

        @Test func `text 3 color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let text3 = theme.text3
            let expected = definition.text3.getColor(scheme: .light, contrast: .standard)

            #expect(text3 == expected)
        }

        // MARK: - TextField Colors

        @Test func `text field color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let textField = theme.textField
            let expected = definition.textField.getColor(scheme: .light, contrast: .standard)

            #expect(textField == expected)
        }

        @Test func `text field edit color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let textFieldEdit = theme.textFieldEdit
            let expected = definition.textFieldEdit.getColor(scheme: .light, contrast: .standard)

            #expect(textFieldEdit == expected)
        }

        @Test func `text field placeholder color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let textFieldPlaceholder = theme.textFieldPlaceholder
            let expected = definition.textFieldPlaceholder.getColor(scheme: .light, contrast: .standard)

            #expect(textFieldPlaceholder == expected)
        }

        // MARK: - Status Colors: Success

        @Test func `success color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let success = theme.success
            let expected = definition.success.getColor(scheme: .light, contrast: .standard)

            #expect(success == expected)
        }

        @Test func `text over success color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let textOverSuccess = theme.textOverSuccess
            let expected = definition.textOverSuccess.getColor(scheme: .light, contrast: .standard)

            #expect(textOverSuccess == expected)
        }

        // MARK: - Status Colors: InProgress

        @Test func `in progress color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let inProgress = theme.inProgress
            let expected = definition.inProgress.getColor(scheme: .light, contrast: .standard)

            #expect(inProgress == expected)
        }

        @Test func `text over in progress color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let textOverInProgress = theme.textOverInProgress
            let expected = definition.textOverInProgress.getColor(scheme: .light, contrast: .standard)

            #expect(textOverInProgress == expected)
        }

        // MARK: - Status Colors: Warning

        @Test func `warning color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let warning = theme.warning
            let expected = definition.warning.getColor(scheme: .light, contrast: .standard)

            #expect(warning == expected)
        }

        @Test func `text over warning color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let textOverWarning = theme.textOverWarning
            let expected = definition.textOverWarning.getColor(scheme: .light, contrast: .standard)

            #expect(textOverWarning == expected)
        }

        // MARK: - Status Colors: Error

        @Test func `error color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let error = theme.error
            let expected = definition.error.getColor(scheme: .light, contrast: .standard)

            #expect(error == expected)
        }

        @Test func `text over error color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let textOverError = theme.textOverError
            let expected = definition.textOverError.getColor(scheme: .light, contrast: .standard)

            #expect(textOverError == expected)
        }

        // MARK: - Status Colors: Info

        @Test func `info color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let info = theme.info
            let expected = definition.info.getColor(scheme: .light, contrast: .standard)

            #expect(info == expected)
        }

        @Test func `text over info color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let textOverInfo = theme.textOverInfo
            let expected = definition.textOverInfo.getColor(scheme: .light, contrast: .standard)

            #expect(textOverInfo == expected)
        }

        // MARK: - Status Colors: Inactive

        @Test func `inactive color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let inactive = theme.inactive
            let expected = definition.inactive.getColor(scheme: .light, contrast: .standard)

            #expect(inactive == expected)
        }

        @Test func `text over inactive color delegates to definition`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let textOverInactive = theme.textOverInactive
            let expected = definition.textOverInactive.getColor(scheme: .light, contrast: .standard)

            #expect(textOverInactive == expected)
        }

        // MARK: - Special Colors: Transparent

        @Test func `transparent color is always clear`() {
            let definition = ThemeDefinition()
            let lightTheme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let darkTheme = Theme(
                definition: definition,
                scheme: .dark,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            #expect(lightTheme.transparent == .clear)
            #expect(darkTheme.transparent == .clear)
        }

        @Test func `transparent color is independent of contrast`() {
            let definition = ThemeDefinition()
            let standardTheme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let increasedTheme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .increased,
                dynamicTypeSize: .medium
            )

            #expect(standardTheme.transparent == .clear)
            #expect(increasedTheme.transparent == .clear)
        }

        // MARK: - Gradients: BackgroundGradient

        // The default primary is #066CDB (6, 108, 219) in light mode and that color lightened by 10%,
        // (31, 123, 223), in dark mode. The default secondary is #615AE4 (97, 90, 228) and (113, 107, 231).

        @Test func `background gradient lightens primary in light mode`() throws {
            let theme = Theme(definition: ThemeDefinition(), scheme: .light, contrast: .standard, dynamicTypeSize: .medium)

            let bitmap = try Self.render(theme.backgroundGradient)

            // Primary lightened by 65% and 90%.
            Self.expect(bitmap.pixel(x: 0, y: 0), near: Self.rgb(168, 204, 242))
            Self.expect(bitmap.pixel(x: bitmap.width - 1, y: bitmap.height - 1), near: Self.rgb(230, 240, 251))
        }

        @Test func `background gradient darkens primary in dark mode`() throws {
            let theme = Theme(definition: ThemeDefinition(), scheme: .dark, contrast: .standard, dynamicTypeSize: .medium)

            let bitmap = try Self.render(theme.backgroundGradient)

            // Dark primary darkened by 65% and 90%.
            Self.expect(bitmap.pixel(x: 0, y: 0), near: Self.rgb(11, 43, 78))
            Self.expect(bitmap.pixel(x: bitmap.width - 1, y: bitmap.height - 1), near: Self.rgb(3, 12, 22))
        }

        // MARK: - Gradients: TitleGradient

        @Test func `title gradient from primary to secondary`() throws {
            let theme = Theme(definition: ThemeDefinition(), scheme: .light, contrast: .standard, dynamicTypeSize: .medium)

            let bitmap = try Self.render(theme.titleGradient)

            Self.expect(bitmap.pixel(x: 0, y: 0), near: Self.rgb(6, 108, 219))
            Self.expect(bitmap.pixel(x: bitmap.width - 1, y: bitmap.height - 1), near: Self.rgb(97, 90, 228))
        }

        @Test func `title gradient uses the scheme's primary and secondary`() throws {
            let theme = Theme(definition: ThemeDefinition(), scheme: .dark, contrast: .standard, dynamicTypeSize: .medium)

            let bitmap = try Self.render(theme.titleGradient)

            Self.expect(bitmap.pixel(x: 0, y: 0), near: Self.rgb(31, 123, 223))
            Self.expect(bitmap.pixel(x: bitmap.width - 1, y: bitmap.height - 1), near: Self.rgb(113, 107, 231))
        }

        // MARK: - Color Scheme Variations

        @Test func `all colors respect dark scheme`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .dark,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            // Verify colors are retrieved with dark scheme
            let primary = theme.primary
            let expected = definition.primary.getColor(scheme: .dark, contrast: .standard)
            #expect(primary == expected)
        }

        @Test func `all colors respect increased contrast`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .light,
                contrast: .increased,
                dynamicTypeSize: .medium
            )

            // Verify colors are retrieved with increased contrast
            let primary = theme.primary
            let expected = definition.primary.getColor(scheme: .light, contrast: .increased)
            #expect(primary == expected)
        }

        @Test func `all colors respect dark scheme with increased contrast`() {
            let definition = ThemeDefinition()
            let theme = Theme(
                definition: definition,
                scheme: .dark,
                contrast: .increased,
                dynamicTypeSize: .medium
            )

            // Verify colors are retrieved with dark scheme and increased contrast
            let primary = theme.primary
            let expected = definition.primary.getColor(scheme: .dark, contrast: .increased)
            #expect(primary == expected)
        }

        // MARK: - Custom Definition

        @Test func `custom definition affects colors`() {
            var customDefinition = ThemeDefinition()
            customDefinition.primary = ThemeColor(light: .red, dark: .blue)

            let theme = Theme(
                definition: customDefinition,
                scheme: .light,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let primary = theme.primary
            #expect(primary == .red)
        }

        @Test func `custom definition respected in dark mode`() {
            var customDefinition = ThemeDefinition()
            customDefinition.primary = ThemeColor(light: .red, dark: .blue)

            let theme = Theme(
                definition: customDefinition,
                scheme: .dark,
                contrast: .standard,
                dynamicTypeSize: .medium
            )

            let primary = theme.primary
            #expect(primary == .blue)
        }

        // MARK: - Helpers

        private static func rgb(_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> RenderedBitmap.Pixel {
            RenderedBitmap.Pixel(red: red, green: green, blue: blue, alpha: 255)
        }

        /// Renders the gradient large enough that corner pixels sit within 0.05% of the gradient's end points.
        private static func render(_ gradient: LinearGradient) throws -> RenderedBitmap {
            try #require(RenderedBitmap(rendering: Rectangle().fill(gradient).frame(width: 1000, height: 1000)))
        }

        /// Allows for the rounding of saturated colors through the renderer's working color space.
        private static func expect(_ pixel: RenderedBitmap.Pixel, near expected: RenderedBitmap.Pixel, sourceLocation: SourceLocation = #_sourceLocation) {
            #expect(pixel.isClose(to: expected, tolerance: 6), "\(pixel) is not close to \(expected)", sourceLocation: sourceLocation)
        }
    }

#endif
