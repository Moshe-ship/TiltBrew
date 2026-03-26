import SwiftUI

struct ContentView: View {
    @ObservedObject var accelerometer: Accelerometer
    @State private var fillLevel: Double = 0.85
    @State private var selectedDrink: DrinkType = .coffee
    @State private var hasSpilled = false
    @State private var soundsOn = true
    @State private var previousTiltMag: Double = 0
    @State private var spillCount: Int = 0

    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    private let bgColor = Color(red: 0.96, green: 0.90, blue: 0.83)
    private let espresso = Color(red: 0.24, green: 0.14, blue: 0.08)
    private let coffeeText = Color(red: 0.44, green: 0.31, blue: 0.22)

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Text("TiltBrew")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(espresso)

                    Spacer()

                    if spillCount > 0 {
                        Text("\(spillCount) spill\(spillCount == 1 ? "" : "s")")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(coffeeText.opacity(0.5))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color.white.opacity(0.5)))
                    }

                    Button(action: {
                        soundsOn.toggle()
                        SoundManager.shared.isEnabled = soundsOn
                    }) {
                        Image(systemName: soundsOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(coffeeText)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Color.white.opacity(0.4)))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 8)

                Spacer(minLength: 12)

                // Mug
                MugView(
                    roll: accelerometer.roll,
                    fillLevel: fillLevel,
                    drink: selectedDrink,
                    hasSpilled: hasSpilled
                )
                .frame(height: 240)

                // Status
                Text(statusText)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(coffeeText.opacity(0.5))
                    .padding(.top, 4)

                Spacer(minLength: 12)

                // Drink picker
                HStack(spacing: 8) {
                    ForEach(DrinkType.allCases) { drink in
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                selectedDrink = drink
                                refill()
                            }
                        }) {
                            VStack(spacing: 2) {
                                Text(drink.emoji)
                                    .font(.system(size: 20))
                                Text(drink.displayName)
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .foregroundColor(coffeeText)
                                    .lineLimit(1)
                            }
                            .frame(width: 68, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedDrink == drink
                                          ? Color.white.opacity(0.65)
                                          : Color.white.opacity(0.15))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedDrink == drink
                                            ? drink.color.opacity(0.4)
                                            : Color.clear, lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Refill
                Button(action: refill) {
                    Label("Refill", systemImage: "arrow.clockwise")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .padding(.horizontal, 26)
                        .padding(.vertical, 10)
                        .background(espresso)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: espresso.opacity(0.25), radius: 5, y: 3)
                }
                .buttonStyle(.plain)
                .opacity(fillLevel < 0.6 ? 1.0 : 0.35)
                .padding(.top, 12)

                // Sensor warning
                if !accelerometer.isAvailable {
                    Text("No accelerometer — need M1 Pro+ MacBook")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.red.opacity(0.55))
                        .padding(.top, 6)
                }
            }
            .padding(20)
        }
        .onAppear {
            SoundManager.shared.preload()
        }
        .onReceive(timer) { _ in
            updatePhysics()
        }
    }

    private var statusText: String {
        if hasSpilled { return "Spilled! Tap refill for another cup" }
        if fillLevel < 0.3 { return "Careful... almost empty" }
        if abs(accelerometer.roll) > 0.2 { return "Whoa, watch the tilt!" }
        return "Tilt your MacBook to spill"
    }

    private func refill() {
        fillLevel = 0.85
        hasSpilled = false
        SoundManager.shared.playPour(drink: selectedDrink)
    }

    private func updatePhysics() {
        guard accelerometer.isAvailable else { return }

        let tiltMag = accelerometer.tiltMagnitude
        let rollAbs = abs(accelerometer.roll)

        if tiltMag > 0.12 && fillLevel > 0 {
            // Drain rate adjusted by drink viscosity
            let drainRate = tiltMag * 0.006 * selectedDrink.viscosity
            fillLevel = max(0, fillLevel - drainRate)

            if abs(tiltMag - previousTiltMag) > 0.03 || rollAbs > 0.25 {
                SoundManager.shared.playSlosh(drink: selectedDrink, intensity: tiltMag)
            }

            if fillLevel <= 0.03 && !hasSpilled {
                hasSpilled = true
                spillCount += 1
                SoundManager.shared.playSplash(drink: selectedDrink)
            }
        }

        previousTiltMag = tiltMag
    }
}
