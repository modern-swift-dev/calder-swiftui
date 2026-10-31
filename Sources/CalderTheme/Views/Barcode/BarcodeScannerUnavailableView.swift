#if canImport(SwiftUI)
    #if os(iOS)
        import CalderUIKit
        import SFSafeSymbols
        import SwiftUI

        /// The themed message a barcode scanner shows instead of the camera feed when it cannot scan.
        struct BarcodeScannerUnavailableView: View {
            /// Why the scanner cannot scan.
            enum Reason: Equatable {
                /// The user denied camera access, or access is restricted.
                case permissionDenied
                /// The device has no camera or scanner support that can scan codes.
                case unsupported
            }

            @Environment(\.theme) private var theme

            /// Why the scanner cannot scan.
            let reason: Reason

            /// Opens the app's page in the Settings app. Used only for ``Reason/permissionDenied``.
            var openSettings: () -> Void = {}

            var body: some View {
                VStack(spacing: .spacingMedium) {
                    switch reason {
                        case .permissionDenied:
                            MessageBox(
                                variant: .warn,
                                icon: Image(systemSymbol: .videoSlashFill),
                                title: LocalizedStringResource("barcodeScanner.permissionDenied.title", bundle: .module),
                                message: LocalizedStringResource("barcodeScanner.permissionDenied.message", bundle: .module)
                            )
                            Button(action: openSettings) {
                                Text(LocalizedStringResource("barcodeScanner.permissionDenied.openSettings", bundle: .module))
                            }
                            .buttonStyle(ThemedButtonStyle())
                        case .unsupported:
                            MessageBox(
                                variant: .info,
                                icon: Image(systemSymbol: .cameraFill),
                                title: LocalizedStringResource("barcodeScanner.unsupported.title", bundle: .module),
                                message: LocalizedStringResource("barcodeScanner.unsupported.message", bundle: .module)
                            )
                    }
                }
                .padding(.spacingMedium)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(theme.background1)
            }
        }
    #endif
#endif
