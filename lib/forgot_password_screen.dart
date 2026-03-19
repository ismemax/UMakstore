import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'reset_link_sent_screen.dart';
import 'confirm_reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _idEmailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isCodeSent = false;

  @override
  void dispose() {
    _idEmailController.dispose();
    _codeController.dispose();
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
                          enabled: !_isCodeSent,
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xffd1d5db)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xff2094f3)),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xffe5e7eb)),
                            ),
                          ),
                        ),
                        if (_isCodeSent) ...[
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              color: const Color(0xff0a192f),
                              letterSpacing: 4,
                            ),
                            decoration: InputDecoration(
                              labelText: 'VERIFICATION CODE',
                              labelStyle: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: const Color(0xff0a192f),
                                letterSpacing: 0.3,
                              ),
                              hintText: '      ••••••',
                              hintStyle: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: const Color(0xff9ca3af),
                                letterSpacing: 4,
                              ),
                              prefixIcon: const Icon(Icons.lock_open_outlined, color: Color(0xff6b7280)),
                              floatingLabelBehavior: FloatingLabelBehavior.always,
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
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _isLoading ? null : () {
                                setState(() => _isCodeSent = false);
                                _codeController.clear();
                              },
                              child: Text(
                                'Change Email',
                                style: GoogleFonts.lexend(
                                  fontSize: 13,
                                  color: const Color(0xff2094f3),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        // Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () async {
                              final email = _idEmailController.text;
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter your email')),
                                );
                                return;
                              }

                              if (!_isCodeSent) {
                                // STEP 1: SEND CODE
                                setState(() => _isLoading = true);
                                try {
                                  // Use the standard OTP sender
                                  await AuthService().sendVerificationCode(email);
                                  if (mounted) {
                                    setState(() {
                                      _isCodeSent = true;
                                      _isLoading = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Verification code sent!')),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              } else {
                                // STEP 2: VERIFY AND PROCEED
                                final code = _codeController.text;
                                if (code.length < 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter the 6-digit code')),
                                  );
                                  return;
                                }

                                setState(() => _isLoading = true);
                                try {
                                  await AuthService().confirmUser(
                                    email: email,
                                    confirmationCode: code,
                                  );
                                  if (mounted) {
                                    // Success! Now go to the Reset Password Screen
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ConfirmResetPasswordScreen(
                                          email: email,
                                          code: code,
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Verification failed: $e')),
                                    );
                                  }
                                } finally {
                                  if (mounted) setState(() => _isLoading = false);
                                }
                              }
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
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    _isCodeSent ? 'Verify & Continue' : 'Send Recovery Code',
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
