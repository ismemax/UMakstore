import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manage_apps_screen.dart';
import 'account_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildSectionTitle('ACCOUNT'),
                  const SizedBox(height: 8),
                  _buildListCard([
                    _buildListItem(
                      Icons.manage_accounts_outlined,
                      'Account Settings',
                      hasBorder: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                        );
                      },
                    ),
                    _buildListItem(
                      Icons.apps_rounded,
                      'Manage Apps & Device',
                      hasBorder: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManageAppsScreen()),
                        );
                      },
                    ),
                    _buildListItem(Icons.notifications_none_rounded, 'Notifications', hasBorder: true, hasRedDot: true),
                    _buildListItem(Icons.bookmark_border_rounded, 'Bookmarks', hasBorder: true),
                    _buildListItem(Icons.payments_outlined, 'Payments', hasBorder: false),
                  ]),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('PREFERENCES'),
                  const SizedBox(height: 8),
                  _buildListCard([
                    _buildListItem(Icons.settings_outlined, 'Settings', hasBorder: false),
                  ]),

                  const SizedBox(height: 24),
                  _buildSectionTitle('SUPPORT'),
                  const SizedBox(height: 8),
                  _buildListCard([
                    _buildListItem(Icons.help_outline_rounded, 'Help & Feedback', hasBorder: true),
                    _buildListItem(Icons.info_outline_rounded, 'About', hasBorder: false),
                  ]),

                  const SizedBox(height: 32),
                  _buildSignOutButton(),

                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Version 1.0.2 • Build 20231025',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        color: const Color(0xff94a3b8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xffdbeafe),
            Colors.white,
          ],
          stops: [0.0, 1.0],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 64),
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xffe2e8f0),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const ClipOval(
                  child: Icon(Icons.person, size: 60, color: Color(0xff94a3b8)),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.camera_alt_outlined, size: 18, color: Color(0xff2094f3)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Juan Dela Cruz',
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0f172a),
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ID: 2023-10293',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xff334155),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xff0f172a).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: const Color(0xff0f172a).withValues(alpha: 0.1)),
            ),
            child: Text(
              'College of Computer Science',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xff0f172a),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'BS Application Development',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xff334155),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: const Color(0xff0f172a),
          letterSpacing: 0.7,
        ),
      ),
    );
  }

  Widget _buildListCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe2e8f0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListItem(IconData icon, String title, {bool hasBorder = false, bool hasRedDot = false, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        border: hasBorder
            ? const Border(bottom: BorderSide(color: Color(0xfff1f5f9), width: 1))
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xfff1f5f9)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(icon, color: const Color(0xff0f172a), size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff0f172a),
                  ),
                ),
              ),
              if (hasRedDot)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xffef4444),
                    shape: BoxShape.circle,
                  ),
                ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xff94a3b8), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: const Color(0xfffee2e2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Color(0xff991b1b), size: 20),
            const SizedBox(width: 8),
            Text(
              'Sign Out',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xff991b1b),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
