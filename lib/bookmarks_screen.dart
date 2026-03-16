import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xff1a3b5d)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Bookmarks',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xff1a3b5d),
            letterSpacing: -0.45,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xfff3f4f6),
            height: 1.0,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: [
          Text(
            'SAVED APPS',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xff94a3b8),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildBookmarkItem(
            appName: 'Canvas Student',
            developer: 'Instructure',
            rating: '4.8',
            category: 'Education',
            iconColor: const Color(0xffef4444), // Example fallback color
            iconBgColor: const Color(0xfffee2e2),
          ),
          const SizedBox(height: 12),
          _buildBookmarkItem(
            appName: 'UMak Portal Mobile',
            developer: 'UMak CCIS',
            rating: '4.9',
            category: 'Productivity',
            iconColor: const Color(0xff2094f3),
            iconBgColor: const Color(0xffdbeafe),
          ),
          const SizedBox(height: 12),
          _buildBookmarkItem(
            appName: 'Google Classroom',
            developer: 'Google LLC',
            rating: '4.7',
            category: 'Education',
            iconColor: const Color(0xff10b981),
            iconBgColor: const Color(0xffd1fae5),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkItem({
    required String appName,
    required String developer,
    required String rating,
    required String category,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe2e8f0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Icon Placeholder
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xfff1f5f9)),
            ),
            child: Center(
              child: Icon(Icons.widgets_rounded, color: iconColor, size: 32),
            ),
          ),
          const SizedBox(width: 16),
          // App Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        appName,
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff1a3b5d),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.bookmark_rounded,
                      color: const Color(0xff2094f3), // Primary blue for active bookmark
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  developer,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    color: const Color(0xff64748b),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      rating,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff64748b),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star_rounded, color: Color(0xfffbbf24), size: 14),
                    const SizedBox(width: 12),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xffcbd5e1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      category,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        color: const Color(0xff64748b),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
