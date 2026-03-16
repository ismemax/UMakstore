import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Effects
          Positioned(
            left: -96,
            top: -96,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xffeff6ff).withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned(
            right: -96,
            top: MediaQuery.of(context).size.height * 0.5,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xffeff6ff).withValues(alpha: 0.5),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Logo
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        padding: const EdgeInsets.all(1), // for gradient border effect
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0x1a2094f3), // rgba(32,148,243,0.1)
                              Color(0x002094f3),
                            ],
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0x0d2094f3), // rgba(32,148,243,0.05)
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 44,
                              height: 36,
                              child: SvgPicture.asset(
                                'assets/logo.svg', // Fallback to existing asset 
                                fit: BoxFit.contain,
                                // fallback logic in case the asset color doesn't match perfectly, but we'll try to just render the logo
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        height: 36 / 30,
                        color: const Color(0xff0f172a),
                        letterSpacing: -0.75,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to access your campus apps',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                        height: 24 / 16,
                        color: const Color(0xff64748b),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Form
                    Text(
                      'Student ID',
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: const Color(0xff334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _studentIdController,
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: const Color(0xff0f172a),
                      ),
                      decoration: InputDecoration(
                        hintText: 'K12345678',
                        hintStyle: GoogleFonts.lexend(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: const Color(0xff94a3b8),
                        ),
                        prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xff475569)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xffe2e8f0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xff2094f3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Text(
                      'Password',
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: const Color(0xff334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: const Color(0xff0f172a),
                      ),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: GoogleFonts.lexend(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: const Color(0xff94a3b8),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xff475569)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xff94a3b8),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xffe2e8f0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xff2094f3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                side: const BorderSide(color: Color(0xffcbd5e1)),
                                activeColor: const Color(0xff2094f3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remember me',
                              style: GoogleFonts.lexend(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: const Color(0xff475569),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: const Color(0xff2094f3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Simple mock sign in
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('hasLoggedIn', true);
                          
                          if (!context.mounted) return;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
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
                          'Sign In',
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: const Color(0xff64748b),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign up',
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: const Color(0xff2094f3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
