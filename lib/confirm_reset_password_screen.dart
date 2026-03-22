import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'password_changed_success_screen.dart';

class ConfirmResetPasswordScreen extends StatefulWidget {
  final String email;
  final String code; // Verified code or empty for manual entry
  const ConfirmResetPasswordScreen({
    super.key,
    required this.email,
    this.code = '',
  });

  @override
  State<ConfirmResetPasswordScreen> createState() =>
      _ConfirmResetPasswordScreenState();
}

class _ConfirmResetPasswordScreenState
    extends State<ConfirmResetPasswordScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

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
      _hasSpecialChar = p.contains(
        RegExp(r'[!@#\$%^&*()_+\-=\[\]{};:" ,.?\\:{}|<>=]'),
      );

      _strength = 0;
      if (_hasMin8Chars) _strength++;
      if (_hasUppercase && _hasLowercase) _strength++;
      if (_hasNumber) _strength++;
      if (_hasSpecialChar) _strength++;
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
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
          'Reset Password',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xff0a2540),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Create New Password',
                style: GoogleFonts.lexend(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff0a2540),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your code has been verified. Now, please enter a new strong password for your account.',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  color: const Color(0xff64748b),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Code Field - only show if not already verified in previous screen
              if (widget.code.isEmpty) ...[
                _buildLabel('Recovery Code'),
                _buildTextField(
                  controller: _codeController,
                  hint: 'Enter code from email',
                  icon: Icons.vpn_key_outlined,
                ),
                const SizedBox(height: 24),
              ],

              // Password Field
              _buildLabel('New Password'),
              _buildPasswordField(
                controller: _passwordController,
                hint: 'Enter new password',
                obscureText: _obscurePassword,
                onToggleVisibility: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              const SizedBox(height: 12),

              // Strength Indicator
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _buildStrengthSegment(
                          _strength >= 1
                              ? const Color(0xffef4444)
                              : const Color(0xffe2e8f0),
                        ),
                        _buildStrengthSegment(
                          _strength >= 2
                              ? const Color(0xfff59e0b)
                              : const Color(0xffe2e8f0),
                        ),
                        _buildStrengthSegment(
                          _strength >= 3
                              ? const Color(0xff22c55e)
                              : const Color(0xffe2e8f0),
                        ),
                        _buildStrengthSegment(
                          _strength >= 4
                              ? const Color(0xff15803d)
                              : const Color(0xffe2e8f0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Requirements
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xfff8fafc),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffe2e8f0)),
                ),
                child: Column(
                  children: [
                    _buildRequirementItem(
                      'At least 8 characters',
                      _hasMin8Chars,
                    ),
                    const SizedBox(height: 10),
                    _buildRequirementItem(
                      'Uppercase & Lowercase',
                      _hasUppercase && _hasLowercase,
                    ),
                    const SizedBox(height: 10),
                    _buildRequirementItem('One number', _hasNumber),
                    const SizedBox(height: 10),
                    _buildRequirementItem(
                      'Special character (!@#\$%=)',
                      _hasSpecialChar,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0a2540),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Update Password',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleConfirm() async {
    final password = _passwordController.text;
    final code = widget.code.isNotEmpty ? widget.code : _codeController.text;

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the code from your email')),
      );
      return;
    }

    bool allConditionsMet =
        _hasMin8Chars &&
        _hasUppercase &&
        _hasLowercase &&
        _hasNumber &&
        _hasSpecialChar;
    if (!allConditionsMet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please meet all security requirements')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService().confirmResetPassword(
        email: widget.email,
        newPassword: password,
        confirmationCode: code,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const PasswordChangedSuccessScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.lexend(fontSize: 16, color: const Color(0xff0a2540)),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xff64748b), size: 20),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
      style: GoogleFonts.lexend(fontSize: 16, color: const Color(0xff0a2540)),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: Color(0xff64748b),
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xff0a2540),
          ),
          onPressed: onToggleVisibility,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildStrengthSegment(Color color) {
    return Expanded(
      child: Container(
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool met) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          color: met ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.lexend(
            fontSize: 14,
            color: met ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }
}
