import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'password_changed_success_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xff1e3a8a)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Change Password',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xff1e3a8a), // Matches Figma
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create a new password for your account. Make\nsure it\'s secure and easy to remember.',
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: const Color(0xff64748b),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            
            // TextFields
            _buildPasswordField(
              label: 'Current Password',
              obscureText: _obscureCurrent,
              onToggleVisibility: () {
                setState(() => _obscureCurrent = !_obscureCurrent);
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              label: 'New Password',
              obscureText: _obscureNew,
              onToggleVisibility: () {
                setState(() => _obscureNew = !_obscureNew);
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              label: 'Confirm Password',
              obscureText: _obscureConfirm,
              onToggleVisibility: () {
                setState(() => _obscureConfirm = !_obscureConfirm);
              },
            ),
            
            const SizedBox(height: 24),
            
            // Password Requirements Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xfff9fafb),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xfff3f4f6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PASSWORD REQUIREMENTS',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff1e3a8a),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRequirementItem('At least 8 characters long', isMet: true),
                  const SizedBox(height: 12),
                  _buildRequirementItem('Contains one uppercase letter'),
                  const SizedBox(height: 12),
                  _buildRequirementItem('Contains one number'),
                  const SizedBox(height: 12),
                  _buildRequirementItem('Contains one special character'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Save Button
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PasswordChangedSuccessScreen()),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xff2094f3),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x333b82f6),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  'Save New Password',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      obscureText: obscureText,
      style: GoogleFonts.lexend(
        fontSize: 16,
        color: const Color(0xff1e3a8a),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lexend(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xff94a3b8),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffe5e7eb)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffe5e7eb)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xff2094f3), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xff94a3b8),
            size: 22,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, {bool isMet = false}) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle_outline_rounded : Icons.radio_button_unchecked_rounded,
          color: isMet ? const Color(0xff22c55e) : const Color(0xffcbd5e1),
          size: 16,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.lexend(
            fontSize: 14,
            color: const Color(0xff1e3a8a),
          ),
        ),
      ],
    );
  }
}
