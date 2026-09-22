# 🎙️ Interview Coach

An AI-powered voice interview practice application built with Flutter[cite: 3]. Practice mock interviews out loud with real-time speech recognition, instant voice feedback, and performance analytics[cite: 3].

---

## 📱 Screenshots

| Home Screen | Voice Interview | Analytics & Scores |

<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-09-23 at 02 06 40" src="https://github.com/user-attachments/assets/cbd41dba-8282-4360-8676-76aa0eeaed67" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-09-23 at 02 06 47" src="https://github.com/user-attachments/assets/81c3729b-b3eb-43b9-957e-5fa49b271a17" />


*(Note: Place your screenshot image files inside an `assets/screenshots/` folder in your project and update the image paths above).*

---

## ✨ Features

- 🗣️ **Voice-Driven Mock Interviews:** Answer interview questions naturally using Speech-to-Text (`speech_to_text`)[cite: 3].
- 🔊 **Voice Coaching:** Listen to AI-generated questions out loud using Text-to-Speech (`flutter_tts`)[cite: 3].
- 🤖 **AI Question & Answer Analysis:** Sends user answers via Dio HTTP client for intelligent scoring and feedback[cite: 3].
- 📊 **Performance Analytics:** Track your confidence, fluency, and improvement over time with interactive charts (`fl_chart`)[cite: 3].
- 🔒 **Secure Local Storage:** Offline progress caching using Hive (`hive_flutter`) and encrypted credentials via `flutter_secure_storage`[cite: 3].
- 🎨 **Modern UI & Animations:** Fluid user interface enhanced with Lottie animations, pulse mic effects (`avatar_glow`), and smooth transitions (`animate_do`)[cite: 3].

---

## 🛠️ Tech Stack & Libraries

- **Framework:** [Flutter](https://flutter.dev/) (Dart)[cite: 3]
- **State Management:** [Flutter Riverpod](https://riverpod.dev/) (`flutter_riverpod`)[cite: 3]
- **Database / Local Cache:** [Hive](https://pub.dev/packages/hive) & [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)[cite: 3]
- **Networking:** [Dio](https://pub.dev/packages/dio)[cite: 3]
- **Audio & Voice:** `speech_to_text`, `flutter_tts`[cite: 3]
- **UI & Charts:** `fl_chart`, `lottie`, `avatar_glow`, `animate_do`, `google_fonts`[cite: 3]

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0 or higher)[cite: 3]
- Dart SDK[cite: 1, 3]
- Android Studio / VS Code with Flutter plugin

### Installation

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/your-username/interview-coach.git](https://github.com/your-username/interview-coach.git)
   cd interview-coach
