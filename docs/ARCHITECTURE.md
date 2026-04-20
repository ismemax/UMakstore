# Architecture Overview: UMAS (UMak App Store)

This document provides a detailed breakdown of the technical architecture and design patterns used in the UMAS (University of Makati App Store) application.

## 🏗 High-Level Architecture

UMAS is built using a **Modified Clean Architecture** approach, emphasizing separation of concerns and maintainability. It utilizes Flutter's standard `StatefulWidget` and `StatelessWidget` patterns, complemented by global services for cross-cutting concerns.

### Project Structure

```text
lib/
├── models/         # Plain Data Objects (Entities)
├── services/       # Business Logic, Firebase Interactions, Web APIs
├── utils/          # Theming, Constants, and Helpers
├── widgets/        # Reusable UI components
└── [screens].dart  # Direct screen widgets (Presentation Layer)
```

## 🧠 State Management

The application primarily uses a combination of **ChangeNotifier** for global settings and **StreamBuilder** for real-time data flow.

- **Theme & Localization**: Managed via `ThemeService` and `LanguageService`. These services extend `ChangeNotifier`, and the `MaterialApp` listens to their changes in `main.dart`.
- **Real-time Data**: Interactions with Firestore (like the App List and Reviews) utilize `Streams`. This ensures the UI is always in sync with the backend without manual refreshes.
- **Authentication**: Managed by `AuthGate`, which listens to `FirebaseAuth.instance.authStateChanges()`.

## 📡 Service Layer

Logic is encapsulated within the `services/` directory to keep screens focused on the UI.

| Service | Responsibility |
| :--- | :--- |
| `AuthService` | User registration, login, and profile synchronization. |
| `DeveloperService` | App submissions, Cloudinary media uploads, and app status management. |
| `DeviceService` | Monitoring battery status and storage availability for installations. |
| `NotificationService` | Local notifications and FCM integration. |
| `ThemeService` | Persistence of user theme preferences (Light/Dark/System). |

## 🛠 Coding Standards

1. **Service Injection**: Services are generally accessed via singleton patterns or direct instantiation where performance allows.
2. **Asynchronous Operations**: All Firebase and Network operations must be `async` and include proper `try-catch` blocks for error propagation.
3. **UI/Logic Separation**: Business logic (e.g., calculating app size, formatting strings) must reside in the Model or Service layer, never in the Widget's `build` method.
4. **Error Handling**: Use `debugPrint` for developer logs and provide user-friendly `SnackBar` or `Dialog` feedback for runtime errors.

---
*Last Updated: April 2026*
