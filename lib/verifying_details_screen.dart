import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'registration_success_screen.dart';

class VerifyingDetailsScreen extends StatefulWidget {
  const VerifyingDetailsScreen({super.key});

  @override
  State<VerifyingDetailsScreen> createState() => _VerifyingDetailsScreenState();
}

class _VerifyingDetailsScreenState extends State<VerifyingDetailsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    // Simulate network delay and navigation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RegistrationSuccessScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Loading Animation & U Logo
              SizedBox(
                width: 128,
                height: 128,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Spinning Ring
                    SizedBox(
                      width: 128,
                      height: 128,
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff0a2540)),
                        backgroundColor: const Color(0xffe2e8f0),
                        strokeWidth: 4,
                      ),
                    ),
                    
                    // Central 'U' Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xff0a2540),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x330a2540),
                            blurRadius: 15,
                            spreadRadius: -3,
                            offset: Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Color(0x330a2540),
                            blurRadius: 6,
                            spreadRadius: -4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'U',
                          style: GoogleFonts.lexend(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -1.8,
                            height: 1.1, // Adjust vertical alignment
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Text Content
              Text(
                'Verifying your details...',
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff0a2540),
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Please wait a moment',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff94a3b8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
