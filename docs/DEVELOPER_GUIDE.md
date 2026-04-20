# Developer Walkthrough & Guidelines: UMAS

Welcome to the UMak App Store (UMAS) development team! This guide is designed to help junior developers understand how the code is structured, how data flows, and how to implement new features following our standards.

## Navigation Guide

If you are looking for specific functionality, start here:

- **Authentication Flow**: Look at `lib/login_screen.dart` and `lib/services/auth_service.dart`.
- **App Submission**: Check `lib/add_app_screen.dart` and `lib/services/developer_service.dart`.
- **Image Handling**: All Cloudinary logic is encapsulated in `lib/services/developer_service.dart`.
- **Admin Actions**: Manage status and roles in `lib/admin_dashboard_screen.dart` and `lib/role_management_screen.dart`.
- **UI Components**: Check `lib/widgets/` for reusable buttons, cards, and dialogs.

## Lifecycle of an Application Submission

Understanding this flow is key to understanding the system:

1.  **Submission**: A user with the `developer` role fills out the form in `AddAppScreen`.
2.  **Media Upload**: `DeveloperService.uploadToCloudinary` is called for the icon and each screenshot.
3.  **Firestore Write**: Data is saved to `submitted_apps` with a status of `'Pending'`.
4.  **Admin Review**: An admin sees the app in the `AdminDashboardScreen`.
5.  **Approval**: Admin hits "Approve", status changes to `'Live'`.
6.  **Store Display**: `HomeScreen` uses a `Stream` to fetch all apps where `status == 'Live'` and displays them.

## State Management Pattern

We use a "Service-Listener" pattern. It's simpler than Bloc or Redux but very effective for this scale:

1.  **Define a Service**: Create a class in `lib/services/` that extends `ChangeNotifier`.
2.  **Notify Consumers**: Call `notifyListeners()` whenever a piece of state (like the current theme) changes.
3.  **Listen in UI**:
    ```dart
    final themeService = ThemeService();
    themeService.addListener(() {
      if (mounted) setState(() {});
    });
    ```

## Coding Standards for Juniors

To keep the code clean as we grow, please follow these rules:

### 1. Avoid "Fat Widgets"
If your `build` method is longer than 100 lines, extract pieces into separate widgets in `lib/widgets/` or as private methods within the same file.

### 2. Services, not Logic in UI
**BAD (Logic in Widget):**
```dart
onPressed: () async {
  var result = await FirebaseFirestore.instance.collection('apps').add({...});
}
```

**GOOD (Logic in Service):**
```dart
onPressed: () async {
  await developerService.submitApp(appData);
}
```

### 3. Handle Errors Gracefully
Always wrap asynchronous calls in `try-catch` blocks and show a human-readable message to the user.

### 4. Cloudinary Transformations
When displaying images, **always** use `DeveloperService.getOptimizedUrl()`. Never pass a raw URL to a `NetworkImage` if it comes from Cloudinary, or we will waste the university's bandwidth.

## Testing your changes
Before pushing, ensure:
- The app compiles in both **Light** and **Dark** modes.
- You have run `flutter analyze` and fixed all linting warnings.
- Image uploads work on a real device (emulators sometimes have network issues with Cloudinary).

---
*Created by the Senior Development Team.*
