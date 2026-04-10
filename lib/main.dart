import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'services/theme_service.dart';
import 'services/language_service.dart';
import 'services/notification_service.dart';
import 'services/device_service.dart';
import 'services/auth_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('--- App Boot: Starting Initializations ---');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Firebase App Initialized');
  await ThemeService().init();
  debugPrint('ThemeService Initialized');
  await LanguageService().init();
  debugPrint('LanguageService Initialized');
  NotificationService().init();
  debugPrint('NotificationService initialization started (fire-and-forget)');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeService _themeService = ThemeService();
  final LanguageService _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onStateChanged);
    _languageService.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _themeService.removeListener(_onStateChanged);
    _languageService.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UMak App Store',
      debugShowCheckedModeBanner: false,
      locale: _languageService.locale,
      supportedLocales: const [Locale('en'), Locale('tl')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: _themeService.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has user data, then they're already signed in.
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Otherwise, they're not signed in, show the splash/login flow.
        return const SplashScreen();
      },
    );
  }
}
