import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewSubmittedScreen extends StatelessWidget {
  const ReviewSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Illustration
              Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative outer circles
                  Container(
                    width: 144,
                    height: 144,
                    decoration: BoxDecoration(
                      color: const Color(0xff22c55e).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xff22c55e).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Main check circle
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xff22c55e),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff22c55e).withValues(alpha: 0.3),
                          blurRadius: 25,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
                  ),
                  // Small decorative stars
                  Positioned(
                    top: 0,
                    right: 0,
                    child: const Icon(Icons.star_rounded, color: Color(0xffffc107), size: 24),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    child: const Icon(Icons.star_rounded, color: Color(0xffffc107), size: 16),
                  ),
                  Positioned(
                    bottom: 40,
                    right: -10,
                    child: const Icon(Icons.star_rounded, color: Color(0xffffc107), size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              // Text Content
              Text(
                'Review Submitted!',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff0a1929),
                  letterSpacing: -0.75,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Thank you for your feedback!\nYour review helps others make\nbetter choices.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff0a1929).withValues(alpha: 0.7),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 48),
              // App Summary Card
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xfff8fafc),
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
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xff0a1f35),
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/umak_logo.png'), // Fallback or placeholder
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UMak Portal',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff0a1929),
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return const Icon(Icons.star_rounded, size: 13, color: Color(0xffffc107));
                            }),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xff22c55e).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Color(0xff22c55e), size: 16),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Action Buttons
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xff0a1929),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff0a1929).withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context); // Go back to App Details
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Back to App Details',
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(
                  'Go to Home',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff0a1929).withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
