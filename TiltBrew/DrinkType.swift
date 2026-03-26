import SwiftUI

enum DrinkType: String, CaseIterable, Identifiable {
    case coffee, matcha, oj, hotChocolate

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .coffee:       return "Coffee"
        case .matcha:       return "Matcha"
        case .oj:           return "OJ"
        case .hotChocolate: return "Hot Choc"
        }
    }

    var color: Color {
        switch self {
        case .coffee:       return Color(red: 0.44, green: 0.31, blue: 0.22)
        case .matcha:       return Color(red: 0.42, green: 0.56, blue: 0.34)
        case .oj:           return Color(red: 0.95, green: 0.65, blue: 0.15)
        case .hotChocolate: return Color(red: 0.35, green: 0.18, blue: 0.12)
        }
    }

    var darkColor: Color {
        switch self {
        case .coffee:       return Color(red: 0.24, green: 0.14, blue: 0.08)
        case .matcha:       return Color(red: 0.28, green: 0.40, blue: 0.20)
        case .oj:           return Color(red: 0.80, green: 0.50, blue: 0.05)
        case .hotChocolate: return Color(red: 0.20, green: 0.10, blue: 0.06)
        }
    }

    var emoji: String {
        switch self {
        case .coffee:       return "☕"
        case .matcha:       return "🍵"
        case .oj:           return "🍊"
        case .hotChocolate: return "🍫"
        }
    }

    var foamColor: Color {
        switch self {
        case .coffee:       return Color(red: 0.85, green: 0.75, blue: 0.60)
        case .matcha:       return Color(red: 0.72, green: 0.82, blue: 0.62)
        case .oj:           return Color(red: 1.0, green: 0.85, blue: 0.55)
        case .hotChocolate: return Color(red: 0.65, green: 0.45, blue: 0.30)
        }
    }

    /// Sound profile — each drink sounds different
    var soundProfile: SoundProfile {
        switch self {
        case .coffee:
            // Deep, warm, thick slosh
            return SoundProfile(
                sloshFreq1: 180, sloshFreq2: 150, sloshDecay: 0.88,
                splashFreq: 280, splashDecay: 0.90,
                pourFreq: 140, pourDecay: 0.94,
                sloshDuration: 0.35, splashDuration: 0.9, pourDuration: 1.3
            )
        case .matcha:
            // Lighter, silky, mid-range
            return SoundProfile(
                sloshFreq1: 350, sloshFreq2: 320, sloshDecay: 0.82,
                splashFreq: 450, splashDecay: 0.88,
                pourFreq: 250, pourDecay: 0.93,
                sloshDuration: 0.28, splashDuration: 0.7, pourDuration: 1.1
            )
        case .oj:
            // Bright, bubbly, splashy
            return SoundProfile(
                sloshFreq1: 500, sloshFreq2: 550, sloshDecay: 0.78,
                splashFreq: 600, splashDecay: 0.85,
                pourFreq: 380, pourDecay: 0.90,
                sloshDuration: 0.22, splashDuration: 0.6, pourDuration: 0.9
            )
        case .hotChocolate:
            // Very thick, viscous, slow, gloopy
            return SoundProfile(
                sloshFreq1: 120, sloshFreq2: 100, sloshDecay: 0.92,
                splashFreq: 200, splashDecay: 0.93,
                pourFreq: 100, pourDecay: 0.96,
                sloshDuration: 0.45, splashDuration: 1.1, pourDuration: 1.5
            )
        }
    }

    /// How fast the liquid drains (thicker = slower)
    var viscosity: Double {
        switch self {
        case .coffee:       return 1.0
        case .matcha:       return 0.9
        case .oj:           return 1.2   // thin, drains fast
        case .hotChocolate: return 0.65  // thick, drains slow
        }
    }
}

struct SoundProfile {
    let sloshFreq1: Double
    let sloshFreq2: Double
    let sloshDecay: Double
    let splashFreq: Double
    let splashDecay: Double
    let pourFreq: Double
    let pourDecay: Double
    let sloshDuration: Double
    let splashDuration: Double
    let pourDuration: Double
}
