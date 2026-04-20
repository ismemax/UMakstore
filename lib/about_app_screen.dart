import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: AppBar(
              backgroundColor: Colors.white.withValues(alpha: 0.95),
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xff2094f3),
                  size: 32,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'About UMak App Store',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff0f172a),
                ),
              ),
              shape: const Border(
                bottom: BorderSide(color: Color(0xfff1f5f9), width: 1),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 80 + 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Description'),
            const SizedBox(height: 16),
            _buildText(
              'The UMak App Store is your official gateway to discovering and downloading applications developed by the University of Makati community. Designed specifically for students, faculty, and staff, this platform showcases innovative apps created within our university.',
            ),
            const SizedBox(height: 16),
            _buildText(
              "Experience a curated collection of educational tools, productivity apps, and student-developed projects. The platform provides a secure environment to explore, download, and review applications that enhance your academic and campus life.",
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Key Features', fontSize: 18),
            const SizedBox(height: 16),
            _buildBulletItem(
              'App Discovery:',
              'Browse through a curated collection of apps developed by UMak students and faculty. Discover tools that enhance your learning experience.',
            ),
            _buildBulletItem(
              'Secure Downloads:',
              'All apps are verified and scanned for security. Download with confidence knowing all applications meet university standards.',
            ),
            _buildBulletItem(
              'Developer Portal:',
              'Submit your own apps to the store. Track downloads, read reviews, and manage your app portfolio.',
            ),
            _buildBulletItem(
              'Reviews & Ratings:',
              'Read authentic reviews from fellow students and faculty. Rate apps to help others make informed decisions.',
            ),
            _buildBulletItem(
              'Bookmarks & Favorites:',
              'Save your favorite apps for quick access. Create a personalized collection of go-to applications.',
            ),
            const SizedBox(height: 24),
            _buildText(
              'Whether you are looking for productivity tools, educational apps, or innovative student projects, UMak App Store is your destination for discovering quality applications that enhance your university experience.',
            ),
            const SizedBox(height: 40),
            const Divider(color: Color(0xfff1f5f9), height: 1),
            const SizedBox(height: 32),
            _buildWhatsNewSection(),
            const SizedBox(height: 40),
            const Divider(color: Color(0xfff1f5f9), height: 1),
            const SizedBox(height: 32),
            _buildSectionTitle('App Information', fontSize: 18),
            const SizedBox(height: 16),
            _buildInfoRow('Provider', 'University of Makati'),
            _buildInfoRow('Size', '25.8 MB'),
            _buildInfoRow('Category', 'App Store'),
            _buildInfoRow('Compatibility', 'Android 5.0 or later'),
            _buildInfoRow('Languages', 'English, Filipino'),
            _buildInfoRow('Age Rating', '4+', isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {double fontSize = 24}) {
    return Text(
      title,
      style: GoogleFonts.lexend(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: const Color(0xff1e293b),
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: GoogleFonts.lexend(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xff1e293b),
        height: 1.6,
      ),
    );
  }

  Widget _buildBulletItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.lexend(
                fontSize: 14,
                height: 1.6,
                color: const Color(0xff1e293b),
              ),
              children: [
                TextSpan(
                  text: title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' $description'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsNewSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle("What's New", fontSize: 20),
            Text(
              'Version 1.4.0',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xff2094f3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xfff8fafc),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xfff1f5f9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.history_rounded,
                    size: 14,
                    color: Color(0xff64748b),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'UPDATED APR 20, 2026',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff64748b),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildText(
                "We're constantly improving the app store to make your experience better! In this update:",
              ),
              const SizedBox(height: 16),
              _buildUpdateItem(
                'Feedback & Support:',
                "Launched a robust feedback system with secure storage and an integrated admin dashboard for better student-developer communication.",
              ),
              _buildUpdateItem(
                'Role Management API:',
                'Implemented a secure server-side API for administrative role assignments, ensuring stable and reliable permission handling.',
              ),
              _buildUpdateItem(
                'Readability & UI Polish:',
                'Enhanced visual contrast across all screens and fixed mobile layout regressions for a more premium experience.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Version History',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xff2094f3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: Color(0xff2094f3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  height: 1.5,
                  color: const Color(0xff1e293b),
                ),
                children: [
                  TextSpan(
                    text: title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' $description'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xfff1f5f9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xff64748b),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xff1e293b),
            ),
          ),
        ],
      ),
    );
  }
}
