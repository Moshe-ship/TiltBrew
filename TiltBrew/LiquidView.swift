import SwiftUI

struct LiquidView: View {
    let roll: Double
    let fillLevel: Double
    let drinkColor: Color
    let darkColor: Color
    let foamColor: Color

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let liquidHeight = h * fillLevel
            let surfaceY = h - liquidHeight

            // Tilt shifts the surface left/right
            let tiltOffset = roll * 40.0
            let leftY = surfaceY - tiltOffset
            let rightY = surfaceY + tiltOffset

            ZStack {
                // Main liquid body
                Path { path in
                    path.move(to: CGPoint(x: 0, y: leftY))
                    // Curved surface with wave effect
                    path.addQuadCurve(
                        to: CGPoint(x: w, y: rightY),
                        control: CGPoint(
                            x: w / 2 + roll * w * 0.3,
                            y: min(leftY, rightY) - 8
                        )
                    )
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.addLine(to: CGPoint(x: 0, y: h))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [drinkColor, darkColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                // Foam/highlight on top surface
                Path { path in
                    path.move(to: CGPoint(x: 0, y: leftY))
                    path.addQuadCurve(
                        to: CGPoint(x: w, y: rightY),
                        control: CGPoint(
                            x: w / 2 + roll * w * 0.3,
                            y: min(leftY, rightY) - 8
                        )
                    )
                    // Thin strip below surface
                    let stripH: CGFloat = 6
                    path.addLine(to: CGPoint(x: w, y: rightY + stripH))
                    path.addQuadCurve(
                        to: CGPoint(x: 0, y: leftY + stripH),
                        control: CGPoint(
                            x: w / 2 + roll * w * 0.3,
                            y: min(leftY, rightY) - 8 + stripH
                        )
                    )
                    path.closeSubpath()
                }
                .fill(foamColor.opacity(0.4))
            }
            .animation(.easeOut(duration: 0.08), value: roll)
            .animation(.easeOut(duration: 0.15), value: fillLevel)
        }
    }
}
