import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordChangedSuccessScreen extends StatelessWidget {
  const PasswordChangedSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Animated-like Checkmark Circle with decorative blur/rings
              Stack(
                alignment: Alignment.center,
                children: [
                   Container(
                    width: 216,
                    height: 216,
                    decoration: BoxDecoration(
                      color: const Color(0xff2094f3).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 176,
                    height: 176,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xffdbeafe), width: 1.5),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xff00205b).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xff2094f3).withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Main solid circle
                  Container(
                    width: 144,
                    height: 144,
                    decoration: const BoxDecoration(
                      color: Color(0xff2094f3),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x80bfdbfe),
                          blurRadius: 25,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 72,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              Text(
                'Password Security\nUpdated',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff00205b),
                  height: 1.3,
                  letterSpacing: -0.6,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Your password has been successfully changed\nand verified via OTP. Your account is now\nsecure.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: const Color(0xff00205b),
                  height: 1.6,
                ),
              ),
              
              const Spacer(),
              
              // Return to Profile Button
              InkWell(
                onTap: () {
                  // Pop everything to return to the root screen (which should be the home screen displaying profile tab)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xff00205b),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 15,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Return to Profile',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      )
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
