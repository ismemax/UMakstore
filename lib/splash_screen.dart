import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';

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
      // User is authenticated, go to Home
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
