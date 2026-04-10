import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'create_password_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String email;
  const PersonalInfoScreen({super.key, required this.email});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _studentIdController;
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleInitialController =
      TextEditingController();

  String? _selectedCollege;
  String? _selectedCourse;

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

  @override
  void initState() {
    super.initState();
    final studentId = AuthService().extractStudentId(widget.email);
    _studentIdController = TextEditingController(text: studentId);
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleInitialController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Step 3 of 4',
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  _buildProgressBar(true, colorScheme),
                  const SizedBox(width: 8),
                  _buildProgressBar(true, colorScheme),
                  const SizedBox(width: 8),
                  _buildProgressBar(true, colorScheme),
                  const SizedBox(width: 8),
                  _buildProgressBar(false, colorScheme),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      // Title
                      Text(
                        'Personal Information',
                        style: GoogleFonts.lexend(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Please provide your details exactly as they\nappear in your official school records.',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Student ID (Locked/Read-only)
                      _buildLabel('Student ID', colorScheme),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: TextField(
                          controller: _studentIdController,
                          readOnly: true,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'K12345678',
                            hintStyle: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                            suffixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: colorScheme.onSurface.withValues(alpha: 0.4),
                              size: 20,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 17,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Last Name
                      _buildLabel('Last Name', colorScheme),
                      _buildTextField(_lastNameController, 'e.g. Dela Cruz', colorScheme),
                      const SizedBox(height: 20),

                      // First Name
                      _buildLabel('First Name', colorScheme),
                      _buildTextField(_firstNameController, 'e.g. Juan', colorScheme),
                      const SizedBox(height: 20),

                      // Middle Initial
                      _buildLabel('Middle Initial', colorScheme),
                      _buildTextField(_middleInitialController, 'e.g. A', colorScheme),
                      const SizedBox(height: 20),

                      // College
                      _buildLabel('College', colorScheme),
                      _buildDropdown(
                        hint: 'Select your college',
                        value: _selectedCollege,
                        items: _colleges,
                        onChanged: (val) =>
                            setState(() => _selectedCollege = val),
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 20),

                      // Course
                      _buildLabel('Course', colorScheme),
                      _buildDropdown(
                        hint: 'Select your course',
                        value: _selectedCourse,
                        items: _courses,
                        onChanged: (val) =>
                            setState(() => _selectedCourse = val),
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.95),
                border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CreatePasswordScreen(
                            email: widget.email,
                            studentId: _studentIdController.text,
                            lastName: _lastNameController.text,
                            firstName: _firstNameController.text,
                            middleName: _middleInitialController.text,
                            college: _selectedCollege ?? '',
                            course: _selectedCourse ?? '',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 4,
                    shadowColor: colorScheme.primary.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(bool filled, ColorScheme colorScheme) {
    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: filled ? colorScheme.primary : colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, ColorScheme colorScheme) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: colorScheme.onSurface),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field is required';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lexend(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required ColorScheme colorScheme,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor: colorScheme.surfaceContainerHighest,
      hint: Text(
        hint,
        style: GoogleFonts.lexend(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: GoogleFonts.lexend(fontSize: 16, color: colorScheme.onSurface),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
