import 'package:flutter/foundation.dart';
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
import 'about_app_screen.dart';
import 'device_management_screen.dart';
import 'role_management_screen.dart';
import 'widgets/sign_out_dialog.dart';
import 'services/auth_service.dart';
import 'services/language_service.dart';
import 'developer_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';
import 'dart:io';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final Function(int)? onTabSelected;
  const ProfileScreen({super.key, this.onTabSelected});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LanguageService _languageService = LanguageService();
  final User? _user = FirebaseAuth.instance.currentUser;
  String? _photoBase64;

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_updateUI);
    _loadProfilePhoto();
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProfilePhoto() async {
    final photo = await AuthService().getBase64ProfilePhoto();
    if (mounted) {
      setState(() {
        _photoBase64 = photo;
      });
    }
  }

  @override
  void dispose() {
    _languageService.removeListener(_updateUI);
    super.dispose();
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
          final isPermissionDenied = snapshot.error.toString().contains('PERMISSION_DENIED');
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPermissionDenied ? Icons.lock_person_rounded : Icons.error_outline_rounded,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPermissionDenied ? _languageService.translate('access_denied') : _languageService.translate('something_wrong'),
                      style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPermissionDenied 
                          ? "Missing Firestore permissions. Check your security rules in the Firebase Console."
                          : 'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: 16),
                    // DIAGNOSTIC INFO
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        'Debug ID: ${_user!.uid}\nPath: users/${_user!.uid}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.firaCode(fontSize: 10, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => AuthService().signOutUser(),
                      icon: const Icon(Icons.logout),
                      label: Text(_languageService.translate('sign_out_reconnect')),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // If the document does not exist, we should provide a way to create it or show a placeholder.
        // This is common for initial Google Sign-In if doc creation was interrupted.
        if (!snapshot.hasData || !snapshot.data!.exists) {
           return Scaffold(
            backgroundColor: colorScheme.surface,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_rounded,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _languageService.translate('profile_not_found'),
                      style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _languageService.translate('profile_not_found_desc'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => AuthService().signOutUser(),
                      child: Text(_languageService.translate('sign_out_try_again')),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final userData = snapshot.data?.data() ?? {};
        final firstName = userData['firstName'] ?? '';
        final lastName = userData['lastName'] ?? '';
        final studentId = userData['studentId'] ?? 'ID: NOT SET';
        final college = userData['college'] ?? 'CCIS - College of Computer and Information Science';
        final course = userData['course'] ?? 'BS Application Development';
        final name = (firstName.isEmpty && lastName.isEmpty)
            ? (_user!.displayName ?? 'User Name')
            : '$firstName $lastName';
        final fullName = userData['fullName'] ?? 'User Name'; // This line is from the snippet, but 'name' is used below. Keeping both for now as per instruction.
        final email = userData['email'] ?? 'user@example.com';
        final photoBase64 = userData['photoBase64'];

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(name, studentId, college, course, photoBase64),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildSectionTitle(_languageService.translate('account')),
                      const SizedBox(height: 8),
                      _buildListCard([
                        _buildListItem(
                          Icons.manage_accounts_outlined,
                          _languageService.translate('account_settings'),
                          hasBorder: true,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AccountSettingsScreen(),
                              ),
                            );
                            _loadProfilePhoto();
                          },
                        ),
                        _buildListItem(
                          Icons.apps_rounded,
                          _languageService.translate('manage_apps'),
                          hasBorder: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageAppsScreen(
                                  onTabSelected: widget.onTabSelected,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildListItem(
                          Icons.bookmark_border_rounded,
                          _languageService.translate('bookmarks'),
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
                          _languageService.translate('payments'),
                          hasBorder: false,
                        ),
                      ]),

                      const SizedBox(height: 24),
                      _buildSectionTitle(_languageService.translate('preferences')),
                      const SizedBox(height: 8),
                      _buildListCard([
                        _buildListItem(
                          Icons.settings_outlined,
                          _languageService.translate('settings'),
                          key: const Key('tile_settings'),
                          hasBorder: userData['role'] == 'developer',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildListItem(
                          Icons.phone_android_outlined,
                          'Device Management',
                          key: const Key('tile_device_management'),
                          hasBorder: userData['role'] == 'developer',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DeviceManagementScreen(),
                              ),
                            );
                          },
                        ),
                        if (userData['role'] == 'admin')
                          _buildListItem(
                            Icons.admin_panel_settings_outlined,
                            'Role Management',
                            key: const Key('tile_role_management'),
                            hasBorder: userData['role'] == 'admin',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RoleManagementScreen(),
                                ),
                              );
                            },
                          ),
                        if (userData['role'] == 'developer')
                          _buildListItem(
                            Icons.dashboard_customize_rounded,
                            _languageService.translate('dev_portal'),
                            hasBorder: userData['role'] == 'admin',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DeveloperDashboardScreen(),
                                ),
                              );
                            },
                          ),
                        if (userData['role'] == 'admin')
                          _buildListItem(
                            Icons.admin_panel_settings_rounded,
                            'Admin Dashboard',
                            hasBorder: false,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminDashboardScreen(),
                                ),
                              );
                            },
                          ),
                      ]),

                      const SizedBox(height: 24),
                      _buildSectionTitle(_languageService.translate('support')),
                      const SizedBox(height: 8),
                      _buildListCard([
                        _buildListItem(
                          Icons.help_outline_rounded,
                          _languageService.translate('help_feedback'),
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
                          _languageService.translate('about'),
                          hasBorder: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutAppScreen(),
                              ),
                            );
                          },
                        ),
                      ]),

                      if (kDebugMode) ...[
                        const SizedBox(height: 32),
                        _buildSectionTitle('DEBUG BYPASS (DEVELOPER ONLY)'),
                        const SizedBox(height: 8),
                        _buildListCard([
                          _buildListItem(
                            Icons.bug_report_rounded,
                            'Switch to Admin Role',
                            hasBorder: true,
                            onTap: () => _bypassRole('admin'),
                          ),
                          _buildListItem(
                            Icons.code_rounded,
                            'Switch to Developer Role',
                            hasBorder: true,
                            onTap: () => _bypassRole('developer'),
                          ),
                          _buildListItem(
                            Icons.person_outline_rounded,
                            'Switch to Student Role',
                            hasBorder: false,
                            onTap: () => _bypassRole('student'),
                          ),
                        ]),
                      ],

                      const SizedBox(height: 48),
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

  Future<void> _bypassRole(String role) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await AuthService().updateCurrentUserRole(role);
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bypass Success: You are now a $role')),
        );
        // Refresh UI
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bypass Failed: $e')),
        );
      }
    }
  }

  Widget _buildHeader(String name, String studentId, String college, String course, String? photoBase64) {
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
                  child: photoBase64 != null && photoBase64.isNotEmpty
                      ? Image.memory(base64Decode(photoBase64), fit: BoxFit.cover)
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
    Key? key,
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
        key: key,
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
              _languageService.translate('sign_out'),
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
