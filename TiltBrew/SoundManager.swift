import AVFoundation
import Foundation

final class SoundManager {
    static let shared = SoundManager()

    private var drinkSounds: [DrinkType: DrinkSoundSet] = [:]
    private var lastSloshTime: Date = .distantPast
    var isEnabled: Bool = true

    func preload() {
        // Generate unique procedural sounds for each drink type
        for drink in DrinkType.allCases {
            let profile = drink.soundProfile
            drinkSounds[drink] = DrinkSoundSet(
                slosh1: makeSound(duration: profile.sloshDuration, freq: profile.sloshFreq1, decay: profile.sloshDecay),
                slosh2: makeSound(duration: profile.sloshDuration, freq: profile.sloshFreq2, decay: profile.sloshDecay),
                splash: makeSound(duration: profile.splashDuration, freq: profile.splashFreq, decay: profile.splashDecay),
                pour: makeSound(duration: profile.pourDuration, freq: profile.pourFreq, decay: profile.pourDecay)
            )
        }
    }

    func playSlosh(drink: DrinkType, intensity: Double = 0.5) {
        guard isEnabled, Date().timeIntervalSince(lastSloshTime) > 0.2 else { return }
        guard let sounds = drinkSounds[drink] else { return }
        let player = Bool.random() ? sounds.slosh1 : sounds.slosh2
        player?.volume = Float(min(1.0, intensity * 1.5))
        player?.currentTime = 0
        player?.play()
        lastSloshTime = Date()
    }

    func playSplash(drink: DrinkType) {
        guard isEnabled, let player = drinkSounds[drink]?.splash else { return }
        player.currentTime = 0
        player.play()
    }

    func playPour(drink: DrinkType) {
        guard isEnabled, let player = drinkSounds[drink]?.pour else { return }
        player.currentTime = 0
        player.play()
    }

    // MARK: - Procedural sound synthesis

    private func makeSound(duration: Double, freq: Double, decay: Double) -> AVAudioPlayer? {
        let sampleRate: Double = 44100
        let samples = Int(sampleRate * duration)
        var pcm = [Float](repeating: 0, count: samples)

        // Two-pole resonant low-pass filter on white noise
        // Creates a more convincing liquid sound than single-pole
        var y1: Float = 0, y2: Float = 0
        let omega = Float(2.0 * .pi * freq / sampleRate)
        let r = Float(decay)
        let a1 = -2.0 * r * cos(omega)
        let a2 = r * r
        let gain: Float = (1.0 - r) * 0.5

        for i in 0..<samples {
            let noise = Float.random(in: -1...1)
            let out = gain * noise - a1 * y1 - a2 * y2
            y2 = y1
            y1 = out

            // Amplitude envelope: quick attack, exponential decay
            let t = Float(i) / Float(sampleRate)
            let attack = min(1.0, t / 0.008)
            let envelope = attack * Float(pow(Double(decay), Double(t) * 8.0))
            pcm[i] = out * envelope * 0.5
        }

        return makeWAV(pcm: pcm, sampleRate: sampleRate)
    }

    private func makeWAV(pcm: [Float], sampleRate: Double) -> AVAudioPlayer? {
        let dataSize = pcm.count * 2
        var wav = Data(capacity: 44 + dataSize)
        wav.append(contentsOf: "RIFF".utf8)
        wav.appendUInt32(UInt32(36 + dataSize))
        wav.append(contentsOf: "WAVE".utf8)
        wav.append(contentsOf: "fmt ".utf8)
        wav.appendUInt32(16)
        wav.appendUInt16(1)     // PCM
        wav.appendUInt16(1)     // mono
        wav.appendUInt32(UInt32(sampleRate))
        wav.appendUInt32(UInt32(sampleRate) * 2)
        wav.appendUInt16(2)     // block align
        wav.appendUInt16(16)    // bits
        wav.append(contentsOf: "data".utf8)
        wav.appendUInt32(UInt32(dataSize))

        for sample in pcm {
            let clamped = max(-1.0, min(1.0, sample))
            let val = Int16(clamped * 32767)
            wav.appendUInt16(UInt16(bitPattern: val))
        }

        return try? AVAudioPlayer(data: wav)
    }
}

// MARK: - Sound set per drink
private struct DrinkSoundSet {
    let slosh1: AVAudioPlayer?
    let slosh2: AVAudioPlayer?
    let splash: AVAudioPlayer?
    let pour: AVAudioPlayer?
}

// MARK: - Data helpers
private extension Data {
    mutating func appendUInt16(_ value: UInt16) {
        var v = value.littleEndian
        withUnsafePointer(to: &v) { ptr in
            append(UnsafeBufferPointer(start: ptr, count: 1))
        }
    }
    mutating func appendUInt32(_ value: UInt32) {
        var v = value.littleEndian
        withUnsafePointer(to: &v) { ptr in
            append(UnsafeBufferPointer(start: ptr, count: 1))
        }
    }
}
