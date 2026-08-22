#if os(iOS) || targetEnvironment(macCatalyst)
@testable import CalderTheme
import SnapshotTesting
import Testing

@Suite(.serialized, .snapshots(record: .missing, diffTool: .ksdiff))
@MainActor struct PreviewSnapshotTests {
    @Test func `adaptative stack previews`() {
        assertSnapshots(
            of: AdaptativeStackPreviews.self,
            configurations: PreviewSnapshotConfigurations.compact + PreviewSnapshotConfigurations.regular,
            imageOptions: PreviewSnapshotConfigurations.imageOptions
        )
    }

    @Test func `wrapping hstack previews`() {
        assertSnapshots(of: WrappingHStackLayoutPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `form button previews`() {
        assertSnapshots(of: FormButtonPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `form date picker previews`() {
        assertSnapshots(of: FormDatePickerPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `form field previews`() {
        assertSnapshots(of: FormFieldPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `responsive form field previews`() {
        assertSnapshots(
            of: FormFieldResponsivePreviews.self,
            configurations: PreviewSnapshotConfigurations.compact + PreviewSnapshotConfigurations.regular,
            imageOptions: PreviewSnapshotConfigurations.imageOptions
        )
    }

    @Test func `form header previews`() {
        assertSnapshots(of: FormHeaderPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `form switch previews`() {
        assertSnapshots(of: FormSwitchPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `header previews`() {
        assertSnapshots(of: HeaderPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `tile previews`() {
        assertSnapshots(of: TilePreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `tiles previews`() {
        assertSnapshots(of: TilesPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `list row previews`() {
        assertSnapshots(of: ListRowPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `continuous paginated list previews`() {
        assertSnapshots(of: PaginatedListContinuousPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `grouped paginated list previews`() {
        assertSnapshots(of: PaginatedListGroupedPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `paginated selection previews`() {
        assertSnapshots(of: PaginatedListSelectionPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `paginated selection indicator previews`() {
        assertSnapshots(of: PaginatedListSelectionIndicatorPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `paginated selection item previews`() {
        assertSnapshots(of: PaginatedListSelectionItemPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `toolbar button previews`() {
        assertSnapshots(of: ToolbarButtonPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `toolbar menu previews`() {
        assertSnapshots(of: ToolbarMenuPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `toolbar title previews`() {
        assertSnapshots(of: ToolbarTitlePreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `themed button style previews`() {
        assertSnapshots(of: ThemedButtonStylePreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `barcode generator previews`() {
        assertSnapshots(of: BarcodeGeneratorViewPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `cardify previews`() {
        assertSnapshots(of: CardifyPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `horizontal bar chart previews`() {
        assertSnapshots(of: HorizontalBarChartPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `lane chart previews`() {
        assertSnapshots(of: LaneChartPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `line chart previews`() {
        assertSnapshots(of: LineChartPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `pareto chart previews`() {
        assertSnapshots(of: ParetoChartPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `vertical bar chart previews`() {
        assertSnapshots(of: VerticalBarChartPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `percent bar previews`() {
        assertSnapshots(of: PercentBarPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `percent view previews`() {
        assertSnapshots(of: PercentViewPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `percentage circle previews`() {
        assertSnapshots(of: PercentageCirclePreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `framed icon previews`() {
        assertSnapshots(of: FramedIconPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `attributed text view previews`() {
        if #available(iOS 26, macCatalyst 26, *) {
            assertSnapshots(of: AttributedTextViewPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
        }
    }

    @Test func `decimal input previews`() {
        assertSnapshots(of: InputDecimalPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `number input previews`() {
        assertSnapshots(of: InputNumberPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `password input previews`() {
        assertSnapshots(of: InputPasswordPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `text input previews`() {
        assertSnapshots(of: InputTextPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `text view previews`() {
        assertSnapshots(of: TextViewPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `message box previews`() {
        assertSnapshots(of: MessageBoxPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `markdown view previews`() {
        assertSnapshots(of: MarkdownViewPreviews.self, configurations: PreviewSnapshotConfigurations.regular, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `segmented control previews`() {
        assertSnapshots(of: SegmentedControlPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `generic state view previews`() {
        assertSnapshots(of: GenericStateViewPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `status pill previews`() {
        assertSnapshots(of: StatusPillPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `themed disclosure group previews`() {
        assertSnapshots(of: ThemedDisclosureGroupStylePreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `checkbox group previews`() {
        assertSnapshots(of: CheckboxGroupPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `radio button group previews`() {
        assertSnapshots(of: RadioButtonGroupPreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `checkbox toggle style previews`() {
        assertSnapshots(of: CheckboxToggleButtonStylePreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `radio button toggle style previews`() {
        assertSnapshots(of: RadioButtonToggleButtonStylePreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }

    @Test func `themed toggle style previews`() {
        assertSnapshots(of: ThemedToggleButtonStylePreviews.self, configurations: PreviewSnapshotConfigurations.compact, imageOptions: PreviewSnapshotConfigurations.imageOptions)
    }
}
#endif
