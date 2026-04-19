import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'confirm_reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isCodeSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
                color: colorScheme.primary.withValues(alpha: 0.1),
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
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.restore_page_outlined,
                                      color: colorScheme.primary,
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
                                    color: colorScheme.primary,
                                    border: Border.all(
                                      color: colorScheme.surface,
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
                          'Forgot Password',
                          style: GoogleFonts.lexend(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.8,
                            height: 40 / 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Description
                        Text(
                          'Don\'t worry, it happens. Please enter your UMak Email address to receive a verification code.',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Input Field
                        TextFormField(
                          controller: _emailController,
                          enabled: !_isCodeSent,
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText: 'EMAIL ADDRESS',
                            labelStyle: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                              letterSpacing: 0.3,
                            ),
                            hintText: 'e.g. name@umak.edu.ph',
                            hintStyle: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.mail_outline,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.primary),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
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
                              color: colorScheme.onSurface,
                              letterSpacing: 4,
                            ),
                            decoration: InputDecoration(
                              labelText: 'VERIFICATION CODE',
                              labelStyle: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                                letterSpacing: 0.3,
                              ),
                              hintText: 'Enter 6-digit code',
                              hintStyle: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                              prefixIcon: Icon(
                                Icons.lock_open_outlined,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.primary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(() => _isCodeSent = false);
                                      _codeController.clear();
                                      _emailController.clear();
                                    },
                              child: Text(
                                'Use Different Email',
                                style: GoogleFonts.lexend(
                                  fontSize: 13,
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
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
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    final email = _emailController.text;
                                    if (email.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please enter your email',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() => _isLoading = true);
                                    try {
                                      // Use the standard OTP sender
                                      await AuthService()
                                          .sendVerificationCode(email);
                                      if (mounted) {
                                        setState(() {
                                          _isCodeSent = true;
                                        });
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to send code: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() => _isLoading = false);
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            colorScheme.onPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text('Sending...'),
                                    ],
                                  )
                                : Text(
                                    'Send Verification Code',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                          ),
                        ),
                        if (_isCodeSent) ...[
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      final email = _emailController.text;
                                      final code = _codeController.text;
                                      if (code.length < 6) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please enter the 6-digit code',
                                            ),
                                          ),
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
                                              builder: (_) =>
                                                  ConfirmResetPasswordScreen(
                                                    email: email,
                                                    code: code,
                                                  ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Verification failed: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      } finally {
                                        if (mounted)
                                          setState(() => _isLoading = false);
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
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _isCodeSent
                                        ? 'Verify & Continue'
                                        : 'Send Recovery Code',
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
