import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdatesScreen extends StatelessWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xff0a2342)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Updates',
          style: GoogleFonts.lexend(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff0a2342),
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 64, color: const Color(0xff22c55e).withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text(
              'All apps are up to date',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xff64748b),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last checked: Just now',
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: const Color(0xff94a3b8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
