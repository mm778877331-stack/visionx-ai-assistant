# VisionX 🤖

![Flutter](https://img.shields.io/badge/Flutter-3.19.0-blue?style=flat-square&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.3.0-blue?style=flat-square&logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black)
![Envied](https://img.shields.io/badge/Envied-0.5.4-green?style=flat-square)

VisionX is an AI-powered conversational assistant developed using Flutter. It offers an advanced conversational experience with support for live search and image generation, with a focus on privacy and performance.

---

## 🚀 Key Features

- Smart Conversation: Uses Large Language Models (LLM) to provide natural and accurate responses.
- Live Search: Connects to the Tavily API to provide up-to-date information from the web.
- Image Generation: Can generate images based on your text description.
- Custom Protocols: Supports various conversation modes.
- Advanced Protection: All sensitive keys and protocols are encrypted using envied.
- Secure Identity: Recognizes the primary user (Master UID) in encrypted form.

---

## 🛠 Technologies Used

- 🖥️ Interface: Flutter, Dart
- 🔐 Authentication: Firebase Auth
- 🗄️ Database: Cloud Firestore
- 🤖 AI: OpenRouter API (CloudRift)
- 🔍 Search: Tavily Search API
- 🔒 Encryption: Envied
- ⚙️ State Management: BLoC, GetIt

---

## 📸 App Screenshots

| Home Screen | Chat Screen | Settings |
|:---:|:---:|:---:|
| ![Home](screenshots/home_screen.png) | ![Chat](screenshots/chat_screen.png) | ![Settings](screenshots/settings_screen.png) |

---

## 📦 Installation

``` bash
git clone https://github.com/mm778877331-stack/visionx-ai-assistant.git
cd visionx-ai-assistant
flutter pub get
flutter run
