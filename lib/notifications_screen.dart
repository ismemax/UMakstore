import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
          'Notifications',
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
          _buildDateHeader('Today'),
          const SizedBox(height: 12),
          _buildNotificationCard(
            title: 'Welcome to UMak App Store!',
            description: 'Your account has been successfully created. Explore the apps now.',
            timeAgo: '2h ago',
            iconData: Icons.celebration_rounded,
            iconColor: const Color(0xff2094f3),
            iconBgColor: const Color(0xff2094f3).withValues(alpha: 0.1),
            isUnread: true,
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            title: 'Security Update',
            description: 'Your password was successfully updated via OTP verification.',
            timeAgo: '5h ago',
            iconData: Icons.shield_rounded,
            iconColor: const Color(0xff10b981),
            iconBgColor: const Color(0xff10b981).withValues(alpha: 0.1),
            isUnread: false,
          ),
          
          const SizedBox(height: 32),
          _buildDateHeader('Yesterday'),
          const SizedBox(height: 12),
          _buildNotificationCard(
            title: 'System Maintenance',
            description: 'The portal will be down for maintenance from 12 AM to 4 AM on Sunday.',
            timeAgo: '1d ago',
            iconData: Icons.construction_rounded,
            iconColor: const Color(0xfffb923c),
            iconBgColor: const Color(0xfffb923c).withValues(alpha: 0.1),
            isUnread: false,
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            title: 'Campus Map Updated',
            description: 'Version 5.0.2 is now available with new offline support paths.',
            timeAgo: '1d ago',
            iconData: Icons.map_rounded,
            iconColor: const Color(0xff8b5cf6),
            iconBgColor: const Color(0xff8b5cf6).withValues(alpha: 0.1),
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xff94a3b8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String description,
    required String timeAgo,
    required IconData iconData,
    required Color iconColor,
    required Color iconBgColor,
    bool isUnread = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xfff8fafc) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? const Color(0xffdbeafe) : const Color(0xffe2e8f0),
          width: isUnread ? 1.5 : 1.0,
        ),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(iconData, color: iconColor, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          color: const Color(0xff1a3b5d),
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(
                          color: Color(0xff2094f3),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    color: const Color(0xff64748b),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  timeAgo,
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff94a3b8),
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
