#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
@testable import CalderTheme
import Foundation
import SwiftUI
import Testing

@Suite(.serialized) struct ThemeDefinitionTests {

    // MARK: - Initialization

    @Test func `initialize with default values`() {
        let definition = ThemeDefinition()

        // Verify definition was created successfully
        #expect(type(of: definition.primary) == ThemeColor.self)
        #expect(type(of: definition.secondary) == ThemeColor.self)
    }

    @Test func `default initializer creates valid colors`() {
        let definition = ThemeDefinition()

        // Verify all color properties exist and can be accessed
        _ = definition.primary
        _ = definition.textOverPrimary
        _ = definition.secondary
        _ = definition.textOverSecondary
        _ = definition.background1
        _ = definition.background2
        _ = definition.background3
        _ = definition.text1
        _ = definition.text2
        _ = definition.text3
        _ = definition.textField
        _ = definition.textFieldEdit
        _ = definition.textFieldPlaceholder
        _ = definition.success
        _ = definition.textOverSuccess
        _ = definition.inProgress
        _ = definition.textOverInProgress
        _ = definition.warning
        _ = definition.textOverWarning
        _ = definition.error
        _ = definition.textOverError
        _ = definition.info
        _ = definition.textOverInfo
        _ = definition.inactive
        _ = definition.textOverInactive
    }

    // MARK: - Primary Colors

    @Test func `primary color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.primary.getColor(scheme: .light, contrast: nil)

        // Verify primary color can be retrieved
        #expect(type(of: color) == Color.self)
    }

    @Test func `primary color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .red, dark: .blue)
        definition.primary = customColor

        let lightColor = definition.primary.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.primary.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .red)
        #expect(darkColor == .blue)
    }

    @Test func `text over primary color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.textOverPrimary.getColor(scheme: .light, contrast: nil)

        // Verify textOverPrimary color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `text over primary color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .black, dark: .white)
        definition.textOverPrimary = customColor

        let lightColor = definition.textOverPrimary.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.textOverPrimary.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .black)
        #expect(darkColor == .white)
    }

    // MARK: - Secondary Colors

    @Test func `secondary color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.secondary.getColor(scheme: .light, contrast: nil)

        // Verify secondary color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `secondary color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .green, dark: .orange)
        definition.secondary = customColor

        let lightColor = definition.secondary.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.secondary.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .green)
        #expect(darkColor == .orange)
    }

    @Test func `text over secondary color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.textOverSecondary.getColor(scheme: .light, contrast: nil)

        // Verify textOverSecondary color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `text over secondary color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .yellow, dark: .purple)
        definition.textOverSecondary = customColor

        let lightColor = definition.textOverSecondary.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.textOverSecondary.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .yellow)
        #expect(darkColor == .purple)
    }

    // MARK: - Background Colors

    @Test func `background 1 color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.background1.getColor(scheme: .light, contrast: nil)

        // Verify background1 color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `background 1 color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .white, dark: .black)
        definition.background1 = customColor

        let lightColor = definition.background1.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.background1.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .white)
        #expect(darkColor == .black)
    }

    @Test func `background 2 color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.background2.getColor(scheme: .light, contrast: nil)

        // Verify background2 color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `background 2 color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .gray, dark: .gray)
        definition.background2 = customColor

        let color = definition.background2.getColor(scheme: .light, contrast: nil)
        #expect(color == .gray)
    }

    @Test func `background 3 color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.background3.getColor(scheme: .light, contrast: nil)

        // Verify background3 color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `background 3 color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .blue, dark: .cyan)
        definition.background3 = customColor

        let lightColor = definition.background3.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.background3.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .blue)
        #expect(darkColor == .cyan)
    }

    // MARK: - Text Colors

    @Test func `text 1 color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.text1.getColor(scheme: .light, contrast: nil)

        // Verify text1 color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `text 1 color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .black, dark: .white)
        definition.text1 = customColor

        let lightColor = definition.text1.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.text1.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .black)
        #expect(darkColor == .white)
    }

    @Test func `text 2 color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.text2.getColor(scheme: .light, contrast: nil)

        // Verify text2 color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `text 2 color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .gray, dark: .gray)
        definition.text2 = customColor

        let color = definition.text2.getColor(scheme: .light, contrast: nil)
        #expect(color == .gray)
    }

    @Test func `text 3 color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.text3.getColor(scheme: .light, contrast: nil)

        // Verify text3 color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `text 3 color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .purple, dark: .pink)
        definition.text3 = customColor

        let lightColor = definition.text3.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.text3.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .purple)
        #expect(darkColor == .pink)
    }

    // MARK: - TextField Colors

    @Test func `text field color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.textField.getColor(scheme: .light, contrast: nil)

        // Verify textField color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `text field color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .white, dark: .black)
        definition.textField = customColor

        let lightColor = definition.textField.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.textField.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .white)
        #expect(darkColor == .black)
    }

    @Test func `text field edit color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.textFieldEdit.getColor(scheme: .light, contrast: nil)

        // Verify textFieldEdit color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `text field edit color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .blue, dark: .orange)
        definition.textFieldEdit = customColor

        let lightColor = definition.textFieldEdit.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.textFieldEdit.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .blue)
        #expect(darkColor == .orange)
    }

    @Test func `text field placeholder color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.textFieldPlaceholder.getColor(scheme: .light, contrast: nil)

        // Verify textFieldPlaceholder color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `text field placeholder color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .gray, dark: .gray)
        definition.textFieldPlaceholder = customColor

        let color = definition.textFieldPlaceholder.getColor(scheme: .light, contrast: nil)
        #expect(color == .gray)
    }

    // MARK: - Status Colors: Success

    @Test func `success color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.success.getColor(scheme: .light, contrast: nil)

        // Verify success color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `success color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .green, dark: .mint)
        definition.success = customColor

        let lightColor = definition.success.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.success.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .green)
        #expect(darkColor == .mint)
    }

    @Test func `text over success color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.textOverSuccess.getColor(scheme: .light, contrast: nil)

        // Verify textOverSuccess color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `text over success color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .white, dark: .black)
        definition.textOverSuccess = customColor

        let lightColor = definition.textOverSuccess.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.textOverSuccess.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .white)
        #expect(darkColor == .black)
    }

    // MARK: - Status Colors: InProgress

    @Test func `in progress color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.inProgress.getColor(scheme: .light, contrast: nil)

        // Verify inProgress color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `in progress color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .orange, dark: .yellow)
        definition.inProgress = customColor

        let lightColor = definition.inProgress.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.inProgress.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .orange)
        #expect(darkColor == .yellow)
    }

    @Test func `text over in progress color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.textOverInProgress.getColor(scheme: .light, contrast: nil)

        // Verify textOverInProgress color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `text over in progress color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .black, dark: .white)
        definition.textOverInProgress = customColor

        let lightColor = definition.textOverInProgress.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.textOverInProgress.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .black)
        #expect(darkColor == .white)
    }

    // MARK: - Status Colors: Warning

    @Test func `warning color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.warning.getColor(scheme: .light, contrast: nil)

        // Verify warning color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `warning color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .yellow, dark: .orange)
        definition.warning = customColor

        let lightColor = definition.warning.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.warning.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .yellow)
        #expect(darkColor == .orange)
    }

    @Test func `text over warning color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.textOverWarning.getColor(scheme: .light, contrast: nil)

        // Verify textOverWarning color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `text over warning color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .black, dark: .black)
        definition.textOverWarning = customColor

        let color = definition.textOverWarning.getColor(scheme: .light, contrast: nil)
        #expect(color == .black)
    }

    // MARK: - Status Colors: Error

    @Test func `error color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.error.getColor(scheme: .light, contrast: nil)

        // Verify error color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `error color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .red, dark: .pink)
        definition.error = customColor

        let lightColor = definition.error.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.error.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .red)
        #expect(darkColor == .pink)
    }

    @Test func `text over error color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.textOverError.getColor(scheme: .light, contrast: nil)

        // Verify textOverError color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `text over error color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .white, dark: .black)
        definition.textOverError = customColor

        let lightColor = definition.textOverError.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.textOverError.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .white)
        #expect(darkColor == .black)
    }

    // MARK: - Status Colors: Info

    @Test func `info color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.info.getColor(scheme: .light, contrast: nil)

        // Verify info color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `info color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .blue, dark: .cyan)
        definition.info = customColor

        let lightColor = definition.info.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.info.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .blue)
        #expect(darkColor == .cyan)
    }

    @Test func `text over info color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.textOverInfo.getColor(scheme: .light, contrast: nil)

        // Verify textOverInfo color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `text over info color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .white, dark: .black)
        definition.textOverInfo = customColor

        let lightColor = definition.textOverInfo.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.textOverInfo.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .white)
        #expect(darkColor == .black)
    }

    // MARK: - Status Colors: Inactive

    @Test func `inactive color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.inactive.getColor(scheme: .light, contrast: nil)

        // Verify inactive color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `inactive color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .gray, dark: .gray)
        definition.inactive = customColor

        let color = definition.inactive.getColor(scheme: .light, contrast: nil)
        #expect(color == .gray)
    }

    @Test func `text over inactive color has default value`() {
        let definition = ThemeDefinition()
        let color = definition.textOverInactive.getColor(scheme: .light, contrast: nil)

        // Verify textOverInactive color is not nil
        #expect(type(of: color) == Color.self)
    }

    @Test func `text over inactive color can be customized`() {
        var definition = ThemeDefinition()
        let customColor = ThemeColor(light: .black, dark: .white)
        definition.textOverInactive = customColor

        let lightColor = definition.textOverInactive.getColor(scheme: .light, contrast: nil)
        let darkColor = definition.textOverInactive.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == .black)
        #expect(darkColor == .white)
    }

    // MARK: - Multiple Properties Customization

    @Test func `multiple properties can be customized`() {
        var definition = ThemeDefinition()
        definition.primary = ThemeColor(light: .red, dark: .blue)
        definition.secondary = ThemeColor(light: .green, dark: .orange)
        definition.success = ThemeColor(light: .mint, dark: .teal)

        let primaryLight = definition.primary.getColor(scheme: .light, contrast: nil)
        let primaryDark = definition.primary.getColor(scheme: .dark, contrast: nil)
        let secondaryLight = definition.secondary.getColor(scheme: .light, contrast: nil)
        let secondaryDark = definition.secondary.getColor(scheme: .dark, contrast: nil)
        let successLight = definition.success.getColor(scheme: .light, contrast: nil)
        let successDark = definition.success.getColor(scheme: .dark, contrast: nil)

        #expect(primaryLight == .red)
        #expect(primaryDark == .blue)
        #expect(secondaryLight == .green)
        #expect(secondaryDark == .orange)
        #expect(successLight == .mint)
        #expect(successDark == .teal)
    }

    @Test func `all properties independently customizable`() {
        var definition = ThemeDefinition()

        // Customize all properties
        definition.primary = ThemeColor(light: .red)
        definition.textOverPrimary = ThemeColor(light: .white)
        definition.secondary = ThemeColor(light: .blue)
        definition.textOverSecondary = ThemeColor(light: .black)
        definition.background1 = ThemeColor(light: .gray)
        definition.background2 = ThemeColor(light: .gray)
        definition.background3 = ThemeColor(light: .gray)
        definition.text1 = ThemeColor(light: .black)
        definition.text2 = ThemeColor(light: .gray)
        definition.text3 = ThemeColor(light: .gray)
        definition.textField = ThemeColor(light: .white)
        definition.textFieldEdit = ThemeColor(light: .blue)
        definition.textFieldPlaceholder = ThemeColor(light: .gray)
        definition.success = ThemeColor(light: .green)
        definition.textOverSuccess = ThemeColor(light: .white)
        definition.inProgress = ThemeColor(light: .orange)
        definition.textOverInProgress = ThemeColor(light: .black)
        definition.warning = ThemeColor(light: .yellow)
        definition.textOverWarning = ThemeColor(light: .black)
        definition.error = ThemeColor(light: .red)
        definition.textOverError = ThemeColor(light: .white)
        definition.info = ThemeColor(light: .blue)
        definition.textOverInfo = ThemeColor(light: .white)
        definition.inactive = ThemeColor(light: .gray)
        definition.textOverInactive = ThemeColor(light: .black)

        // Verify all were customized
        #expect(definition.primary.getColor(scheme: .light, contrast: nil) == .red)
        #expect(definition.textOverPrimary.getColor(scheme: .light, contrast: nil) == .white)
        #expect(definition.secondary.getColor(scheme: .light, contrast: nil) == .blue)
        #expect(definition.textOverSecondary.getColor(scheme: .light, contrast: nil) == .black)
        #expect(definition.background1.getColor(scheme: .light, contrast: nil) == .gray)
        #expect(definition.background2.getColor(scheme: .light, contrast: nil) == .gray)
        #expect(definition.background3.getColor(scheme: .light, contrast: nil) == .gray)
        #expect(definition.text1.getColor(scheme: .light, contrast: nil) == .black)
        #expect(definition.text2.getColor(scheme: .light, contrast: nil) == .gray)
        #expect(definition.text3.getColor(scheme: .light, contrast: nil) == .gray)
        #expect(definition.textField.getColor(scheme: .light, contrast: nil) == .white)
        #expect(definition.textFieldEdit.getColor(scheme: .light, contrast: nil) == .blue)
        #expect(definition.textFieldPlaceholder.getColor(scheme: .light, contrast: nil) == .gray)
        #expect(definition.success.getColor(scheme: .light, contrast: nil) == .green)
        #expect(definition.textOverSuccess.getColor(scheme: .light, contrast: nil) == .white)
        #expect(definition.inProgress.getColor(scheme: .light, contrast: nil) == .orange)
        #expect(definition.textOverInProgress.getColor(scheme: .light, contrast: nil) == .black)
        #expect(definition.warning.getColor(scheme: .light, contrast: nil) == .yellow)
        #expect(definition.textOverWarning.getColor(scheme: .light, contrast: nil) == .black)
        #expect(definition.error.getColor(scheme: .light, contrast: nil) == .red)
        #expect(definition.textOverError.getColor(scheme: .light, contrast: nil) == .white)
        #expect(definition.info.getColor(scheme: .light, contrast: nil) == .blue)
        #expect(definition.textOverInfo.getColor(scheme: .light, contrast: nil) == .white)
        #expect(definition.inactive.getColor(scheme: .light, contrast: nil) == .gray)
        #expect(definition.textOverInactive.getColor(scheme: .light, contrast: nil) == .black)
    }

    // MARK: - Struct Mutability

    @Test func `struct is mutable`() {
        var definition = ThemeDefinition()
        definition.primary = ThemeColor(light: .red)

        // Verify we can mutate the struct
        #expect(definition.primary.getColor(scheme: .light, contrast: nil) == .red)

        // Mutate again
        definition.primary = ThemeColor(light: .blue)
        #expect(definition.primary.getColor(scheme: .light, contrast: nil) == .blue)
    }

    @Test func `struct can be reassigned`() {
        var definition = ThemeDefinition()
        definition.primary = ThemeColor(light: .red)

        // Create a new definition
        definition = ThemeDefinition()

        // Verify primary is back to default
        let defaultDefinition = ThemeDefinition()
        let actualColor = definition.primary.getColor(scheme: .light, contrast: nil)
        let expectedColor = defaultDefinition.primary.getColor(scheme: .light, contrast: nil)

        #expect(actualColor == expectedColor)
    }
}

#endif
