#if canImport(SwiftUI)
import CalderSwiftUI
import Foundation
import SFSafeSymbols
import SwiftUI

public extension ColorScheme {

    var inverted: ColorScheme {
        switch self {
            case .light:
                return .dark
            case .dark:
                return .light
            @unknown default:
                return .light
        }
    }
}

/// A struct representing a themed appearance, encapsulating colors and fonts
/// based on a given `ThemeDefinition`, `ColorScheme`, and `ColorSchemeContrast`.
public struct Theme {

    // MARK: - Properties

    /// The theme definition that contains color and font specifications.
    public let definition: ThemeDefinition

    /// The current color scheme, either light or dark.
    public let scheme: ColorScheme

    /// The current contrast setting, standard or increased.
    public let contrast: ColorSchemeContrast

    /// The dynamic content size for the font
    private let dynamicTypeSize: DynamicTypeSize

    // MARK: - Initializer

    /// Initializes a `Theme` instance with a given theme definition, color scheme, and contrast setting.
    /// - Parameters:
    ///   - definition: The `ThemeDefinition` containing color and font styles.
    ///   - scheme: The color scheme, typically `.light` or `.dark`.
    ///   - contrast: The contrast setting, supporting accessibility needs.
    public init(definition: ThemeDefinition, scheme: ColorScheme, contrast: ColorSchemeContrast, dynamicTypeSize: DynamicTypeSize) {
        self.definition = definition
        self.scheme = scheme
        self.contrast = contrast
        self.dynamicTypeSize = dynamicTypeSize
    }

    // MARK: - Colors

    public var primary: Color {
        definition.primary.getColor(scheme: scheme, contrast: contrast)
    }

    public var textOverPrimary: Color {
        definition.textOverPrimary.getColor(scheme: scheme, contrast: contrast)
    }

    public var secondary: Color {
        definition.secondary.getColor(scheme: scheme, contrast: contrast)
    }

    public var textOverSecondary: Color {
        definition.textOverSecondary.getColor(scheme: scheme, contrast: contrast)
    }

    public var background1: Color {
        definition.background1.getColor(scheme: scheme, contrast: contrast)
    }

    public var background2: Color {
        definition.background2.getColor(scheme: scheme, contrast: contrast)
    }

    public var background3: Color {
        definition.background3.getColor(scheme: scheme, contrast: contrast)
    }

    public var text1: Color {
        definition.text1.getColor(scheme: scheme, contrast: contrast)
    }

    public var text2: Color {
        definition.text2.getColor(scheme: scheme, contrast: contrast)
    }

    public var text3: Color {
        definition.text3.getColor(scheme: scheme, contrast: contrast)
    }

    public var textField: Color {
        definition.textField.getColor(scheme: scheme, contrast: contrast)
    }

    public var textFieldEdit: Color {
        definition.textFieldEdit.getColor(scheme: scheme, contrast: contrast)
    }

    public var textFieldPlaceholder: Color {
        definition.textFieldPlaceholder.getColor(scheme: scheme, contrast: contrast)
    }

    public var success: Color {
        definition.success.getColor(scheme: scheme, contrast: contrast)
    }

    public var textOverSuccess: Color {
        definition.textOverSuccess.getColor(scheme: scheme, contrast: contrast)
    }

    public var inProgress: Color {
        definition.inProgress.getColor(scheme: scheme, contrast: contrast)
    }

    public var textOverInProgress: Color {
        definition.textOverInProgress.getColor(scheme: scheme, contrast: contrast)
    }

    public var warning: Color {
        definition.warning.getColor(scheme: scheme, contrast: contrast)
    }

    public var textOverWarning: Color {
        definition.textOverWarning.getColor(scheme: scheme, contrast: contrast)
    }

    public var error: Color {
        definition.error.getColor(scheme: scheme, contrast: contrast)
    }

    public var textOverError: Color {
        definition.textOverError.getColor(scheme: scheme, contrast: contrast)
    }

    public var info: Color {
        definition.info.getColor(scheme: scheme, contrast: contrast)
    }

    public var textOverInfo: Color {
        definition.textOverInfo.getColor(scheme: scheme, contrast: contrast)
    }

    public var inactive: Color {
        definition.inactive.getColor(scheme: scheme, contrast: contrast)
    }

    public var textOverInactive: Color {
        definition.textOverInactive.getColor(scheme: scheme, contrast: contrast)
    }

    public var transparent: Color {
        .clear
    }

    public var backgroundGradient: LinearGradient {
        if scheme == .light {
            .init(colors: [
                self.primary.lighten(amount: 0.65),
                self.primary.lighten(amount: 0.9)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            .init(colors: [
                self.primary.darken(amount: 0.65),
                self.primary.darken(amount: 0.9)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    public var titleGradient: LinearGradient {
        .init(colors: [
            self.primary,
            self.secondary
        ], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// The border color for the current scheme and contrast.
    public var border: Color {
        definition.border.getColor(scheme: scheme, contrast: contrast)
    }

    /// The shadow color for the current scheme and contrast.
    public var shadow: Color {
        definition.shadow.getColor(scheme: scheme, contrast: contrast)
    }
}

// MARK: - Environment Integration

/// Environment key for defining a custom theme definition.
private struct ThemeDefinitionEnv: EnvironmentKey {
    /// The value type stored in the environment.
    typealias Value = ThemeDefinition

    /// The default value for the theme definition.
    static var defaultValue: ThemeDefinition {
        .init()
    }
}

/// Extends `EnvironmentValues` to include `ThemeDefinition` and `Theme` as environment properties.
public extension EnvironmentValues {

    /// The current `ThemeDefinition` stored in the environment.
    var themeDefinition: ThemeDefinition {
        get { self[ThemeDefinitionEnv.self] }
        set { self[ThemeDefinitionEnv.self] = newValue }
    }

    /// The computed `Theme` object, based on the `themeDefinition`, current color scheme, and contrast settings.
    var theme: Theme {
        .init(definition: themeDefinition, scheme: colorScheme, contrast: colorSchemeContrast, dynamicTypeSize: dynamicTypeSize)
    }

    /// The computed `Theme` object, based on the `themeDefinition`, dark color scheme, and current contrast setting.
    var darkTheme: Theme {
        .init(definition: themeDefinition, scheme: .dark, contrast: colorSchemeContrast, dynamicTypeSize: dynamicTypeSize)
    }

    /// The computed `Theme` object, based on the `themeDefinition`, light color scheme, and current contrast setting.
    var lightTheme: Theme {
        .init(definition: themeDefinition, scheme: .light, contrast: colorSchemeContrast, dynamicTypeSize: dynamicTypeSize)
    }
}

#endif
