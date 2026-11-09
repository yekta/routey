import AppKit

/// Routey's mark, on its 24 × 24 grid, drawn as a template image for the menu bar.
enum RouteyMark {
    static func image(height: CGFloat = 16) -> NSImage {
        let scale = height / 24
        let image = NSImage(size: NSSize(width: height, height: height), flipped: true) { _ in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            context.scaleBy(x: scale, y: scale)
            context.addPath(path)
            context.setFillColor(.black)
            context.fillPath()
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "Routey"
        return image
    }

    private static let path: CGPath = {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 4.5, y: 0))
        path.addCurve(to: CGPoint(x: 8.887, y: 3.5), control1: CGPoint(x: 6.5998, y: 0.0002), control2: CGPoint(x: 8.4204, y: 1.4527))
        path.addLine(to: CGPoint(x: 17.25, y: 3.5))
        path.addCurve(to: CGPoint(x: 22, y: 8.25), control1: CGPoint(x: 19.8734, y: 3.5), control2: CGPoint(x: 22, y: 5.6266))
        path.addCurve(to: CGPoint(x: 17.25, y: 13), control1: CGPoint(x: 22, y: 10.8734), control2: CGPoint(x: 19.8734, y: 13))
        path.addLine(to: CGPoint(x: 9.86, y: 13))
        path.addLine(to: CGPoint(x: 16.15, y: 16.495))
        path.addCurve(to: CGPoint(x: 22.1118, y: 15.8386), control1: CGPoint(x: 17.6805, y: 14.7907), control2: CGPoint(x: 20.2471, y: 14.5081))
        path.addCurve(to: CGPoint(x: 23.4304, y: 21.6896), control1: CGPoint(x: 23.9764, y: 17.169), control2: CGPoint(x: 24.5441, y: 19.6879))
        path.addCurve(to: CGPoint(x: 17.7634, y: 23.6539), control1: CGPoint(x: 22.3167, y: 23.6913), control2: CGPoint(x: 19.877, y: 24.5369))
        path.addCurve(to: CGPoint(x: 15.178, y: 18.242), control1: CGPoint(x: 15.6498, y: 22.7709), control2: CGPoint(x: 14.5368, y: 20.4411))
        path.addLine(to: CGPoint(x: 8.705, y: 14.646))
        path.addCurve(to: CGPoint(x: 9.65, y: 11), control1: CGPoint(x: 6.95, y: 13.671), control2: CGPoint(x: 7.643, y: 11))
        path.addLine(to: CGPoint(x: 17.25, y: 11))
        path.addCurve(to: CGPoint(x: 20, y: 8.25), control1: CGPoint(x: 18.7688, y: 11), control2: CGPoint(x: 20, y: 9.7688))
        path.addCurve(to: CGPoint(x: 17.25, y: 5.5), control1: CGPoint(x: 20, y: 6.7312), control2: CGPoint(x: 18.7688, y: 5.5))
        path.addLine(to: CGPoint(x: 8.887, y: 5.5))
        path.addCurve(to: CGPoint(x: 5.5, y: 8.887), control1: CGPoint(x: 8.5019, y: 7.1856), control2: CGPoint(x: 7.1856, y: 8.5019))
        path.addLine(to: CGPoint(x: 5.5, y: 19.5))
        path.addCurve(to: CGPoint(x: 4.5, y: 20.5), control1: CGPoint(x: 5.5, y: 20.0523), control2: CGPoint(x: 5.0523, y: 20.5))
        path.addCurve(to: CGPoint(x: 3.5, y: 19.5), control1: CGPoint(x: 3.9477, y: 20.5), control2: CGPoint(x: 3.5, y: 20.0523))
        path.addLine(to: CGPoint(x: 3.5, y: 8.887))
        path.addCurve(to: CGPoint(x: 0.0303, y: 3.9968), control1: CGPoint(x: 1.2677, y: 8.3771), control2: CGPoint(x: 0.2257, y: 6.2722))
        path.addCurve(to: CGPoint(x: 4.5, y: 0), control1: CGPoint(x: 0.2864, y: 1.7214), control2: CGPoint(x: 2.2102, y: 0.0011))
        path.closeSubpath()
        path.move(to: CGPoint(x: 19.5, y: 17))
        path.addCurve(to: CGPoint(x: 17, y: 19.5), control1: CGPoint(x: 18.1193, y: 17), control2: CGPoint(x: 17, y: 18.1193))
        path.addCurve(to: CGPoint(x: 19.5, y: 22), control1: CGPoint(x: 17, y: 20.8807), control2: CGPoint(x: 18.1193, y: 22))
        path.addCurve(to: CGPoint(x: 22, y: 19.5), control1: CGPoint(x: 20.8807, y: 22), control2: CGPoint(x: 22, y: 20.8807))
        path.addCurve(to: CGPoint(x: 19.5, y: 17), control1: CGPoint(x: 22, y: 18.1193), control2: CGPoint(x: 20.8807, y: 17))
        path.closeSubpath()
        path.move(to: CGPoint(x: 4.5, y: 2))
        path.addCurve(to: CGPoint(x: 2, y: 4.5), control1: CGPoint(x: 3.1193, y: 2), control2: CGPoint(x: 2, y: 3.1193))
        path.addCurve(to: CGPoint(x: 4.5, y: 7), control1: CGPoint(x: 2, y: 5.8807), control2: CGPoint(x: 3.1193, y: 7))
        path.addCurve(to: CGPoint(x: 7, y: 4.5), control1: CGPoint(x: 5.8807, y: 7), control2: CGPoint(x: 7, y: 5.8807))
        path.addCurve(to: CGPoint(x: 4.5, y: 2), control1: CGPoint(x: 7, y: 3.1193), control2: CGPoint(x: 5.8807, y: 2))
        path.closeSubpath()
        return path
    }()
}
