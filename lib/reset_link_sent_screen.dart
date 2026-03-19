import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'confirm_reset_password_screen.dart';

class ResetLinkSentScreen extends StatelessWidget {
  final String email;

  const ResetLinkSentScreen({
    super.key,
    this.email = 'user@umak.edu.ph',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xff0a1825), size: 20),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xffe2e8f0),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xff2094f3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xffe2e8f0),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        actions: const [
          SizedBox(width: 48), // To balance the center title
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      // Icon Graphic
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Main Background Circle
                            Container(
                              width: 160,
                              height: 160,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xfff0f4f8),
                              ),
                            ),
                            // Mail Icon
                            const Icon(
                              Icons.mail_outline_rounded,
                              size: 72,
                              color: Color(0xff0a1825), // Dark color for the envelope
                            ),
                            // Top Right Blue Dot
                            Positioned(
                              top: 40,
                              right: 32,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xff2094f3),
                                ),
                              ),
                            ),
                            // Bottom Left Light Blue Dot
                            Positioned(
                              bottom: 40,
                              left: 32,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xff93c5fd),
                                ),
                              ),
                            ),
                            // Bottom Right Checkmark Badge
                            Positioned(
                              bottom: 0,
                              right: 20,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xff2094f3),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Title
                      Text(
                        'Check your mail',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff0a1825),
                          letterSpacing: -0.75,
                          height: 36 / 30,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Description
                      Text(
                        'We have sent password recovery\ninstructions to your email address.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff102a43),
                          height: 26 / 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Email Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xfff3f4f6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          email,
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff0f2438),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
              
              // Bottom Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Open email app logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2094f3),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: const Color(0x332094f3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Open Email App',
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ConfirmResetPasswordScreen(email: email),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xff2094f3),
                        side: const BorderSide(color: Color(0xff2094f3)),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Enter Reset Code',
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
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
                        // Back to sign in logic
                        // Pop back to the LoginScreen
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xff0f2438), width: 2),
                        foregroundColor: const Color(0xff0f2438),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Back to Sign In',
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Resend text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive the email? ',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff64748b),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Resend logic
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Click to resend',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff2094f3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
