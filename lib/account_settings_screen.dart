import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'change_password_screen.dart';
import 'widgets/profile_photo_bottom_sheet.dart';
import 'services/language_service.dart';
import 'dart:io';
import 'dart:convert';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final LanguageService _languageService = LanguageService();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String? _selectedCollege;
  String? _selectedCourse;
  String? _photoBase64;

  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _colleges = [
    'CBFS - College of Business and Financial Sciences',
    'CITE - College of Innovative Teacher Education',
    'CTHM - College of Tourism and Hospitality Management',
    'SOL - School of Law',
    'CCIS - College of Computer and Information Science',
    'CCAPS - College of Continuing, Advanced and Professional Studies',
    'CET - College of Engineering and Technology',
    'IAD - Institute of Accountancy',
    'IOA - Institute of Architecture',
    'CHK - College of Human Kinetics',
    'IDEM - Institute of Design and Engineering Management',
    'ISW - Institute of Social Work',
    'IOP - Institute of Pharmacy',
    'ITEST - Institute of Technology and Entrepreneurship Studies',
    'IOPsy - Institute of Psychology',
    'IIHS - Institute of Integrated Health Sciences',
    'CGPP - College of Governance and Public Policy',
    'CCSE - College of Computing and Software Engineering',
    'ION - Institute of Nursing',
  ];

  final List<String> _courses = [
    'BS Accountancy',
    'BS Business Administration',
    'BS Management Accounting',
    'BS Real Estate Management',
    'BS Tourism Management',
    'BS Hospitality Management',
    'Bachelor of Elementary Education',
    'Bachelor of Secondary Education',
    'Juris Doctor',
    'BS Computer Science',
    'BS Information Technology',
    'BS Information Systems',
    'BS Computer Engineering',
    'BS Electronics Engineering',
    'BS Civil Engineering',
    'BS Architecture',
    'BS Psychology',
    'BS Social Work',
    'BS Pharmacy',
    'BS Nursing',
    'BS Physical Therapy',
    'BS Medical Technology',
    'BS Public Administration',
    'BS Development Management',
    'BS Applied Mathematics',
    'BS Statistics',
    'BS Biology',
    'BS Chemistry',
    'BS Physics',
    'AB English',
    'AB Filipino',
    'AB Communication',
    'AB History',
    'AB Political Science',
    'AB Sociology',
    'BS Entrepreneurship',
    'BS Tourism Technology',
    'BS Hospitality Technology',
  ];

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_updateUI);
    _loadUserData();
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  String? _migrateCollegeName(String? oldCollege) {
    if (oldCollege == null) return null;
    
    // Map old college names to new ones
    final Map<String, String?> collegeMigration = {
      'College of Arts and Letters': null, // Removed
      'College of Business and Financial Services': 'CBFS - College of Business and Financial Sciences',
      'College of Computing and Information Sciences': 'CCIS - College of Computer and Information Science',
      'College of Governance and Public Policy': 'CGPP - College of Governance and Public Policy',
      'College of Computer Science': 'CCIS - College of Computer and Information Science', // Old name
    };
    
    final migratedCollege = collegeMigration[oldCollege] ?? oldCollege;
    
    // Check if the migrated college exists in the current list
    if (_colleges.contains(migratedCollege)) {
      return migratedCollege;
    }
    
    // If not found, return null to reset selection
    return null;
  }

  Future<void> _loadUserData() async {
    try {
      final doc = await AuthService().getUserProfile();
      if (doc != null && doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _middleNameController.text = data['middleName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _selectedCollege = _migrateCollegeName(data['college']);
          _selectedCourse = _courses.contains(data['course']) ? data['course'] : null;
          _photoBase64 = data['photoBase64'];
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
    _languageService.removeListener(_updateUI);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _languageService.translate('account_settings'),
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            letterSpacing: -0.45,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1.0),
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
                      await AuthService().removeProfilePhotoBase64();
                      setState(() {
                        _photoBase64 = null;
                        _isSaving = false;
                      });
                    } else if (result is File) {
                      setState(() => _isSaving = true);
                      // Save as Base64 in Firestore
                      await AuthService().updateProfilePhotoBase64(result);
                      
                      // For immediate UI update, we can convert to base64 here or just reload
                      final bytes = await result.readAsBytes();
                      setState(() {
                        _photoBase64 = base64Encode(bytes);
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
                              color: colorScheme.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: colorScheme.surface, width: 4),
                            image: (_photoBase64 != null && _photoBase64!.isNotEmpty)
                                  ? DecorationImage(
                                      image: MemoryImage(base64Decode(_photoBase64!)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: (_photoBase64 == null || _photoBase64!.isEmpty)
                              ? Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 80,
                                    color: colorScheme.onSurface.withValues(alpha: 0.3),
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
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.surface,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
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
                        _languageService.translate('change_photo'),
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.primary,
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
                  _languageService.translate('personal_info'),
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              _buildEditableField(_languageService.translate('first_name'), _firstNameController, colorScheme),
              const SizedBox(height: 16),
              _buildEditableField(_languageService.translate('middle_initial'), _middleNameController, colorScheme),
              const SizedBox(height: 16),
              _buildEditableField(_languageService.translate('last_name'), _lastNameController, colorScheme),
              const SizedBox(height: 16),
              _buildDropdownField(
                _languageService.translate('college_label'),
                _selectedCollege,
                _colleges,
                (val) => setState(() => _selectedCollege = val),
                colorScheme,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                _languageService.translate('course_label'),
                _selectedCourse,
                _courses,
                (val) => setState(() => _selectedCourse = val),
                colorScheme,
              ),

              const SizedBox(height: 40),

              // SECURITY Section
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
                child: Text(
                  _languageService.translate('security'),
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
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
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.restore_rounded,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _languageService.translate('change_password'),
                              style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
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
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
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
                          _languageService.translate('save_changes'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Text(
                    _languageService.translate('cancel'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
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

  Widget _buildEditableField(String label, TextEditingController controller, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: colorScheme.onSurface,
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
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, bottom: 0, left: 16, right: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: colorScheme.surfaceContainerHighest,
            hint: Text(
              'Select $label',
              style: GoogleFonts.lexend(
                fontSize: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
            underline: const SizedBox(),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    color: colorScheme.onSurface,
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
