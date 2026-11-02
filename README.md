# Toddler Joy

> **Interactive, sensory playground app for toddlers** built with Flutter & Dart.

[![Flutter](https://img.shields.io/badge/Flutter-3.24%2B-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5%2B-0175C2.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## About Toddler Joy

Toddler Joy is an interactive touch, sound, and visual playground designed for early childhood engagement. It offers safe, advertisement-free sensory mini-games:

- 🫧 **Bubble Pop:** Float and pop multi-colored bubbles with particle splash physics and soothing pops.
- 🎹 **Rainbow Xylophone:** 8-key colorful musical keyboard with pitch-accurate audio tones and visual haptic pulses.
- 🦁 **Animal Friends:** Tap animals to discover friendly illustrations, animations, and sound effects.
- 🔷 **Shape & Color Explorer:** Interactive sorting and touch responses for foundational shape recognition.

---

## Project Structure

```
lib/
├── main.dart
├── screens/
│   ├── bubbles_screen.dart       # Bubble popping physics & particles
│   ├── xylophone_screen.dart     # Colorful musical xylophone
│   ├── animals_screen.dart       # Interactive animal sounds & cards
│   └── shapes_screen.dart        # Shapes and colors playground
├── services/
│   └── sound_service.dart        # Tone generation & audio feedback
└── widgets/
    └── particle_overlay.dart     # Confetti & touch sparkle effects
```

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.5.0`
- Android Studio / VS Code with Flutter extension

### Run Locally

```bash
# Clone the repository
git clone https://github.com/locus-basanta/toddler-joy.git
cd toddler-joy

# Install dependencies
flutter pub get

# Run on device or emulator
flutter run
```

---

## License

MIT © 2026 Basanta Sapkota
