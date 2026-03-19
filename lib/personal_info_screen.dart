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
  final TextEditingController _middleInitialController = TextEditingController();
  
  String? _selectedCollege;
  String? _selectedCourse;

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff003366)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Step 3 of 4',
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xff64748b),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                children: [
                  _buildProgressBar(true),
                  const SizedBox(width: 8),
                  _buildProgressBar(true),
                  const SizedBox(width: 8),
                  _buildProgressBar(true),
                  const SizedBox(width: 8),
                  _buildProgressBar(false),
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
                          color: const Color(0xff0f172a),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Subtitle
                      Text(
                        'Please provide your details exactly as they\nappear in your official school records.',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          color: const Color(0xff64748b),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Student ID (Locked/Read-only)
                      _buildLabel('Student ID'),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xfff8fafc),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xffe2e8f0)),
                        ),
                        child: TextField(
                          controller: _studentIdController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'K12345678',
                            hintStyle: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff64748b),
                            ),
                            suffixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: Color(0xff94a3b8),
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
                      _buildLabel('Last Name'),
                      _buildTextField(_lastNameController, 'e.g. Dela Cruz'),
                      const SizedBox(height: 20),
                      
                      // First Name
                      _buildLabel('First Name'),
                      _buildTextField(_firstNameController, 'e.g. Juan'),
                      const SizedBox(height: 20),
                      
                      // Middle Initial
                      _buildLabel('Middle Initial'),
                      _buildTextField(_middleInitialController, 'e.g. A'),
                      const SizedBox(height: 20),
                      
                      // College
                      _buildLabel('College'),
                      _buildDropdown(
                        hint: 'Select your college',
                        value: _selectedCollege,
                        items: _colleges,
                        onChanged: (val) => setState(() => _selectedCollege = val),
                      ),
                      const SizedBox(height: 20),
                      
                      // Course
                      _buildLabel('Course'),
                      _buildDropdown(
                        hint: 'Select your course',
                        value: _selectedCourse,
                        items: _courses,
                        onChanged: (val) => setState(() => _selectedCourse = val),
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
                color: Colors.white.withValues(alpha: 0.95),
                border: const Border(
                  top: BorderSide(color: Color(0xfff1f5f9)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Navigate with all collected profile data
                      // Note: We'll pass these forward to avoid saving until registration completes
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
                    backgroundColor: const Color(0xff003366),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0x33003366),
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

  Widget _buildProgressBar(bool filled) {
    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: filled ? const Color(0xff003366) : const Color(0xffe2e8f0),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: const Color(0xff003366),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
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
          color: const Color(0xff94a3b8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xffcbd5e1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xffcbd5e1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff003366), width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      hint: Text(
        hint,
        style: GoogleFonts.lexend(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: const Color(0xff0f172a),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xff64748b)),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff003366)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff003366)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff003366), width: 2),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: GoogleFonts.lexend(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
