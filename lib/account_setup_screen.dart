import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'registration_success_screen.dart';

class AccountSetupScreen extends StatefulWidget {
  final String email;
  final String studentId;
  final String lastName;
  final String firstName;
  final String middleName;
  final String college;
  final String course;

  const AccountSetupScreen({
    super.key,
    required this.email,
    required this.studentId,
    required this.lastName,
    required this.firstName,
    required this.middleName,
    required this.college,
    required this.course,
  });

  @override
  State<AccountSetupScreen> createState() => _AccountSetupScreenState();
}

class _AccountSetupScreenState extends State<AccountSetupScreen> {
  @override
  void initState() {
    super.initState();
    _startSetup();
  }

  Future<void> _startSetup() async {
    try {
      // 1. Save profile to Firestore
      await AuthService().saveUserProfile(
        email: widget.email,
        studentId: widget.studentId,
        lastName: widget.lastName,
        firstName: widget.firstName,
        middleName: widget.middleName,
        college: widget.college,
        course: widget.course,
      );

      // 2. Artificial delay for visual "setup" feel as per Figma
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RegistrationSuccessScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to set up account: $e')));
        Navigator.of(context).pop(); // Go back to legal screen to retry
      }
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
              // Rotating Gear/Sync icon placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xfff8fafc),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xfff1f5f9), width: 2),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: Color(0xff0f172a),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Setting up Account',
                style: GoogleFonts.lexend(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff0f172a),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Hang tight while we prepare your university experience in the app.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  color: const Color(0xff64748b),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
