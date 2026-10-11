#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    import CalderSwiftUI
    @testable import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    struct ThemeDefinitionTests {

        // MARK: - Default Colors

        /// A default color derived from a hex value, whose dark variant blends toward white or black.
        private struct DerivedDefault {
            let name: String
            let color: ThemeColor
            let red: Int
            let green: Int
            let blue: Int
            let darkVariant: DarkVariant
            let ratio: Float
        }

        /// Whether a default's dark variant blends toward white or black.
        private enum DarkVariant {
            case lighter
            case darker

            var target: Float {
                switch self {
                    case .lighter:
                        1
                    case .darker:
                        0
                }
            }
        }

        @MainActor
        @Test func `default brand and status colors use the documented hex values`() {
            let definition = ThemeDefinition()
            let defaults = [
                DerivedDefault(name: "primary", color: definition.primary, red: 0x06, green: 0x6C, blue: 0xDB, darkVariant: .lighter, ratio: 0.1),
                DerivedDefault(name: "secondary", color: definition.secondary, red: 0x61, green: 0x5A, blue: 0xE4, darkVariant: .lighter, ratio: 0.1),
                DerivedDefault(name: "success", color: definition.success, red: 0x4E, green: 0x9A, blue: 0x53, darkVariant: .lighter, ratio: 0.1),
                DerivedDefault(name: "inProgress", color: definition.inProgress, red: 0xF2, green: 0x99, blue: 0x4A, darkVariant: .lighter, ratio: 0.1),
                DerivedDefault(name: "warning", color: definition.warning, red: 0xF2, green: 0xC9, blue: 0x4C, darkVariant: .lighter, ratio: 0.1),
                DerivedDefault(name: "error", color: definition.error, red: 0xEB, green: 0x57, blue: 0x57, darkVariant: .darker, ratio: 0.1),
                DerivedDefault(name: "info", color: definition.info, red: 0x06, green: 0x6C, blue: 0xDB, darkVariant: .lighter, ratio: 0.15)
            ]

            for entry in defaults {
                let light = Self.resolve(entry.color.getColor(scheme: .light))
                let dark = Self.resolve(entry.color.getColor(scheme: .dark))
                let expectedLight = [entry.red, entry.green, entry.blue].map { Float($0) / 255 }
                let expectedDark = expectedLight.map { $0 + (entry.darkVariant.target - $0) * entry.ratio }

                #expect(Self.isClose([light.red, light.green, light.blue], to: expectedLight), "\(entry.name) light is \(light)")
                #expect(Self.isClose([dark.red, dark.green, dark.blue], to: expectedDark), "\(entry.name) dark is \(dark)")
            }
        }

        @Test func `default text over colors contrast with their backgrounds`() {
            let definition = ThemeDefinition()
            let defaults: [(name: String, color: ThemeColor, expected: Color)] = [
                ("textOverPrimary", definition.textOverPrimary, .white),
                ("textOverSecondary", definition.textOverSecondary, .white),
                ("textOverSuccess", definition.textOverSuccess, .white),
                ("textOverInProgress", definition.textOverInProgress, .black),
                ("textOverWarning", definition.textOverWarning, .black),
                ("textOverError", definition.textOverError, .white),
                ("textOverInfo", definition.textOverInfo, .white)
            ]

            for (name, color, expected) in defaults {
                #expect(color.getColor(scheme: .light) == expected, "\(name) light")
                #expect(color.getColor(scheme: .dark) == expected, "\(name) dark")
            }
        }

        @MainActor @Test func `default surface and text colors use system colors`() {
            let definition = ThemeDefinition()
            let defaults: [(name: String, color: ThemeColor, expected: Color)] = [
                ("background1", definition.background1, .systemBackground),
                ("background2", definition.background2, .secondarySystemBackground),
                ("background3", definition.background3, .tertiarySystemBackground),
                ("text1", definition.text1, .label),
                ("text2", definition.text2, .secondaryLabel),
                ("text3", definition.text3, .tertiaryLabel),
                ("textField", definition.textField, .tertiarySystemBackground),
                ("textFieldEdit", definition.textFieldEdit, .primary),
                ("textFieldPlaceholder", definition.textFieldPlaceholder, .placeholderText),
                ("inactive", definition.inactive, .systemGroupedBackground),
                ("textOverInactive", definition.textOverInactive, .secondaryLabel)
            ]

            // Compare resolved values: adaptive system colors can be distinct instances that render identically.
            for (name, color, expected) in defaults {
                for scheme in [ColorScheme.light, .dark] {
                    var environment = EnvironmentValues()
                    environment.colorScheme = scheme
                    #expect(color.getColor(scheme: scheme).resolve(in: environment) == expected.resolve(in: environment), "\(name) \(scheme)")
                }
            }
        }

        // MARK: - Primary Colors

        @Test func `primary color can be customized`() {
            var definition = ThemeDefinition()
            let customColor = ThemeColor(light: .red, dark: .blue)
            definition.primary = customColor

            let lightColor = definition.primary.getColor(scheme: .light, contrast: nil)
            let darkColor = definition.primary.getColor(scheme: .dark, contrast: nil)

            #expect(lightColor == .red)
            #expect(darkColor == .blue)
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

        @Test func `secondary color can be customized`() {
            var definition = ThemeDefinition()
            let customColor = ThemeColor(light: .green, dark: .orange)
            definition.secondary = customColor

            let lightColor = definition.secondary.getColor(scheme: .light, contrast: nil)
            let darkColor = definition.secondary.getColor(scheme: .dark, contrast: nil)

            #expect(lightColor == .green)
            #expect(darkColor == .orange)
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

        @Test func `background 1 color can be customized`() {
            var definition = ThemeDefinition()
            let customColor = ThemeColor(light: .white, dark: .black)
            definition.background1 = customColor

            let lightColor = definition.background1.getColor(scheme: .light, contrast: nil)
            let darkColor = definition.background1.getColor(scheme: .dark, contrast: nil)

            #expect(lightColor == .white)
            #expect(darkColor == .black)
        }

        @Test func `background 2 color can be customized`() {
            var definition = ThemeDefinition()
            let customColor = ThemeColor(light: .gray, dark: .gray)
            definition.background2 = customColor

            let color = definition.background2.getColor(scheme: .light, contrast: nil)
            #expect(color == .gray)
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

        @Test func `text 1 color can be customized`() {
            var definition = ThemeDefinition()
            let customColor = ThemeColor(light: .black, dark: .white)
            definition.text1 = customColor

            let lightColor = definition.text1.getColor(scheme: .light, contrast: nil)
            let darkColor = definition.text1.getColor(scheme: .dark, contrast: nil)

            #expect(lightColor == .black)
            #expect(darkColor == .white)
        }

        @Test func `text 2 color can be customized`() {
            var definition = ThemeDefinition()
            let customColor = ThemeColor(light: .gray, dark: .gray)
            definition.text2 = customColor

            let color = definition.text2.getColor(scheme: .light, contrast: nil)
            #expect(color == .gray)
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

        @Test func `text field color can be customized`() {
            var definition = ThemeDefinition()
            let customColor = ThemeColor(light: .white, dark: .black)
            definition.textField = customColor

            let lightColor = definition.textField.getColor(scheme: .light, contrast: nil)
            let darkColor = definition.textField.getColor(scheme: .dark, contrast: nil)

            #expect(lightColor == .white)
            #expect(darkColor == .black)
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

        @Test func `text field placeholder color can be customized`() {
            var definition = ThemeDefinition()
            let customColor = ThemeColor(light: .gray, dark: .gray)
            definition.textFieldPlaceholder = customColor

            let color = definition.textFieldPlaceholder.getColor(scheme: .light, contrast: nil)
            #expect(color == .gray)
        }

        // MARK: - Status Colors: Success

        @Test func `success color can be customized`() {
            var definition = ThemeDefinition()
            let customColor = ThemeColor(light: .green, dark: .mint)
            definition.success = customColor

            let lightColor = definition.success.getColor(scheme: .light, contrast: nil)
            let darkColor = definition.success.getColor(scheme: .dark, contrast: nil)

            #expect(lightColor == .green)
            #expect(darkColor == .mint)
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

        @Test func `in progress color can be customized`() {
            var definition = ThemeDefinition()
            let customColor = ThemeColor(light: .orange, dark: .yellow)
            definition.inProgress = customColor

            let lightColor = definition.inProgress.getColor(scheme: .light, contrast: nil)
            let darkColor = definition.inProgress.getColor(scheme: .dark, contrast: nil)

            #expect(lightColor == .orange)
            #expect(darkColor == .yellow)
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

        @Test func `warning color can be customized`() {
            var definition = ThemeDefinition()
            let customColor = ThemeColor(light: .yellow, dark: .orange)
            definition.warning = customColor

            let lightColor = definition.warning.getColor(scheme: .light, contrast: nil)
            let darkColor = definition.warning.getColor(scheme: .dark, contrast: nil)

            #expect(lightColor == .yellow)
            #expect(darkColor == .orange)
        }

        @Test func `text over warning color can be customized`() {
            var definition = ThemeDefinition()
            let customColor = ThemeColor(light: .black, dark: .black)
            definition.textOverWarning = customColor

            let color = definition.textOverWarning.getColor(scheme: .light, contrast: nil)
            #expect(color == .black)
        }

        // MARK: - Status Colors: Error

        @Test func `error color can be customized`() {
            var definition = ThemeDefinition()
            let customColor = ThemeColor(light: .red, dark: .pink)
            definition.error = customColor

            let lightColor = definition.error.getColor(scheme: .light, contrast: nil)
            let darkColor = definition.error.getColor(scheme: .dark, contrast: nil)

            #expect(lightColor == .red)
            #expect(darkColor == .pink)
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

        @Test func `info color can be customized`() {
            var definition = ThemeDefinition()
            let customColor = ThemeColor(light: .blue, dark: .cyan)
            definition.info = customColor

            let lightColor = definition.info.getColor(scheme: .light, contrast: nil)
            let darkColor = definition.info.getColor(scheme: .dark, contrast: nil)

            #expect(lightColor == .blue)
            #expect(darkColor == .cyan)
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

        @Test func `inactive color can be customized`() {
            var definition = ThemeDefinition()
            let customColor = ThemeColor(light: .gray, dark: .gray)
            definition.inactive = customColor

            let color = definition.inactive.getColor(scheme: .light, contrast: nil)
            #expect(color == .gray)
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

        // MARK: - Helpers

        @MainActor
        private static func resolve(_ color: Color) -> Color.Resolved {
            color.resolve(in: EnvironmentValues())
        }

        private static func isClose(_ components: [Float], to expected: [Float]) -> Bool {
            zip(components, expected).allSatisfy { abs($0 - $1) < 0.005 }
        }
    }

#endif
