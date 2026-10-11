#if canImport(Darwin)
    #if canImport(CoreGraphics)
        import CalderStdLib
        import CoreGraphics
        import Foundation

        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
            import UIKit

            /// The platform color type: `UIColor` on iOS, tvOS, and Mac Catalyst, and `NSColor` on macOS.
            public typealias CalderPlatformColor = UIColor
            /// The platform font type: `UIFont` on iOS, tvOS, and Mac Catalyst, and `NSFont` on macOS.
            public typealias CalderPlatformFont = UIFont
        #endif

        #if os(macOS) && !targetEnvironment(macCatalyst)
            import AppKit

            /// The platform color type: `UIColor` on iOS, tvOS, and Mac Catalyst, and `NSColor` on macOS.
            public typealias CalderPlatformColor = NSColor
            /// The platform font type: `UIFont` on iOS, tvOS, and Mac Catalyst, and `NSFont` on macOS.
            public typealias CalderPlatformFont = NSFont
        #endif

        #if os(iOS) || os(tvOS) || os(macOS)
            /// The previous name of ``CalderPlatformColor``.
            ///
            /// Renamed because other libraries, such as DGCharts, declare a public `NSUIColor` too.
            @available(*, deprecated, renamed: "CalderPlatformColor")
            public typealias NSUIColor = CalderPlatformColor

            /// The previous name of ``CalderPlatformFont``.
            ///
            /// Renamed because other libraries, such as DGCharts, declare a public `NSUIFont` too.
            @available(*, deprecated, renamed: "CalderPlatformFont")
            public typealias NSUIFont = CalderPlatformFont
        #endif

        #if os(iOS) || os(tvOS) || os(macOS)
            public extension CGContext {

                /// Draws a circle within a specified frame.
                /// - Parameters:
                ///   - frame: The `CGRect` defining the bounding rectangle for the circle.
                ///   - strokeWidth: The width of the circle's stroke.
                ///   - strokeColor: The `CalderPlatformColor` for the circle's stroke.
                ///   - fillColor: An optional `CalderPlatformColor` to fill the circle with. If `nil`, the circle will not be filled.
                func drawCircle(
                    frame: CGRect,
                    strokeWidth: CGFloat,
                    strokeColor: CalderPlatformColor,
                    fillColor: CalderPlatformColor?
                ) {
                    saveGState()

                    if let fill = fillColor {
                        setFillColor(fill.cgColor)
                        fillEllipse(in: frame)
                    }

                    setLineWidth(strokeWidth)
                    setStrokeColor(strokeColor.cgColor)
                    strokeEllipse(in: frame)
                    restoreGState()
                }

                /// Draws a pie slice (arc) with a specified center, angles, radius, and color.
                /// - Parameters:
                ///   - x: The X-coordinate of the center of the pie.
                ///   - y: The Y-coordinate of the center of the pie.
                ///   - start: The starting angle in degrees for the arc.
                ///   - end: The end angle in degrees for the arc.
                ///   - radius: The radius of the pie slice.
                ///   - color: The `CalderPlatformColor` to fill the pie slice with.
                func drawPie(
                    x: CGFloat,
                    y: CGFloat,
                    start: CGFloat,
                    end: CGFloat,
                    radius: CGFloat,
                    color: CalderPlatformColor
                ) {
                    saveGState()
                    setFillColor(color.cgColor)
                    move(to: CGPoint(x: x, y: y))

                    addArc(
                        center: CGPoint(x: x, y: y),
                        radius: radius,
                        startAngle: start.degreesToRadians,
                        endAngle: end.degreesToRadians,
                        clockwise: false
                    )

                    closePath()
                    fillPath()
                    restoreGState()
                }

                /// Draws a square within a specified frame.
                ///
                /// The square is filled first, then stroked, so the full stroke width stays visible over the fill.
                /// - Parameters:
                ///   - frame: The `CGRect` defining the bounding rectangle for the square.
                ///   - fillColor: An optional `CalderPlatformColor` to fill the square with. If `nil`, the square will not be filled.
                ///   - strokeWidth: The width of the square's stroke.
                ///   - strokeColor: The `CalderPlatformColor` for the square's stroke.
                func drawSquare(
                    frame: CGRect,
                    fillColor: CalderPlatformColor?,
                    strokeWidth: CGFloat,
                    strokeColor: CalderPlatformColor
                ) {
                    saveGState()

                    if let fill = fillColor {
                        setFillColor(fill.cgColor)
                        self.fill(frame)
                    }

                    setLineWidth(strokeWidth)
                    setStrokeColor(strokeColor.cgColor)
                    stroke(frame)
                    restoreGState()
                }

                /// Draws text within a specified rectangle using a given font and color.
                ///
                /// The text is drawn upright into the receiver, which is made the current UIKit or AppKit graphics
                /// context for the duration of the call. The receiver is treated as flipped (top-left origin, as with
                /// `UIGraphicsImageRenderer`) when its current transformation matrix inverts the y-axis, and as
                /// unflipped (bottom-left origin, as with a bitmap `CGContext`) otherwise.
                /// Call this method on the thread that owns the receiver.
                /// - Parameters:
                ///   - text: The `NSString` to draw.
                ///   - rect: The `CGRect` defining the area where the text will be drawn.
                ///   - font: The `CalderPlatformFont` to use for drawing the text.
                ///   - color: The `CalderPlatformColor` for the text.
                func drawText(
                    text: NSString,
                    rect: CGRect,
                    font: CalderPlatformFont,
                    color: CalderPlatformColor
                ) {
                    saveGState()
                    setTextDrawingMode(.fill)
                    setAllowsFontSmoothing(true)
                    setAllowsFontSubpixelPositioning(true)
                    setAllowsFontSubpixelQuantization(true)
                    setShouldAntialias(true)
                    setShouldSmoothFonts(true)
                    setShouldSubpixelPositionFonts(true)
                    setShouldSubpixelQuantizeFonts(true)

                    let style = NSMutableParagraphStyle()
                    style.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    style.alignment = NSTextAlignment.center

                    let isFlipped = ctm.d < 0
                    #if os(macOS) && !targetEnvironment(macCatalyst)
                        NSGraphicsContext.saveGraphicsState()
                        NSGraphicsContext.current = NSGraphicsContext(cgContext: self, flipped: isFlipped)
                    #else
                        if !isFlipped {
                            // UIKit draws text for a flipped context; flip around `rect` so it stays upright in place.
                            translateBy(x: 0, y: rect.minY + rect.maxY)
                            scaleBy(x: 1, y: -1)
                        }
                        UIGraphicsPushContext(self)
                    #endif

                    text.draw(in: rect, withAttributes: [
                        NSAttributedString.Key.font: font,
                        NSAttributedString.Key.paragraphStyle: style,
                        NSAttributedString.Key.foregroundColor: color
                    ])

                    #if os(macOS) && !targetEnvironment(macCatalyst)
                        NSGraphicsContext.restoreGraphicsState()
                    #else
                        UIGraphicsPopContext()
                    #endif

                    restoreGState()
                }

                /// Draws a star shape centred within a specified rectangle.
                ///
                /// The star alternates `nbPoint` outer tips with inner vertices. Its outer radius is half the
                /// shorter side of `rect`, so the star stays inside the rectangle. The first tip points toward
                /// `rect.minY`, which is up in UIKit's flipped coordinate system. Nothing is drawn when `nbPoint`
                /// is `0`.
                /// - Parameters:
                ///   - rect: The `CGRect` defining the bounding box for the star.
                ///   - color: The `CalderPlatformColor` to fill the star with.
                ///   - nbPoint: The number of points the star should have. Defaults to 5.
                func drawStar(
                    rect: CGRect,
                    color: CalderPlatformColor,
                    nbPoint: UInt = 5
                ) {
                    guard nbPoint > 0 else {
                        return
                    }

                    saveGState()

                    let outerRadius = min(rect.width, rect.height) / 2.0
                    // 0.382 gives a regular five-point star; other counts keep the same proportions.
                    let innerRadius = outerRadius * 0.382
                    let step = Double.pi / Double(nbPoint)

                    setFillColor(color.cgColor)

                    for index in 0 ..< 2 * Int(nbPoint) {
                        let radius = index.isMultiple(of: 2) ? outerRadius : innerRadius
                        let angle = Double(index) * step
                        let point = CGPoint(x: rect.midX + radius * sin(angle), y: rect.midY - radius * cos(angle))
                        if index == 0 {
                            move(to: point)
                        } else {
                            addLine(to: point)
                        }
                    }
                    closePath()
                    fillPath()
                    restoreGState()
                }
            }
        #endif
    #endif

#endif
