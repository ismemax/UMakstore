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
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final userData = snapshot.data?.data() ?? {};
        final firstName = userData['firstName'] ?? '';
        final lastName = userData['lastName'] ?? '';
        final studentId = userData['studentId'] ?? 'ID: NOT SET';
        final college = userData['college'] ?? 'College of Computer Science';
        final course = userData['course'] ?? 'BS Application Development';
        final name = (firstName.isEmpty && lastName.isEmpty)
            ? (_user!.displayName ?? 'User Name')
            : '$firstName $lastName';
        final fullName = userData['fullName'] ?? 'User Name'; // This line is from the snippet, but 'name' is used below. Keeping both for now as per instruction.
        final email = userData['email'] ?? 'user@example.com'; // This line is from the snippet.
        final photoUrl = userData['photoUrl']; // This line is from the snippet.

        return Scaffold(
          backgroundColor: colorScheme.surface,
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
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AccountSettingsScreen(),
                              ),
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
                              MaterialPageRoute(
                                builder: (context) => const ManageAppsScreen(),
                              ),
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
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreen(),
                              ),
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
                              MaterialPageRoute(
                                builder: (context) => const BookmarksScreen(),
                              ),
                            );
                          },
                        ),
                        _buildListItem(
                          Icons.payments_outlined,
                          'Payments',
                          hasBorder: false,
                        ),
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
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
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
                              MaterialPageRoute(
                                builder: (context) =>
                                    const HelpAndFeedbackScreen(),
                              ),
                            );
                          },
                        ),
                        _buildListItem(
                          Icons.info_outline_rounded,
                          'About',
                          hasBorder: false,
                        ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: localPhotoPath != null && File(localPhotoPath).existsSync()
                      ? Image.file(File(localPhotoPath), fit: BoxFit.cover)
                      : Container(
                          color: colorScheme.primary.withOpacity(0.1),
                          child: Icon(Icons.person_rounded, size: 60, color: colorScheme.primary),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
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
              color: colorScheme.onSurface,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ID: $studentId',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              college,
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            course,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface.withValues(alpha: 0.5),
          letterSpacing: 0.7,
        ),
      ),
    );
  }

  Widget _buildListCard(List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListItem(
    IconData icon,
    String title, {
    bool hasBorder = false,
    bool hasRedDot = false,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: hasBorder
            ? Border(
                bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
              )
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
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Center(
                  child: Icon(icon, color: colorScheme.onSurface, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
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
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.black.withValues(alpha: 0.5),
          builder: (context) => const SignOutDialog(),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.errorContainer.withValues(alpha: 0.2) : const Color(0xfffee2e2),
          borderRadius: BorderRadius.circular(12),
          border: isDark ? Border.all(color: colorScheme.error.withValues(alpha: 0.3)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: isDark ? colorScheme.error : const Color(0xff991b1b),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Sign Out',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? colorScheme.error : const Color(0xff991b1b),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
