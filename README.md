# VisionX AI Assistant 🤖

![Flutter](https://img.shields.io/badge/Flutter-3.19.0-blue?style=flat-square&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.3.0-blue?style=flat-square&logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black)
![BLoC](https://img.shields.io/badge/BLoC-8.0.0-blue?style=flat-square)
![Envied](https://img.shields.io/badge/Envied-0.5.4-green?style=flat-square)

VisionX is an AI-powered conversational assistant developed using Flutter. It offers an advanced conversational experience with support for live search and image generation, with a focus on privacy and performance.


## 🚀 Key Features

- Smart Conversation: Uses Large Language Models (LLM) to provide natural and accurate responses.
- Live Search: Connects to the Tavily API to provide up-to-date information from the web.
- Image Generation: Can generate images based on your text description.
- Custom Protocols: Supports various conversation modes.
- Advanced Protection: All sensitive keys and protocols are encrypted using envied.
- Secure Identity: Recognizes the primary user (Master UID) in encrypted form.

## 🛠 Technologies Used

| Domain | Technologies |
|--------|--------------|
| Interface | Flutter, Dart |
| Authentication | Firebase Auth |
| Database | Cloud Firestore |
| AI | OpenRouter API (CloudRift) |
| Search | Tavily Search API |
| Encryption | Envied (for keys and protocols) |
| State Management | BLoC, GetIt |


## 📱 App Screens

### 🔹 Welcome Screen
<img src="[https://i.ibb.co/Yh7Yv5x/welcome-screen.jpg](https://i.imgpeek.com/BRqhnYH3CC00)" alt="Welcome Screen" width="300"/>

### 🔹 Login Screens

<img src="https://i.ibb.co/m5mT5c4/login-options.jpg" alt="Login Options" width="300"/>

<img src="https://i.ibb.co/6B7XKjD/login-without-account.jpg" alt="Login Without Account" width="300"/>

### 🔹 Chat Interface

<img src="https://i.ibb.co/1RY0LTP/chat-list.jpg" alt="Chat List"  width="300"/>
<img src="https://i.ibb.co/0fLcQ4X/chat-interface.jpg" alt="Chat Interface" width="300"/>

## 📦 Installation

``` bash
git clone https://github.com/mm778877331-stack/visionx-ai-assistant.git
cd visionx-ai-assistant
flutter pub get
flutter run
