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
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Update All',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xff0a2342),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              'AVAILABLE NOW (4)',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xff64748b),
                letterSpacing: 0.6,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildUpdateItem(
                  title: 'UMak Messenger',
                  versionSize: 'Version 2.4.1 • 45.2 MB',
                  description: 'We\'ve added crystal-clear HD video calling and squashed those pesky bugs...',
                  iconBgColor: const Color(0xffe2b48e),
                  iconData: Icons.chat_bubble_outline_rounded,
                ),
                _buildUpdateItem(
                  title: 'Student Portal',
                  versionSize: 'Version 1.10.0 • 120 MB',
                  description: 'Major redesign for the course enrollment page. Added dark mode support and...',
                  iconBgColor: Colors.white,
                  iconData: Icons.account_circle_outlined,
                  iconColor: const Color(0xff0f172a),
                ),
                _buildUpdateItem(
                  title: 'UMak Library',
                  versionSize: 'Version 3.2.5 • 32.8 MB',
                  description: 'Improved book reservation system and fixed checkout errors. You can now sca...',
                  iconBgColor: const Color(0xff22726d),
                  iconData: Icons.menu_book_rounded,
                ),
                _buildUpdateItem(
                  title: 'Campus Maps',
                  versionSize: 'Version 5.0.2 • 88.4 MB',
                  description: 'New offline map support for main campus buildings. Updated paths for th...',
                  iconBgColor: const Color(0xffe9eee9),
                  iconData: Icons.map_rounded,
                  iconColor: const Color(0xff86b389),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateItem({
    required String title,
    required String versionSize,
    required String description,
    required Color iconBgColor,
    required IconData iconData,
    Color iconColor = Colors.white,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xfff1f5f9), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffe2e8f0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Icon(iconData, color: iconColor, size: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff0a2342),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            versionSize,
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff64748b),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(9999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xff2094f3),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          'Update',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: const Color(0xff475569),
                    height: 1.4,
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
