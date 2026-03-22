import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'legal_and_consent_screen.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String email;
  final String studentId;
  final String lastName;
  final String firstName;
  final String middleName;
  final String college;
  final String course;

  const CreatePasswordScreen({
    super.key,
    required this.email,
    required this.studentId,
    required this.lastName,
    required this.firstName,
    required this.middleName,
    required this.college,
    required this.course,
  });

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Real-time validation states
  bool _hasMin8Chars = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  int _strength = 0; // 0-4

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final p = _passwordController.text;
    setState(() {
      _hasMin8Chars = p.length >= 8;
      _hasUppercase = p.contains(RegExp(r'[A-Z]'));
      _hasLowercase = p.contains(RegExp(r'[a-z]'));
      _hasNumber = p.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = p.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{};:" ,.?\\:{}|<>=]'));
      
      _strength = 0;
      if (_hasMin8Chars) _strength++;
      if (_hasUppercase && _hasLowercase) _strength++;
      if (_hasNumber) _strength++;
      if (_hasSpecialChar) _strength++;
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff0a2540)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Step 4 of 4',
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
                  _buildProgressBar(true),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    // Title
                    Text(
                      'Create a Password',
                      style: GoogleFonts.lexend(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff0a2540),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      'For the security of your account, please\ncreate a strong password.',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        color: const Color(0xff64748b),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Password Field
                    _buildLabel('Password'),
                    _buildPasswordField(
                      controller: _passwordController,
                      hint: 'P@ssw',
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    
                    // Strength Indicator
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              _buildStrengthSegment(_strength >= 1 ? const Color(0xffef4444) : const Color(0xffe2e8f0)), // Weak - Red
                              _buildStrengthSegment(_strength >= 2 ? const Color(0xfff59e0b) : const Color(0xffe2e8f0)), // Medium - Orange
                              _buildStrengthSegment(_strength >= 3 ? const Color(0xff22c55e) : const Color(0xffe2e8f0)), // Strong - Light Green
                              _buildStrengthSegment(_strength >= 4 ? const Color(0xff15803d) : const Color(0xffe2e8f0)), // Very Strong - Dark Green
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Medium',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xfff59e0b),
                          ),
                        ),
                        Text(
                          'Strength',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff94a3b8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Confirm Password Field
                    _buildLabel('Confirm Password'),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hint: 'Re-enter your password',
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                    // Password Requirements Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xfff8fafc),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xffe2e8f0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password Requirements',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff0a2540),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildRequirementItem('At least 8 characters', _hasMin8Chars),
                          const SizedBox(height: 10),
                          _buildRequirementItem('One uppercase letter', _hasUppercase),
                          const SizedBox(height: 10),
                          _buildRequirementItem('One lowercase letter', _hasLowercase),
                          const SizedBox(height: 10),
                          _buildRequirementItem('One number', _hasNumber),
                          const SizedBox(height: 10),
                          _buildRequirementItem('One special character (!@#\$%=)', _hasSpecialChar),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
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
                  onPressed: _isLoading ? null : () async {
                    final password = _passwordController.text;
                    final confirm = _confirmPasswordController.text;
                    
                    // CHECK ALL CONDITIONS ARE MET
                    bool allConditionsMet = _hasMin8Chars && 
                                           _hasUppercase && 
                                           _hasLowercase && 
                                           _hasNumber && 
                                           _hasSpecialChar;

                    if (!allConditionsMet) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please meet all password requirements first.')),
                      );
                      return;
                    }

                    if (password.isEmpty || confirm.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                      return;
                    }
                    if (password != confirm) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
                      return;
                    }

                    setState(() => _isLoading = true);
                    try {
                      // Perform sign up here if not done in Step 1, 
                      // but since Step 1 was using email/pass, we'll assume we're doing it here or just updating.
                      // Let's assume registration is a multi-step process where signUp happens here.
                      await AuthService().signUpUser(
                        email: widget.email,
                        password: password,
                      );
                      
                      if (!mounted) return;
                      if (mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LegalAndConsentScreen(
                              email: widget.email,
                              studentId: widget.studentId,
                              lastName: widget.lastName,
                              firstName: widget.firstName,
                              middleName: widget.middleName,
                              college: widget.college,
                              course: widget.course,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account creation failed: $e')));
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0a2540),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0x330a2540),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : Text(
                          'Complete Registration',
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
          color: filled ? const Color(0xff0a2540) : const Color(0xffe2e8f0),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
    );
  }

  Widget _buildStrengthSegment(Color color) {
    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(9999), // Simplified for now, though Figma has rounded corners on edges
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xff0a2540),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.lexend(
        fontSize: 16,
        color: const Color(0xff0a2540),
      ),
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
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xff0a2540),
            size: 22,
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff0a2540)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff0a2540)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff0a2540), width: 2),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool met) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          met ? Icons.check_circle_outline_rounded : Icons.radio_button_unchecked_rounded,
          color: met ? const Color(0xff10b981) : const Color(0xffcbd5e1), // Green vs Grayish
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: met ? FontWeight.w500 : FontWeight.w400,
              color: met ? const Color(0xff0a2540) : const Color(0xff64748b),
            ),
          ),
        ),
      ],
    );
  }
}
