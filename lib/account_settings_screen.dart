import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'change_password_screen.dart';
import 'widgets/profile_photo_bottom_sheet.dart';
import 'dart:io';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String? _selectedCollege;
  String? _selectedCourse;
  String? _localPhotoPath;

  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _colleges = [
    'College of Arts and Letters',
    'College of Business and Financial Services',
    'College of Computing and Information Sciences',
    'College of Governance and Public Policy',
  ];

  final List<String> _courses = [
    'BS Information Technology',
    'BS Computer Science',
    'BS Business Administration',
    'AB Communication',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final doc = await AuthService().getUserProfile();
      if (doc != null && doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // Try getting local photo path first
        final localPath = await AuthService().getLocalProfilePhotoPath();

        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _middleNameController.text = data['middleName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _selectedCollege = data['college'];
          _selectedCourse = data['course'];
          _localPhotoPath = localPath;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      await AuthService().updateUserProfile({
        'firstName': _firstNameController.text.trim(),
        'middleName': _middleNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'college': _selectedCollege,
        'course': _selectedCourse,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving changes: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
          'Account Settings',
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
          child: Container(color: const Color(0xfff3f4f6), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final result = await showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => const ProfilePhotoBottomSheet(),
                    );

                    if (result == 'REMOVE') {
                      setState(() => _isSaving = true);
                      await AuthService().removeProfilePhotoLocally();
                      setState(() {
                        _localPhotoPath = null;
                        _isSaving = false;
                      });
                    } else if (result is File) {
                      setState(() => _isSaving = true);
                      // Save locally instead of Firebase
                      final newPath = await AuthService()
                          .saveProfilePhotoLocally(result);
                      setState(() {
                        _localPhotoPath = newPath;
                        _isSaving = false;
                      });
                    }
                  },
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              color: const Color(0xfffad9c1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              image:
                                  (_localPhotoPath != null &&
                                      File(_localPhotoPath!).existsSync())
                                  ? DecorationImage(
                                      image: FileImage(File(_localPhotoPath!)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1A000000),
                                  blurRadius: 15,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child:
                                (_localPhotoPath == null ||
                                    !File(_localPhotoPath!).existsSync())
                                ? const Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xff2094f3),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1A000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Change Profile Photo',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff2094f3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
                child: Text(
                  'PERSONAL INFORMATION',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff1a3b5d).withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              _buildEditableField('First Name', _firstNameController),
              const SizedBox(height: 16),
              _buildEditableField('Middle Initial', _middleNameController),
              const SizedBox(height: 16),
              _buildEditableField('Last Name', _lastNameController),
              const SizedBox(height: 16),
              _buildDropdownField(
                'College',
                _selectedCollege,
                _colleges,
                (val) => setState(() => _selectedCollege = val),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Course',
                _selectedCourse,
                _courses,
                (val) => setState(() => _selectedCourse = val),
              ),

              const SizedBox(height: 40),

              // SECURITY Section
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
                child: Text(
                  'SECURITY',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff1a3b5d).withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xfff8fafc),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffe5e7eb)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0D000000),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.restore_rounded,
                              color: Color(0xff1a3b5d),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Change Password',
                              style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff102a43),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xff94a3b8),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Action Buttons
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _isSaving ? null : _saveChanges,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xff2094f3),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x332094f3),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _isSaving
                      ? const Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : Text(
                          'Save Changes',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffe5e7eb)),
                  ),
                  child: Text(
                    'Cancel',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff1a3b5d),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xff1a3b5d),
            ),
          ),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: const Color(0xff102a43),
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, bottom: 0, left: 16, right: 16),
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xff1a3b5d),
            ),
          ),
          DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: Text(
              'Select $label',
              style: GoogleFonts.lexend(
                fontSize: 16,
                color: const Color(0xff94a3b8),
              ),
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xff1a3b5d)),
            underline: const SizedBox(),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    color: const Color(0xff102a43),
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
