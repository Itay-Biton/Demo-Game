# 🔥 Card Battle Game (iOS)

A dynamic, animated two-player (user vs. PC) card game for iOS built with UIKit. Players compete over a series of rounds to collect the highest score. The game features smooth card-flip animations, countdown timers, sound effects, and automatic theme adaptation for light and dark modes.

---

## 📱 Features

- 🎴 **Randomized card decks** for user and bot
- ⏱ **Countdown timer** before each round
- 💥 **Animated card flip** with sound effects
- 🔊 **Background music** and round result sounds
- 🎉 **Result screen** after all rounds
- 🌙 **Supports Light and Dark Mode**
- 📱 **Landscape-only** game orientation

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/your-username/card-battle-game.git
cd card-battle-game
```

2. Open in Xcode

Double-click Demo Game.xcodeproj or Demo Game.xcworkspace.

3. Set up resources
	•	Make sure all .mp3 files are included in the Sounds folder as a folder reference (blue folder icon).
	•	All card and UI images should be added to Assets.xcassets with light/dark variations if applicable.

4. Build & Run

Select a device or simulator and click Run ▶️.

⸻

🎵 Audio Integration
	•	All sounds are handled by SoundManager.swift using AVAudioPlayer.
	•	Background music resumes/pauses when the app enters or exits the foreground.
	•	Round result sounds play based on outcome.

⸻

🌗 Light & Dark Mode

Images like background or UI icons should use Appearances: Any, Dark in the asset catalog. The game automatically switches based on system theme.

⸻

🧪 Future Improvements
	•	Add multiplayer support
	•	Leaderboard and stats tracking
	•	Custom decks and animations
	•	Haptics feedback
	•	Sound toggle in settings

⸻

🧑‍💻 Author

Itay Biton
fire-arc.com
Email: itay.b@fire-arc.com

⸻

📄 License

This project is licensed under the MIT License.
