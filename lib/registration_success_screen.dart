import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Spacer to push content exactly to the middle as per Figma empty rectangle above
              const Spacer(flex: 2),

              // Center Content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Icon with concentric rings
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Ring (50% Opacity #e8f8ed)
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xffe8f8ed).withValues(alpha: 0.5),
                          ),
                        ),
                        // Middle Ring (#dcfce7)
                        Container(
                          width: 128,
                          height: 128,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xffdcfce7),
                          ),
                        ),
                        // Core Ring (#34c759)
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xff34c759),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33bbf7d0), // derived from #bbf7d0 w/ opacity
                                blurRadius: 15,
                                spreadRadius: -3,
                                offset: Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Color(0x33bbf7d0),
                                blurRadius: 6,
                                spreadRadius: -4,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Success Title
                  Text(
                    'Success!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff0a2540),
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 14),
                  
                  // Success Subtitle
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Text(
                      'Your account has been\nsuccessfully created. Welcome\nto UMak!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff64748b),
                        height: 1.625, // 29.25/18
                      ),
                    ),
                  ),
                ],
              ),

              // Spacer to push center content up and leave room for bottom button
              const Spacer(flex: 3),

              // Bottom Get Started Button
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60, // ~16px padding on top/bottom with 28px text = 60px
                  child: ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('hasCreatedAccount', true);
                      if (!context.mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0a2540),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0x330a2540),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
