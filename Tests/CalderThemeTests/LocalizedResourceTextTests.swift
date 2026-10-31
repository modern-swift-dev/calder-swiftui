#if canImport(SwiftUI)
    @testable import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    /// Checks that components expose their text as a `LocalizedStringResource`, which resolves in a chosen locale
    /// instead of the process locale that the deprecated `String` properties use.
    @Suite(.serialized)
    @MainActor struct LocalizedResourceTextTests {
        /// A bundle with a string for English and one for German, so the locale a resource resolves in is observable.
        private final class GreetingBundle {
            let url: URL

            init() throws {
                url = FileManager.default.temporaryDirectory.appendingPathComponent("greeting-\(UUID().uuidString).bundle")
                for (language, value) in [("en", "Hello"), ("de", "Hallo")] {
                    let directory = url.appendingPathComponent("\(language).lproj")
                    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                    try "\"greeting\" = \"\(value)\";".write(to: directory.appendingPathComponent("Localizable.strings"), atomically: true, encoding: .utf8)
                }
                try """
                <?xml version="1.0" encoding="UTF-8"?>
                <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
                <plist version="1.0"><dict>
                <key>CFBundleIdentifier</key><string>test.greeting</string>
                <key>CFBundleDevelopmentRegion</key><string>en</string>
                </dict></plist>
                """.write(to: url.appendingPathComponent("Info.plist"), atomically: true, encoding: .utf8)
            }

            deinit { try? FileManager.default.removeItem(at: url) }

            var resource: LocalizedStringResource {
                LocalizedStringResource("greeting", bundle: .atURL(url))
            }
        }

        private let german = Locale(identifier: "de")
        private let english = Locale(identifier: "en")

        private func resolved(_ resource: LocalizedStringResource, in locale: Locale) -> String {
            var resource = resource
            resource.locale = locale
            return String(localized: resource)
        }

        @Test func `a resource resolves in the locale it is given`() throws {
            let greeting = try GreetingBundle()

            #expect(resolved(greeting.resource, in: german) == "Hallo")
            #expect(resolved(greeting.resource, in: english) == "Hello")
        }

        @Test func `form components expose resources`() throws {
            let greeting = try GreetingBundle()

            #expect(resolved(FormButton(text: greeting.resource) {}.textResource, in: german) == "Hallo")
            #expect(resolved(FormHeader(title: greeting.resource).titleResource, in: german) == "Hallo")
            #expect(resolved(FormField(name: greeting.resource) { EmptyView() }.nameResource, in: german) == "Hallo")
            #expect(resolved(FormFieldResponsive(name: greeting.resource) { _ in EmptyView() }.nameResource, in: german) == "Hallo")
            #expect(resolved(FormSwitch(name: greeting.resource, value: .constant(true)).nameResource, in: german) == "Hallo")
            #if !os(tvOS)
                #expect(resolved(FormDatePicker(name: greeting.resource, value: .constant(Date())).nameResource, in: german) == "Hallo")
            #endif
        }

        @Test func `string components expose their text verbatim`() {
            let text = "100% %@ \\(x)"

            #expect(resolved(FormButton(text: text) {}.textResource, in: german) == text)
            #expect(resolved(FormHeader(title: text).titleResource, in: german) == text)
            #expect(resolved(MessageBox(variant: .info, title: text, message: text).titleResource, in: german) == text)
            #expect(resolved(MessageBox(variant: .info, title: text, message: text).messageResource, in: german) == text)
            #expect(resolved(StatusPill(text: text, variant: .info).textResource, in: german) == text)
        }

        @Test func `display components expose resources`() throws {
            let greeting = try GreetingBundle()

            let box = MessageBox(variant: .info, title: greeting.resource, message: greeting.resource)
            #expect(resolved(box.titleResource, in: german) == "Hallo")
            #expect(resolved(box.messageResource, in: german) == "Hallo")
            #expect(resolved(StatusPill(text: greeting.resource, variant: .info).textResource, in: german) == "Hallo")
            #expect(resolved(SegmentedControl.Item(id: 1, title: greeting.resource).titleResource, in: german) == "Hallo")
            #expect(resolved(SegmentedControl.Item(id: 1, title: "Plain").titleResource, in: german) == "Plain")
        }

        @Test func `input components expose resources`() throws {
            let greeting = try GreetingBundle()

            let text = InputText(text: .constant(""), placeholder: greeting.resource, invalidMessage: greeting.resource)
            #expect(resolved(text.placeholderResource, in: german) == "Hallo")
            #expect(try resolved(#require(text.invalidMessageResource), in: german) == "Hallo")
            #expect(InputText(text: .constant(""), placeholder: greeting.resource).invalidMessageResource == nil)

            let password = InputPassword(text: .constant(""), placeholder: greeting.resource, invalidMessage: greeting.resource)
            #expect(resolved(password.placeholderResource, in: german) == "Hallo")
            #expect(try resolved(#require(password.invalidMessageResource), in: german) == "Hallo")
        }

        #if !os(watchOS)
            @Test func `toolbar title exposes a resource`() throws {
                let greeting = try GreetingBundle()

                #expect(resolved(ToolbarTitle(title: greeting.resource).titleResource, in: german) == "Hallo")
            }
        #endif

        @Test func `assigning an invalid message resource replaces it`() throws {
            let greeting = try GreetingBundle()
            var text = InputText(text: .constant(""), placeholder: "Name", invalidMessage: "Old")

            text.invalidMessageResource = greeting.resource
            #expect(try resolved(#require(text.invalidMessageResource), in: german) == "Hallo")

            text.invalidMessageResource = nil
            #expect(text.invalidMessageResource == nil)
        }

        @Test func `list row body exposes resources`() throws {
            let greeting = try GreetingBundle()

            let body = ListRowBody(title: greeting.resource, subtitle: greeting.resource, caption: greeting.resource)
            #expect(resolved(body.titleResource, in: german) == "Hallo")
            #expect(try resolved(#require(body.subtitleResource), in: german) == "Hallo")
            #expect(try resolved(#require(body.captionResource), in: german) == "Hallo")
            #expect(ListRowBody(title: "Plain").subtitleResource == nil)
            #expect(ListRowBody(title: "Plain").captionResource == nil)
            #expect(resolved(ListRowBody(title: "Plain").titleResource, in: german) == "Plain")
        }

        @Test func `selection items expose resources`() throws {
            let greeting = try GreetingBundle()

            #expect(resolved(CheckboxGroup.Item(id: 1, text: greeting.resource).textResource, in: german) == "Hallo")
            #expect(resolved(RadioButtonGroup.Item(id: 1, text: greeting.resource).textResource, in: german) == "Hallo")
            #expect(resolved(CheckboxGroup.Item(id: 1, text: "Plain").textResource, in: german) == "Plain")
            #expect(resolved(RadioButtonGroup.Item(id: 1, text: "Plain").textResource, in: german) == "Plain")
        }

        @Test func `assigning a selection item resource replaces it`() throws {
            let greeting = try GreetingBundle()
            var checkbox = CheckboxGroup.Item(id: 1, text: "Old")
            var radio = RadioButtonGroup.Item(id: 1, text: "Old")

            checkbox.textResource = greeting.resource
            radio.textResource = greeting.resource

            #expect(resolved(checkbox.textResource, in: german) == "Hallo")
            #expect(resolved(radio.textResource, in: german) == "Hallo")
        }

        @Test func `percent bar exposes its suffix as a resource`() throws {
            let greeting = try GreetingBundle()

            #expect(try resolved(#require(PercentBar(value: 1, total: 2, text: greeting.resource).textResource), in: german) == "Hallo")
            #expect(try resolved(#require(PercentBar(value: 1, total: 2, text: "Plain").textResource), in: german) == "Plain")
            #expect(PercentBar(value: 1, total: 2).textResource == nil)
        }

        @Test func `charts expose label resources`() throws {
            let greeting = try GreetingBundle()
            let g = greeting.resource

            let line = LineChart(title: g, xAxisLabel: g, leftYAxisTitle: g, points: [])
            let vertical = VerticalBarChart(title: g, xAxisLabel: g, leftYAxisTitle: g, points: [])
            let horizontal = HorizontalBarChart(xAxisLabel: g, leftYAxisTitle: g, points: [])
            let pareto = ParetoChart(title: g, xAxisLabel: g, leftYAxisTitle: g, rightYAxisTitle: g, points: [])
            let resources = [
                line.titleResource, line.xAxisLabelResource, line.yAxisTitleResource,
                vertical.titleResource, vertical.xAxisLabelResource, vertical.yAxisTitleResource,
                horizontal.xAxisLabelResource, horizontal.yAxisTitleResource,
                pareto.titleResource, pareto.xAxisLabelResource, pareto.leftYAxisTitleResource, pareto.rightYAxisTitleResource
            ]

            #expect(resources.map { resolved($0, in: german) } == Array(repeating: "Hallo", count: resources.count))
        }

        @Test func `string charts expose their labels verbatim`() {
            let chart = LineChart(title: "100% %@", xAxisLabel: "X", leftYAxisTitle: "Y", points: [])

            #expect(resolved(chart.titleResource, in: german) == "100% %@")
            #expect(resolved(chart.xAxisLabelResource, in: german) == "X")
        }

        @Test func `assigning a chart label resource replaces it`() throws {
            let greeting = try GreetingBundle()
            var chart = LineChart(title: "Old", xAxisLabel: "Old", leftYAxisTitle: "Old", points: [])

            chart.titleResource = greeting.resource
            chart.xAxisLabelResource = greeting.resource
            chart.yAxisTitleResource = greeting.resource

            #expect(resolved(chart.titleResource, in: german) == "Hallo")
            #expect(resolved(chart.xAxisLabelResource, in: german) == "Hallo")
            #expect(resolved(chart.yAxisTitleResource, in: german) == "Hallo")
        }

        @available(*, deprecated, message: "Covers the deprecated String properties.")
        @Test func `deprecated string properties still resolve`() {
            #expect(FormButton(text: "Plain") {}.text == "Plain")
            #expect(FormHeader(title: "Plain").title == "Plain")
            #expect(MessageBox(variant: .info, title: "Plain", message: "Body").message == "Body")
            #expect(ListRowBody(title: "Plain", subtitle: "Sub", caption: "Cap").title == "Plain")
            #expect(ListRowBody(title: "Plain", subtitle: "Sub", caption: "Cap").subtitle == "Sub")
            #expect(ListRowBody(title: "Plain", subtitle: "Sub", caption: "Cap").caption == "Cap")
            #expect(CheckboxGroup.Item(id: 1, text: "Plain").text == "Plain")
            #expect(RadioButtonGroup.Item(id: 1, text: "Plain").text == "Plain")
            #expect(PercentBar(value: 1, total: 2, text: "Plain").text == "Plain")
            #expect(LineChart(title: "T", xAxisLabel: "X", leftYAxisTitle: "Y", points: []).title == "T")
        }
    }
#endif
