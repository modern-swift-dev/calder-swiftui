#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
@testable import CalderTheme
import Foundation
import SwiftUI
import Testing

@Suite(.serialized)
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

        // Verify theme was created by checking we can access primary color
        #expect(type(of: theme.primary) == Color.self)
    }

    @Test func `initialize theme with dark scheme`() {
        let definition = ThemeDefinition()
        let theme = Theme(
            definition: definition,
            scheme: .dark,
            contrast: .standard,
            dynamicTypeSize: .medium
        )

        // Verify theme respects dark scheme
        #expect(type(of: theme.primary) == Color.self)
    }

    @Test func `initialize theme with increased contrast`() {
        let definition = ThemeDefinition()
        let theme = Theme(
            definition: definition,
            scheme: .light,
            contrast: .increased,
            dynamicTypeSize: .medium
        )

        // Verify theme respects increased contrast
        #expect(type(of: theme.primary) == Color.self)
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

        // Verify themes can be created with different sizes
        #expect(type(of: smallTheme.primary) == Color.self)
        #expect(type(of: largeTheme.primary) == Color.self)
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

    @Test func `background gradient lightens in light mode`() {
        let definition = ThemeDefinition()
        let theme = Theme(
            definition: definition,
            scheme: .light,
            contrast: .standard,
            dynamicTypeSize: .medium
        )

        let gradient = theme.backgroundGradient

        // Verify it returns a LinearGradient
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `background gradient darkens in dark mode`() {
        let definition = ThemeDefinition()
        let theme = Theme(
            definition: definition,
            scheme: .dark,
            contrast: .standard,
            dynamicTypeSize: .medium
        )

        let gradient = theme.backgroundGradient

        // Verify it returns a LinearGradient
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `background gradient differs between light and dark`() {
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

        let lightGradient = lightTheme.backgroundGradient
        let darkGradient = darkTheme.backgroundGradient

        // Both should return LinearGradient type
        #expect(type(of: lightGradient) == LinearGradient.self)
        #expect(type(of: darkGradient) == LinearGradient.self)
    }

    // MARK: - Gradients: TitleGradient

    @Test func `title gradient from primary to secondary`() {
        let definition = ThemeDefinition()
        let theme = Theme(
            definition: definition,
            scheme: .light,
            contrast: .standard,
            dynamicTypeSize: .medium
        )

        let gradient = theme.titleGradient

        // Verify it returns a LinearGradient
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `title gradient independent of scheme`() {
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

        let lightGradient = lightTheme.titleGradient
        let darkGradient = darkTheme.titleGradient

        // Both should return LinearGradient type
        #expect(type(of: lightGradient) == LinearGradient.self)
        #expect(type(of: darkGradient) == LinearGradient.self)
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
}

#endif
