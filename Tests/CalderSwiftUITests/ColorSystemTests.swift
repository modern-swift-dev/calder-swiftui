#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    @testable import CalderSwiftUI
    import Foundation
    import SwiftUI
    import Testing

    struct ColorSystemTests {

        // MARK: - System Gray Colors

        #if os(macOS) || os(iOS)
            @MainActor
            @Test(arguments: [ColorScheme.light, .dark])
            func `system gray levels are distinct`(_ scheme: ColorScheme) {
                let grays: [Color] = [.systemGray, .systemGray2, .systemGray3, .systemGray4, .systemGray5, .systemGray6]
                let resolved = grays.map { resolve($0, in: scheme) }
                #expect(Set(resolved).count == grays.count)
            }

            @MainActor
            @Test(arguments: [Color.systemGray2, .systemGray3, .systemGray4, .systemGray5, .systemGray6])
            func `system gray levels follow the appearance`(_ gray: Color) {
                #expect(resolve(gray, in: .light) != resolve(gray, in: .dark))
            }

            @MainActor
            @Test(arguments: [ColorScheme.light, .dark])
            func `system gray is an opaque mid gray`(_ scheme: ColorScheme) {
                let gray = resolve(.systemGray, in: scheme)
                #expect(gray.opacity == 1)
                for channel in [gray.red, gray.green, gray.blue] {
                    #expect((0.4 ... 0.7).contains(channel))
                }
            }
        #endif

        // MARK: - Label Colors

        #if os(macOS) || os(iOS)
            @MainActor
            @Test(arguments: [ColorScheme.light, .dark])
            func `label levels lose emphasis in order`(_ scheme: ColorScheme) {
                let labels: [Color] = [.label, .secondaryLabel, .tertiaryLabel, .quaternaryLabel]
                let opacities = labels.map { resolve($0, in: scheme).opacity }
                #expect(zip(opacities, opacities.dropFirst()).allSatisfy { $0 > $1 })
            }

            @MainActor
            @Test func `label contrasts with the appearance`() {
                let light = resolve(.label, in: .light)
                let dark = resolve(.label, in: .dark)
                #expect(light.red < 0.5 && light.green < 0.5 && light.blue < 0.5)
                #expect(dark.red > 0.5 && dark.green > 0.5 && dark.blue > 0.5)
            }

            // MARK: - Interactive Colors

            @MainActor
            @Test(arguments: [ColorScheme.light, .dark])
            func `link is blue`(_ scheme: ColorScheme) {
                let link = resolve(.link, in: scheme)
                #expect(link.blue > link.red && link.blue > link.green)
            }

            @MainActor
            @Test(arguments: [Color.placeholderText, .separator], [ColorScheme.light, .dark])
            func `placeholder text and separator are translucent`(_ color: Color, _ scheme: ColorScheme) {
                #expect(resolve(color, in: scheme).opacity < 1)
            }
        #endif

        // MARK: - Separator Colors

        @MainActor
        @Test(arguments: [ColorScheme.light, .dark])
        func `opaque separator is opaque`(_ scheme: ColorScheme) {
            #expect(resolve(.opaqueSeparator, in: scheme).opacity == 1)
        }

        // MARK: - Static Text Colors

        #if os(macOS) || os(iOS) || os(tvOS)
            @MainActor
            @Test(arguments: [ColorScheme.light, .dark])
            func `dark text is opaque black in every appearance`(_ scheme: ColorScheme) {
                let text = resolve(.darkText, in: scheme)
                #expect([text.red, text.green, text.blue] == [0, 0, 0])
                #expect(text.opacity == 1)
            }

            @MainActor
            @Test(arguments: [ColorScheme.light, .dark])
            func `light text is white in every appearance`(_ scheme: ColorScheme) {
                let text = resolve(.lightText, in: scheme)
                #expect([text.red, text.green, text.blue].allSatisfy { abs($0 - 1) < 0.01 })
                #expect(text.opacity > 0)
            }
        #endif

        // MARK: - Appearance

        #if os(iOS) || os(tvOS) || os(macOS)
            @MainActor
            @Test(arguments: [
                Color.systemBackground, .secondarySystemBackground, .tertiarySystemBackground,
                .systemGroupedBackground, .secondarySystemGroupedBackground, .tertiarySystemGroupedBackground,
                .systemFill, .secondarySystemFill, .tertiarySystemFill, .quaternarySystemFill
            ])
            func `backgrounds and fills follow the appearance`(_ color: Color) {
                #expect(resolve(color, in: .light) != resolve(color, in: .dark))
            }
        #endif

        // MARK: - Helpers

        /// Resolves on the main actor because AppKit-backed colors resolve against `NSAppearance`.
        @MainActor
        private func resolve(_ color: Color, in scheme: ColorScheme) -> Color.Resolved {
            var environment = EnvironmentValues()
            environment.colorScheme = scheme
            return color.resolve(in: environment)
        }
    }

#endif
