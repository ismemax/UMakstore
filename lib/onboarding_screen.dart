import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  // Image Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 442),
                      child: AspectRatio(
                        aspectRatio: 4 / 5,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Backdrop blurred effect
                            Container(
                              width: 288,
                              height: 288,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xffeff6ff),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xffeff6ff).withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 30,
                                  ),
                                ],
                              ),
                            ),
                            // Image with rounded corners
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  child: Image.asset('assets/building.png'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Text and Buttons Section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Spacer(),
                          // Title
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(text: 'Your Gateway to\n'),
                                TextSpan(
                                  text: 'UMak Apps',
                                  style: TextStyle(color: const Color(0xff2094f3)), // brand blue
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              height: 35 / 28,
                              color: const Color(0xff0f172a),
                              letterSpacing: -0.7,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Subtitle
                          Text(
                            'Discover, download, and manage your\nuniversity tools in one place.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              height: 26 / 16,
                              color: const Color(0xff64748b),
                            ),
                          ),
                          const Spacer(flex: 2),

                          // Buttons
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2094f3),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: const Color(0xffbfdbfe),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Create Account',
                                style: GoogleFonts.lexend(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                  letterSpacing: 0.425,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xff2094f3), width: 2),
                                foregroundColor: const Color(0xff2094f3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Sign In',
                                style: GoogleFonts.lexend(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                  letterSpacing: 0.425,
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Terms and Privacy
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(text: 'By continuing, you agree to our '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: const TextStyle(
                                    color: Color(0xff2094f3),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const TextSpan(text: ' and\n'),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                    color: Color(0xff2094f3),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              height: 19.5 / 12,
                              color: const Color(0xff94a3b8),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
