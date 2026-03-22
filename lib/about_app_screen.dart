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
                'About This App',
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
              'The official UMak Portal app brings your university life directly to your fingertips. Designed specifically for students, faculty, and staff, this application serves as a centralized hub for all your academic needs.',
            ),
            const SizedBox(height: 16),
            _buildText(
              "Experience a seamless mobile interface that allows you to manage your academic journey with ease. The app integrates directly with the university's main database ensuring that all data presented is real-time and accurate.",
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Key Features', fontSize: 18),
            const SizedBox(height: 16),
            _buildBulletItem(
              'Real-time Grades:',
              'Check your latest grades as soon as they are posted by your professors. View a detailed breakdown of your academic performance across all semesters.',
            ),
            _buildBulletItem(
              'Smart Schedule:',
              'View your daily class schedule with room assignments, instructor details, and time slots. The smart view highlights your current and upcoming classes.',
            ),
            _buildBulletItem(
              'Campus News & Announcements:',
              'Receive real-time push notifications for important campus announcements, class suspensions, and university events.',
            ),
            _buildBulletItem(
              'Student Profile:',
              'Access your digital ID and student information anytime. Update your contact details directly through the app.',
            ),
            _buildBulletItem(
              'Library Access:',
              'Search for books, check availability, and view your borrowed history and due dates.',
            ),
            const SizedBox(height: 24),
            _buildText(
              'Whether you are a freshman navigating the campus for the first time or a graduating senior tracking your final requirements, the UMak Portal is your essential companion for a successful academic year.',
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
            _buildInfoRow('Size', '45.2 MB'),
            _buildInfoRow('Category', 'Education'),
            _buildInfoRow('Compatibility', 'iOS 14.0 or later'),
            _buildInfoRow('Languages', 'English'),
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
              'Version 2.4.1',
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
                    'UPDATED OCT 24, 2023',
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
                "We're constantly improving the app to make your experience better! In this update:",
              ),
              const SizedBox(height: 16),
              _buildUpdateItem(
                'New Dark Mode Support:',
                "The app now fully respects your system's dark mode settings for comfortable viewing at night.",
              ),
              _buildUpdateItem(
                'Schedule Widget:',
                'Added a home screen widget so you can see your next class without opening the app.',
              ),
              _buildUpdateItem(
                'Performance Improvements:',
                'Faster loading times for the grades module and fixed a bug where notifications were sometimes delayed.',
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
