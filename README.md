# UMakstore 🚀

[![Platform](https://img.shields.io/badge/Platform-Android-green.svg)](https://developer.android.com)
[![Kotlin](https://img.shields.io/badge/Kotlin-1.9+-blue.svg)](https://kotlinlang.org)
[![Compose](https://img.shields.io/badge/Jetpack-Compose-orange.svg)](https://developer.android.com/jetpack/compose)
[![Hilt](https://img.shields.io/badge/Dependency-Injection-purple.svg)](https://developer.android.com/training/dependency-injection/hilt-android)

**UMakstore** is a modern, performance-oriented Android application serving as the central hub for students and developers at the University of Makati. It provides a seamless interface for discovering, managing, and updating academic and utility applications within the UMak ecosystem.

---

## 🛠 Tech Stack

Built with a commitment to modern Android best practices, this project leverages the following technologies:

- **Language**: [Kotlin](https://kotlinlang.org/) (Coroutines, Flow for asynchronous programming)
- **UI Framework**: [Jetpack Compose](https://developer.android.com/jetpack/compose) (Declarative UI component architecture)
- **Dependency Injection**: [Dagger Hilt](https://developer.android.com/training/dependency-injection/hilt-android) (Standardized dependency management)
- **Local Persistence**: [Room Database](https://developer.android.com/training/data-storage/room) (SQLite abstraction layer)
- **Networking**: [Retrofit](https://square.github.io/retrofit/) & [OkHttp](https://square.github.io/okhttp/) (REST API consumption)
- **Architecture**: **MVVM (Model-View-ViewModel)** with **Clean Architecture** principles (Data, Domain, and Presentation layers)
- **Image Loading**: [Coil](https://coil-kt.github.io/coil/) (Kotlin-first image loading library)

---

## 🚀 Getting Started

Follow these instructions to set up the project on your local machine for development and testing.

### Prerequisites

- **Android Studio Ladybug** (or later)
- **Android SDK Platform 34** (or later)
- **Gradle 8.0+**

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ismemax/UMakstore.git
   ```

2. **Open the project:**
   Launch Android Studio and select **Open** -> Navigate to the cloned directory.

3. **Configure API Keys:**
   This project uses sensitive configuration data (e.g., Firebase, API Base URLs). To maintain security, these are managed via `local.properties`.
   
   - Locate (or create) the `local.properties` file in your root directory.
   - Add your keys as follows:
     ```properties
     BASE_URL="https://api.umak.edu.ph/v1/"
     API_KEY="your_api_key_here"
     ```
   
4. **Sync Gradle:**
   Click **"Sync Project with Gradle Files"** and wait for the dependencies to download.

---

## 🏗 Architecture

The app follows **Clean Architecture** to ensure high maintainability, testability, and scalability. It is divided into three primary layers:

### 1. Data Layer
Handles all data retrieval from both the local Room database and remote APIs via Retrofit. It implements the Repository patterns defined in the Domain layer.

### 2. Domain Layer
The core of the application. It contains **Business Logic**, **Use Cases**, and **Entities**. This layer is pure Kotlin/Java and has no dependency on the Android framework or the Data layer.

### 3. Presentation Layer
Powered by **Jetpack Compose** and **MVVM**. 
- **ViewModels**: Manage UI state using `StateFlow` and handle user interactions by executing Use Cases.
- **Compose UI**: Reusable components that react to state changes in the ViewModel.

---

## 🧪 Testing

Quality is a first-class citizen in this project. We keep a high code coverage via automated testing.

### Unit Tests
Execute the business logic and ViewModel tests using:
```bash
./gradlew test
```

### UI Tests (Instrumented)
Verify the UI flow and integration using Espresso/Compose Test Rule:
```bash
./gradlew connectedAndroidTest
```

---

## 📈 Roadmap & Contributions

We welcome contributions from the UMak developer community. 
- **Internal Tools**: Check the `developer_service` module for API integration guides.
- **Reporting Issues**: Use the GitHub Issues tab to report bugs or request features.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Developed with ❤️ by the **UMak Tech Team**.
