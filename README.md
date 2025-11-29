# 🚗 Gaza Cars

<div align="center">
  <img src="assets/icon/app_icon.png" alt="Gaza Cars Logo" width="150" height="150" style="border-radius: 20px;">
  <br>
  <h1>The Premium Marketplace for Cars in Gaza</h1>

  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
  [![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)](https://firebase.google.com/)
  [![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)](https://apple.com/ios/)
  [![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://android.com/)
</div>

---

## 📱 Overview

**Gaza Cars** is a state-of-the-art mobile application designed to revolutionize the car buying and selling experience in Gaza. Built with **Flutter** and **Clean Architecture**, it combines performance, security, and a stunning user interface to connect buyers and traders seamlessly.

### 🎨 Design & Theme

The app features a modern, clean aesthetic centered around a **Premium Blue** theme, designed to evoke trust and professionalism.

*   **Primary Color**: `#1E88E5` (Ocean Blue)
*   **Typography**: **Cairo** (Google Fonts) for excellent Arabic & English readability.
*   **Modes**: Fully supported **Light** and **Dark** themes.

<div align="center">
  <img src="assets/splash/splash_screen.png" alt="Splash Screen" width="200" style="border-radius: 10px; margin: 10px;">
</div>

---

## ✨ Key Features

*   **🔐 Secure Authentication**: Seamless sign-up via Email, Google, or Apple.
*   **👥 Role-Based Access**: Tailored experiences for **Buyers** (browsing, chatting) and **Traders** (selling, analytics).
*   **🚘 Advanced Search**: Filter cars by make, model, price, year, condition, and more.
*   **💬 Real-Time Chat**: Instant messaging between buyers and sellers with block/report features.
*   **❤️ Favorites**: Save listings to your watchlist for quick access.
*   **🌍 Multi-Language Support**: Native support for **English** and **Arabic** (RTL).
*   **🛡️ Admin Dashboard**: Powerful tools for content moderation and user management.

---

## 🛠️ Tech Stack

This project is built using industry-standard best practices and libraries:

*   **Framework**: [Flutter](https://flutter.dev/) (3.x)
*   **Language**: [Dart](https://dart.dev/)
*   **Architecture**: Clean Architecture (Domain, Data, Presentation layers)
*   **State Management**: [Flutter Bloc](https://pub.dev/packages/flutter_bloc)
*   **Dependency Injection**: [GetIt](https://pub.dev/packages/get_it) & [Injectable](https://pub.dev/packages/injectable)
*   **Backend**: [Firebase](https://firebase.google.com/)
    *   Authentication
    *   Cloud Firestore
    *   Cloud Storage
    *   Cloud Messaging (FCM)
*   **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
*   **Localization**: [flutter_localizations](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)

---

## 🚀 Getting Started

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install)
*   [CocoaPods](https://cocoapods.org/) (for iOS)
*   Firebase Project Setup

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/elamir-mansour/gaza-cars-app.git
    cd gaza-cars-app
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Setup Firebase**
    *   Add `google-services.json` to `android/app/`.
    *   Add `GoogleService-Info.plist` to `ios/Runner/`.

4.  **Run the app**
    ```bash
    flutter run
    ```

---

## ⚖️ Legal

*   [Privacy Policy](https://elamir-mansour.github.io/gaza-cars-app/privacy_policy.html)
*   [Terms of Service](https://elamir-mansour.github.io/gaza-cars-app/terms_of_service.html)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

<div align="center">
  <sub>Built with ❤️ for Gaza</sub>
</div>
