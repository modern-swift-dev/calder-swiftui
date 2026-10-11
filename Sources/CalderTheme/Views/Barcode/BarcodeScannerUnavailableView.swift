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
                VStack(spacing: .medium) {
                    switch reason {
                        case .permissionDenied:
                            MessageBox(
                                variant: .warn,
                                icon: Image(systemSymbol: .videoSlashFill),
                                title: "Camera access is off",
                                message: "Allow camera access in Settings to scan codes."
                            )
                            Button(action: openSettings) {
                                Text(verbatim: "Open Settings")
                            }
                            .buttonStyle(ThemedButtonStyle())
                        case .unsupported:
                            MessageBox(
                                variant: .info,
                                icon: Image(systemSymbol: .cameraFill),
                                title: "Scanning unavailable",
                                message: "This device cannot scan codes with its camera."
                            )
                    }
                }
                .padding(.medium)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(theme.background1)
            }
        }
    #endif
#endif
