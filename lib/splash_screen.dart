import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'services/device_service.dart';
import 'services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInitialNavigation();
  }

  Future<void> _checkInitialNavigation() async {
    // Delay for a visual splash effect
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final bool hasFinishedOnboarding =
        prefs.getBool('hasFinishedOnboarding') ?? false;

    // Check actual Firebase Auth status
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      // User is authenticated, validate device first
      final deviceRegistered = await DeviceService().isDeviceRegistered();
      
      if (deviceRegistered) {
        // Device is registered, validate it
        final isValidDevice = await AuthService().validateDevice();
        if (isValidDevice) {
          // Device is valid, go to Home
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        } else {
          // Device is not valid, show error and sign out
          _showDeviceErrorDialog();
        }
      } else {
        // First time on this device, register it
        final registered = await AuthService().registerDevice();
        if (registered) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        } else {
          _showDeviceErrorDialog();
        }
      }
    } else if (!hasFinishedOnboarding) {
      // No user, and hasn't seen onboarding, go to Onboarding
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      // No user, but finished onboarding, go to Login
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  void _showDeviceErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.security, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Text(
              'Device Access Denied',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your account is already active on another device.',
              style: GoogleFonts.lexend(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'For security reasons, UMak App Store allows access from only one device at a time.',
              style: GoogleFonts.lexend(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              'Please sign out from the other device and try again.',
              style: GoogleFonts.lexend(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await AuthService().signOutUser();
              Navigator.of(context).pushReplacementNamed('/auth');
            },
            child: Text(
              'OK',
              style: GoogleFonts.lexend(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cap Logo
              SizedBox(
                width: 128,
                height: 128,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/logo.svg',
                    width: 91.28,
                    height: 73.64,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // App Name
              Text(
                'University of Makati',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: const Color(0xff0a192f),
                  letterSpacing: -0.6,
                  height: 32 / 24, // 1.333
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'App Store',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: const Color(0xcc0a192f), // 0.8 opacity of 0a192f
                  height: 28 / 18, // 1.555
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
