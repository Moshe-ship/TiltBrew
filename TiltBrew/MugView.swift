import SwiftUI

struct MugView: View {
    let roll: Double
    let fillLevel: Double
    let drink: DrinkType
    let hasSpilled: Bool

    private let mugColor = Color(red: 0.83, green: 0.65, blue: 0.46)
    private let mugDark = Color(red: 0.70, green: 0.52, blue: 0.34)

    var body: some View {
        ZStack {
            // Shadow puddle
            Ellipse()
                .fill(Color.black.opacity(0.08))
                .frame(width: 200, height: 20)
                .offset(y: 105)
                .blur(radius: 4)

            // Spill puddle (when spilled)
            if hasSpilled {
                Ellipse()
                    .fill(drink.color.opacity(0.35))
                    .frame(width: 180 + (1.0 - fillLevel) * 60, height: 16)
                    .offset(x: roll * 30, y: 100)
                    .blur(radius: 3)
                    .animation(.easeOut(duration: 0.5), value: hasSpilled)
            }

            // Drips when tilted hard
            if fillLevel < 0.7 && fillLevel > 0 {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(drink.color.opacity(0.6))
                        .frame(width: CGFloat(4 + i * 2), height: CGFloat(5 + i * 2))
                        .offset(
                            x: roll > 0 ? 75 + CGFloat(i * 8) : -75 - CGFloat(i * 8),
                            y: CGFloat(-20 + i * 30)
                        )
                        .opacity(abs(roll) > 0.15 ? 1 : 0)
                        .animation(.easeOut(duration: 0.3).delay(Double(i) * 0.1), value: roll)
                }
            }

            // Mug body
            ZStack {
                // Mug outer shape
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [mugColor, mugDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 140, height: 160)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 3, y: 5)

                // Inner mug (dark interior rim)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.15, green: 0.10, blue: 0.08))
                    .frame(width: 124, height: 148)
                    .offset(y: -2)

                // Liquid inside
                LiquidView(
                    roll: roll,
                    fillLevel: fillLevel,
                    drinkColor: drink.color,
                    darkColor: drink.darkColor,
                    foamColor: drink.foamColor
                )
                .frame(width: 120, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .offset(y: 1)

                // Mug handle
                MugHandle()
                    .offset(x: 82, y: 10)
            }
            .rotationEffect(.degrees(roll * 18))
            .animation(.easeOut(duration: 0.1), value: roll)

            // Face emoji
            Text(faceEmoji)
                .font(.system(size: 40))
                .offset(y: -10)
                .rotationEffect(.degrees(roll * 18))
                .animation(.easeOut(duration: 0.1), value: roll)
        }
    }

    private var faceEmoji: String {
        if hasSpilled { return "😱" }
        if fillLevel < 0.2 { return "😵" }
        if fillLevel < 0.4 { return "😰" }
        if abs(roll) > 0.3 { return "😩" }
        if abs(roll) > 0.15 { return "😟" }
        return "😌"
    }
}

struct MugHandle: View {
    var body: some View {
        ZStack {
            // Outer handle
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.83, green: 0.65, blue: 0.46),
                            Color(red: 0.70, green: 0.52, blue: 0.34)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 10
                )
                .frame(width: 36, height: 52)
        }
    }
}
