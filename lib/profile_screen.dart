import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_apps_screen.dart';
import 'account_settings_screen.dart';
import 'notifications_screen.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';
import 'help_and_feedback_screen.dart';
import 'widgets/sign_out_dialog.dart';
import 'services/auth_service.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  String? _localPhotoPath;

  @override
  void initState() {
    super.initState();
    _loadLocalPhoto();
  }

  Future<void> _loadLocalPhoto() async {
    final path = await AuthService().getLocalProfilePhotoPath();
    if (mounted) {
      setState(() {
        _localPhotoPath = path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: Text('No user logged in')));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(_user.uid).snapshots(),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data();
        final firstName = userData?['firstName'] ?? '';
        final lastName = userData?['lastName'] ?? '';
        final studentId = userData?['studentId'] ?? 'ID: NOT SET';
        final college = userData?['college'] ?? 'College of Computer Science';
        final course = userData?['course'] ?? 'BS Application Development';
        final name = (firstName.isEmpty && lastName.isEmpty) 
          ? (_user.displayName ?? 'User Name') 
          : '$firstName $lastName';

        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(name, studentId, college, course, _localPhotoPath),
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
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                            );
                            _loadLocalPhoto();
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
                        _buildListItem(
                          Icons.notifications_none_rounded,
                          'Notifications',
                          hasBorder: true,
                          hasRedDot: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                            );
                          },
                        ),
                        _buildListItem(
                          Icons.bookmark_border_rounded,
                          'Bookmarks',
                          hasBorder: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const BookmarksScreen()),
                            );
                          },
                        ),
                        _buildListItem(Icons.payments_outlined, 'Payments', hasBorder: false),
                      ]),
                      
                      const SizedBox(height: 24),
                      _buildSectionTitle('PREFERENCES'),
                      const SizedBox(height: 8),
                      _buildListCard([
                        _buildListItem(
                          Icons.settings_outlined,
                          'Settings',
                          hasBorder: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          },
                        ),
                      ]),

                      const SizedBox(height: 24),
                      _buildSectionTitle('SUPPORT'),
                      const SizedBox(height: 8),
                      _buildListCard([
                        _buildListItem(
                          Icons.help_outline_rounded,
                          'Help & Feedback',
                          hasBorder: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HelpAndFeedbackScreen()),
                            );
                          },
                        ),
                        _buildListItem(Icons.info_outline_rounded, 'About', hasBorder: false),
                      ]),

                      const SizedBox(height: 32),
                      _buildSignOutButton(context),

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
      },
    );
  }

  Widget _buildHeader(String name, String studentId, String college, String course, String? localPhotoPath) {
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
                  image: (localPhotoPath != null && File(localPhotoPath).existsSync())
                      ? DecorationImage(
                          image: FileImage(File(localPhotoPath)),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: (localPhotoPath == null || !File(localPhotoPath).existsSync())
                    ? const ClipOval(
                        child: Icon(Icons.person, size: 60, color: Color(0xff94a3b8)),
                      )
                    : null,
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
            name,
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0f172a),
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ID: $studentId',
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
              college,
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xff0f172a),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            course,
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

  Widget _buildSignOutButton(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: const Color(0xfff5f7f8).withValues(alpha: 0.9),
          builder: (context) => const SignOutDialog(),
        );
      },
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
