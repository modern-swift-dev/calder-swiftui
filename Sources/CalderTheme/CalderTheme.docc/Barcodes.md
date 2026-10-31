# Scanning and generating barcodes

Scan barcodes and QR codes with the camera, and display generated codes.

## Overview

CalderTheme provides three barcode views:

- `BarcodeScanner` scans codes with AVFoundation and reports each code through a binding. It wraps
  `BarcodeScannerViewController`. It's available on iOS.
- `BarcodeSelector` scans codes with VisionKit's `DataScannerViewController`, highlights the
  codes it recognizes, and reports the selected one. It wraps `BarcodeSelectorViewController`.
  It's available on iOS, excluding Mac Catalyst.
- ``BarcodeGeneratorView`` displays a QR, Code 128, or PDF417 code generated from a string. It's
  available on every platform except watchOS.

### Declare camera usage

Apps that show `BarcodeScanner` or `BarcodeSelector` must declare `NSCameraUsageDescription`
in their `Info.plist`; otherwise the system terminates the app on its first camera access.

```xml
<key>NSCameraUsageDescription</key>
<string>The camera scans barcodes and QR codes.</string>
```

### Scan codes

Pass a binding for the result and the scanner's state. The scanner pauses after it writes a
result; set the `result` binding back to `nil` to scan the next code without recreating the view.

```swift
import AVFoundation
import CalderTheme
import SwiftUI

struct TicketScanner: View {
    @State private var result: BarcodeScanner.ScanResult?

    var body: some View {
        VStack {
            BarcodeScanner(result: $result, state: .scanning, supportedTypes: [.qr, .ean13])

            if let result {
                Text(result.payload)
                Button("Scan another code") {
                    self.result = nil
                }
            }
        }
    }
}
```

`BarcodeScanner` applies changes to its `state` after creation: `.suspended` pauses detection,
`.scanning` resumes it (restarting the camera after `.finished`), and `.finished` stops the
camera.

### Turn on the torch

Pass a `torch` binding to turn the torch on or off while the camera runs. It's off by default.
A device without a torch ignores it, so check `BarcodeScannerViewController.isTorchAvailable`
to hide a torch button on devices that can't use it:

```swift
struct TicketScanner: View {
    @State private var result: BarcodeScanner.ScanResult?
    @State private var torch = false

    var body: some View {
        VStack {
            BarcodeScanner(result: $result, state: .scanning, torch: $torch)

            if BarcodeScannerViewController.isTorchAvailable {
                Toggle("Torch", isOn: $torch)
            }
        }
    }
}
```

With UIKit, set `BarcodeScannerView.Model.isTorchOn` when you create the scanner, or call
`BarcodeScannerViewController.isTorchOn` and `BarcodeScannerView.setTorch(_:)` while it runs.

### Zoom the camera

Pass a `zoomFactor` binding to zoom the camera. `1` is no zoom, which is the default, and the camera
clamps the factor to the range it supports. Pinching the preview changes the zoom and writes the new
factor to the binding:

```swift
@State private var zoom: CGFloat = 1

BarcodeScanner(result: $result, state: .scanning, zoomFactor: $zoom)
```

With UIKit, set `BarcodeScannerView.Model.zoomFactor` when you create the scanner, or use
`BarcodeScannerViewController.zoomFactor` and `onZoomFactorChange` while it runs.

To let people pick among the codes in view, use `BarcodeSelector` and choose the symbologies to
recognize:

```swift
import CalderTheme
import SwiftUI
import Vision
import VisionKit

struct ProductScanner: View {
    @State private var scannedCode: (String, VNBarcodeSymbology?)?

    var body: some View {
        BarcodeSelector(
            recognizedTypes: [.barcode(symbologies: [.ean13, .qr])],
            scannedCode: $scannedCode
        )
    }
}
```

### Handle camera permission and unsupported devices

`BarcodeScanner` and `BarcodeScannerViewController` ask for camera access when it is
undetermined. When access is denied or restricted, they show a message, themed with the
environment's `themeDefinition`, with a button that opens Settings, and they start scanning
when the app becomes active with access granted.

`BarcodeSelector` and `BarcodeSelectorViewController` don't prompt for camera access. When the
device supports scanning but `BarcodeSelectorViewController.isAvailable` is `false` as the view
loads, for example because access is denied, they show the same message with the Settings button
instead of a black screen.

On devices that cannot scan, such as Simulator, the scanner and selector show an unavailable
message instead of a blank view. Check `BarcodeScannerViewController.isSupported`,
`BarcodeSelectorViewController.isSupported`, and `BarcodeSelectorViewController.isAvailable` to
hide scanning entry points:

```swift
struct TicketsView: View {
    var body: some View {
        NavigationStack {
            List {
                if BarcodeScannerViewController.isSupported {
                    NavigationLink("Scan a ticket") {
                        TicketScanner()
                    }
                }
            }
        }
    }
}
```

### Generate codes

Create a ``BarcodeGeneratorView`` with the payload and a `BarcodeGenerator` type from
CalderUIKit:

```swift
import CalderTheme
import CalderUIKit
import SwiftUI

struct TicketCode: View {
    let ticketID: String

    var body: some View {
        BarcodeGeneratorView(code: ticketID, type: .qr)
            .frame(width: 200, height: 200)
    }
}
```

`BarcodeGeneratorView` generates its image off the main thread and keeps it across parent view
updates; it regenerates only when the code or barcode type changes. `BarcodeGeneratorView.Model`
is main-actor isolated. When the payload cannot be encoded, the view shows an error instead of a
progress indicator. QR codes encode payloads as UTF-8, while Code 128 and PDF417 codes require
ASCII payloads.

### Use the UIKit scanner

`BarcodeScannerViewController.onCodeScanned(_:type:rect:path:)` is main-actor isolated and
suspends detection before reporting the code, so only one code is delivered per scan even when
several are in frame. The scan region shows its active tint while codes are detected and
returns to its inactive tint shortly after detection stops.

The scanner configures, starts, and stops its capture session on one serial session queue, so
`BarcodeScannerViewController.start()` and `stop()` return without blocking the main thread and
a stop always runs after an earlier start. `BarcodeScannerViewDelegate` is main-actor isolated
and `Sendable`; its `supportedObjectTypes(_:)` requirement is `nonisolated` because the scanner
calls it on the session queue while configuring the session.

The scanner's metadata output delivers to a background metadata queue: the nonisolated
`metadataOutput(_:didOutput:from:)` hands each detected code to the main actor, which reports it
to `onCodeScanned(_:type:rect:path:)`.
