import SwiftUI

/// Routey's mark, on its 20 × 24 grid, scaled to fit the frame and centred in it.
struct MarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 4, y: 0))
        path.addCurve(to: CGPoint(x: 7.87402, y: 3), control1: CGPoint(x: 5.86384, y: 0), control2: CGPoint(x: 7.42998, y: 1.27477))
        path.addLine(to: CGPoint(x: 14, y: 3))
        path.addCurve(to: CGPoint(x: 19, y: 8), control1: CGPoint(x: 16.7614, y: 3), control2: CGPoint(x: 19, y: 5.23858))
        path.addCurve(to: CGPoint(x: 14, y: 13), control1: CGPoint(x: 19, y: 10.7614), control2: CGPoint(x: 16.7614, y: 13))
        path.addLine(to: CGPoint(x: 8.85059, y: 13))
        path.addLine(to: CGPoint(x: 13.6006, y: 16.7988))
        path.addCurve(to: CGPoint(x: 16, y: 16), control1: CGPoint(x: 14.269, y: 16.297), control2: CGPoint(x: 15.0999, y: 16))
        path.addCurve(to: CGPoint(x: 20, y: 20), control1: CGPoint(x: 18.2091, y: 16), control2: CGPoint(x: 20, y: 17.7909))
        path.addCurve(to: CGPoint(x: 16, y: 24), control1: CGPoint(x: 20, y: 22.2091), control2: CGPoint(x: 18.2091, y: 24))
        path.addCurve(to: CGPoint(x: 12, y: 20), control1: CGPoint(x: 13.7909, y: 24), control2: CGPoint(x: 12, y: 22.2091))
        path.addCurve(to: CGPoint(x: 12.3506, y: 18.3613), control1: CGPoint(x: 12, y: 19.416), control2: CGPoint(x: 12.1257, y: 18.8615))
        path.addLine(to: CGPoint(x: 7.4541, y: 14.4434))
        path.addCurve(to: CGPoint(x: 8.66211, y: 11), control1: CGPoint(x: 6.02694, y: 13.3014), control2: CGPoint(x: 6.83421, y: 11))
        path.addLine(to: CGPoint(x: 14, y: 11))
        path.addCurve(to: CGPoint(x: 17, y: 8), control1: CGPoint(x: 15.6569, y: 11), control2: CGPoint(x: 17, y: 9.65685))
        path.addCurve(to: CGPoint(x: 14, y: 5), control1: CGPoint(x: 17, y: 6.34315), control2: CGPoint(x: 15.6569, y: 5))
        path.addLine(to: CGPoint(x: 7.87402, y: 5))
        path.addCurve(to: CGPoint(x: 4.99121, y: 7.875), control1: CGPoint(x: 7.51152, y: 6.40844), control2: CGPoint(x: 6.40086, y: 7.5155))
        path.addCurve(to: CGPoint(x: 5, y: 8), control1: CGPoint(x: 4.99633, y: 7.91599), control2: CGPoint(x: 5, y: 7.95762))
        path.addLine(to: CGPoint(x: 5, y: 21))
        path.addCurve(to: CGPoint(x: 4, y: 22), control1: CGPoint(x: 5, y: 21.5523), control2: CGPoint(x: 4.55228, y: 22))
        path.addCurve(to: CGPoint(x: 3, y: 21), control1: CGPoint(x: 3.44772, y: 22), control2: CGPoint(x: 3, y: 21.5523))
        path.addLine(to: CGPoint(x: 3, y: 8))
        path.addCurve(to: CGPoint(x: 3.00781, y: 7.875), control1: CGPoint(x: 3, y: 7.95766), control2: CGPoint(x: 3.00271, y: 7.91595))
        path.addCurve(to: CGPoint(x: 0, y: 4), control1: CGPoint(x: 1.27874, y: 7.4336), control2: CGPoint(x: 0, y: 5.86657))
        path.addCurve(to: CGPoint(x: 4, y: 0), control1: CGPoint(x: 0, y: 1.79086), control2: CGPoint(x: 1.79086, y: 0))
        path.closeSubpath()
        path.move(to: CGPoint(x: 16, y: 18))
        path.addCurve(to: CGPoint(x: 14, y: 20), control1: CGPoint(x: 14.8954, y: 18), control2: CGPoint(x: 14, y: 18.8954))
        path.addCurve(to: CGPoint(x: 16, y: 22), control1: CGPoint(x: 14, y: 21.1046), control2: CGPoint(x: 14.8954, y: 22))
        path.addCurve(to: CGPoint(x: 18, y: 20), control1: CGPoint(x: 17.1046, y: 22), control2: CGPoint(x: 18, y: 21.1046))
        path.addCurve(to: CGPoint(x: 16, y: 18), control1: CGPoint(x: 18, y: 18.8954), control2: CGPoint(x: 17.1046, y: 18))
        path.closeSubpath()
        path.move(to: CGPoint(x: 4, y: 2))
        path.addCurve(to: CGPoint(x: 2, y: 4), control1: CGPoint(x: 2.89543, y: 2), control2: CGPoint(x: 2, y: 2.89543))
        path.addCurve(to: CGPoint(x: 4, y: 6), control1: CGPoint(x: 2, y: 5.10457), control2: CGPoint(x: 2.89543, y: 6))
        path.addCurve(to: CGPoint(x: 6, y: 4), control1: CGPoint(x: 5.10457, y: 6), control2: CGPoint(x: 6, y: 5.10457))
        path.addCurve(to: CGPoint(x: 4, y: 2), control1: CGPoint(x: 6, y: 2.89543), control2: CGPoint(x: 5.10457, y: 2))
        path.closeSubpath()
        let scale = min(rect.width / 20, rect.height / 24)
        let origin = CGPoint(x: rect.midX - 10 * scale, y: rect.midY - 12 * scale)
        return path.applying(CGAffineTransform(translationX: origin.x, y: origin.y).scaledBy(x: scale, y: scale))
    }
}

/// The mark, filled.
struct MarkIcon: View {
    var body: some View {
        MarkShape()
            .aspectRatio(20 / 24, contentMode: .fit)
            .accessibilityLabel("Routey")
    }
}
