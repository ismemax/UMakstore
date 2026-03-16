import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reset_link_sent_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _idEmailController = TextEditingController();

  @override
  void dispose() {
    _idEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff0a192f)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xff64748b)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background Blur Effect
          Positioned(
            right: -80,
            top: -80,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xffeff6ff).withValues(alpha: 0.5),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Top Icon
                        SizedBox(
                          width: 68,
                          height: 68,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                bottom: 0,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffeff6ff),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.restore_page_outlined, // Fallback icon
                                      color: Color(0xff0a192f),
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xff0a192f),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title
                        Text(
                          'Forgot Password?',
                          style: GoogleFonts.lexend(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff0a192f),
                            letterSpacing: -0.8,
                            height: 40 / 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Description
                        Text(
                          'Don\'t worry, it happens. Please enter the Student ID or UMak Email associated with your account to receive instructions.',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xff172a45),
                            height: 26 / 16,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Input Field
                        TextFormField(
                          controller: _idEmailController,
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            color: const Color(0xff0a192f),
                          ),
                          decoration: InputDecoration(
                            labelText: 'STUDENT ID / EMAIL ADDRESS',
                            labelStyle: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xff0a192f),
                              letterSpacing: 0.3,
                            ),
                            hintText: 'e.g. k12345678 or name@umak.edu.ph',
                            hintStyle: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xff9ca3af),
                            ),
                            prefixIcon: const Icon(Icons.mail_outline, color: Color(0xff6b7280)),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            floatingLabelStyle: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xff0a192f),
                              letterSpacing: 0.3,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xffd1d5db)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xff2094f3)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ResetLinkSentScreen(
                                    email: _idEmailController.text.isNotEmpty 
                                        ? _idEmailController.text 
                                        : 'user@umak.edu.ph',
                                  ),
                                ),
                              );
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
                              'Send Reset Link',
                              style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Remember your password? ',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xff6b7280),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Log in',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff2094f3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
