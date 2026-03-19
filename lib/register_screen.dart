import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'verification_screen.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff00205b)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Logo Container
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xfff1f5f9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        'assets/logo.png', // Reusing the logo asset
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Title
                    Text(
                      'Create Account',
                      style: GoogleFonts.lexend(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff00205b),
                        letterSpacing: -0.75,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      'Enter your university email to get\nstarted.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff64748b),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Email Field Label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                        child: Text(
                          'Email Address',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff334155),
                          ),
                        ),
                      ),
                    ),
                    
                    // Email Input
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'student@umak.edu.ph',
                        hintStyle: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff94a3b8),
                        ),
                        prefixIcon: const Icon(
                          Icons.mail_outline_rounded,
                          color: Color(0xff94a3b8),
                          size: 20,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 17,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xffe2e8f0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xffe2e8f0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xff0056d2), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 24),

                    // Removed Password Field
                    const SizedBox(height: 32),
                    
                    // Send Code Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () async {
                          final email = _emailController.text;
                          
                          if (email.isEmpty || !email.endsWith('@umak.edu.ph')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid UMak email')),
                            );
                            return;
                          }

                          setState(() => _isLoading = true);
                          try {
                            // CHECK IF EMAIL ALREADY EXISTS
                            final exists = await AuthService().isEmailRegistered(email);
                            if (exists && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('This email is already registered. Please log in instead.')),
                              );
                              setState(() => _isLoading = false);
                              return;
                            }

                            await AuthService().sendVerificationCode(email);
                            if (!mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VerificationScreen(email: email),
                              ),
                            );
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to send code: $e')),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0056d2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _isLoading 
                              ? const SizedBox(
                                  height: 20, 
                                  width: 20, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                )
                              : Text(
                                  'Send Verification Code',
                                  style: GoogleFonts.lexend(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            const SizedBox(width: 8),
                            if (!_isLoading) const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Divider
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Color(0xffe2e8f0), thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'OR',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff94a3b8),
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Color(0xffe2e8f0), thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Google Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () async {
                          setState(() => _isLoading = true);
                          try {
                            final user = await AuthService().signInWithGoogle();
                            if (!mounted) return;
                            if (user != null) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Google Sign-In failed: $e')),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xffe2e8f0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: const Color(0xff334155),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Placeholder for Google Icon
                            const Icon(Icons.g_mobiledata, size: 28), // Using a material icon as fallback
                            const SizedBox(width: 12),
                            Text(
                              'Continue with Google',
                              style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Footer
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'By continuing, you agree to our '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: const Color(0xff0056d2),
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xff0056d2).withValues(alpha: 0.3), // 0.3 opacity blue as per figma
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: const Color(0xff0056d2),
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xff0056d2).withValues(alpha: 0.3),
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff94a3b8),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
