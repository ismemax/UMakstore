import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../login_screen.dart';

class SignOutDialog extends StatelessWidget {
  const SignOutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xffe0e7ff),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.logout_rounded,
                  color: Color(0xff1e3a8a),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            render_text(
              'Sign out?',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0a1929),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              "You'll need to sign in again to access the app store.",
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: const Color(0xff1e3a5f).withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  await AuthService().signOutUser();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffef4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Sign Out',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xff1e3a5f),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget render_text(
    String text, {
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.lexend(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: -0.5,
      ),
    );
  }
}
