#if canImport(Darwin)
#if canImport(CoreGraphics)
import CalderStdLib
import CoreGraphics
import Foundation

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import UIKit

public typealias NSUIColor = UIColor
public typealias NSUIFont = UIFont
#endif

#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit

public typealias NSUIColor = NSColor
public typealias NSUIFont = NSFont
#endif

#if os(iOS) || os(tvOS) || os(macOS)
public extension CGContext {

    /// Draws a circle within a specified frame.
    /// - Parameters:
    ///   - frame: The `CGRect` defining the bounding rectangle for the circle.
    ///   - strokeWidth: The width of the circle's stroke.
    ///   - strokeColor: The `NSUIColor` for the circle's stroke.
    ///   - fillColor: An optional `NSUIColor` to fill the circle with. If `nil`, the circle will not be filled.
    func drawCircle(
        frame: CGRect,
        strokeWidth: CGFloat,
        strokeColor: NSUIColor,
        fillColor: NSUIColor?
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
    ///   - color: The `NSUIColor` to fill the pie slice with.
    func drawPie(
        x: CGFloat,
        y: CGFloat,
        start: CGFloat,
        end: CGFloat,
        radius: CGFloat,
        color: NSUIColor
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
    /// - Parameters:
    ///   - frame: The `CGRect` defining the bounding rectangle for the square.
    ///   - fillColor: An optional `NSUIColor` to fill the square with. If `nil`, the square will not be filled.
    ///   - strokeWidth: The width of the square's stroke.
    ///   - strokeColor: The `NSUIColor` for the square's stroke.
    func drawSquare(
        frame: CGRect,
        fillColor: NSUIColor?,
        strokeWidth: CGFloat,
        strokeColor: NSUIColor
    ) {
        saveGState()

        setLineWidth(strokeWidth)
        setStrokeColor(strokeColor.cgColor)
        stroke(frame)

        if let fill = fillColor {
            setFillColor(fill.cgColor)
            self.fill(frame)
        }
        restoreGState()
    }

    /// Draws text within a specified rectangle using a given font and color.
    /// - Parameters:
    ///   - text: The `NSString` to draw.
    ///   - rect: The `CGRect` defining the area where the text will be drawn.
    ///   - font: The `NSUIFont` to use for drawing the text.
    ///   - color: The `NSUIColor` for the text.
    func drawText(
        text: NSString,
        rect: CGRect,
        font: NSUIFont,
        color: NSUIColor
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

        text.draw(in: rect, withAttributes: [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.foregroundColor: color
        ])

        restoreGState()
    }

    /// Draws a star shape within a specified rectangle.
    /// - Parameters:
    ///   - rect: The `CGRect` defining the bounding box for the star.
    ///   - color: The `NSUIColor` to fill the star with.
    ///   - nbPoint: The number of points the star should have. Defaults to 5.
    func drawStar(
        rect: CGRect,
        color: NSUIColor,
        nbPoint: UInt = 5
    ) {
        saveGState()

        let rayon = rect.size.width / 2.0
        let flip = -1.0
        let theta = 2.0 * Double.pi * (2.0 / Double(nbPoint))

        setLineWidth(1)
        setFillColor(color.cgColor)

        move(to: CGPoint(x: rect.origin.x, y: rayon * flip + rect.origin.y))
        for idx in 0 ..< nbPoint {
            let x = rayon * sin(Double(idx) * theta)
            let y = rayon * cos(Double(idx) * theta)
            addLine(to: CGPoint(x: x + rect.origin.x, y: y * flip + rect.origin.y))
        }
        closePath()
        fillPath()
        restoreGState()
    }
}
#endif
#endif

#endif
