# Keyboard-avoidance modifier

Calder does not provide a SwiftUI modifier that moves content out of the way of the software keyboard.

## Why this is out of scope

SwiftUI already avoids the keyboard: scroll views, forms and lists inset their content automatically when the keyboard appears, and `ignoresSafeArea(.keyboard)` opts out where that isn't wanted. A Calder modifier on top of that would duplicate platform behaviour and fight it in the containers that already adjust.

Code that needs the keyboard's size for something SwiftUI doesn't handle can read `KeyboardObserver` from the environment:

```swift
@Environment(\.keyboardObserver) private var keyboard

var body: some View {
    content.padding(.bottom, keyboard.visible ? keyboard.keyboardSize.height : 0)
}
```

UIKit screens keep using the existing `UIScrollView` keyboard-inset helpers.

## Prior requests

- #169: "SwiftUI keyboard-avoidance modifier"
