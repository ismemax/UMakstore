import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'personal_info_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // Controllers for digits
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (var f in _focusNodes) {
      f.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
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
          icon: const Icon(Icons.arrow_back, color: Color(0xff002855)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Step 2 of 4',
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
                  _buildProgressBar(false),
                  const SizedBox(width: 8),
                  _buildProgressBar(false),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    // Envelope Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xffeff6ff),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mail_outline_rounded,
                          color: Color(0xff002855),
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title
                    Text(
                      'Verify your email',
                      style: GoogleFonts.lexend(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff002855),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: "We've sent a 6-digit verification code to\n"),
                          TextSpan(
                            text: widget.email,
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff0f172a),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        color: const Color(0xff64748b),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Wrong email link
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Wrong email address?',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff002855),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // OTP Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) => _buildOtpBox(index)),
                    ),
                    const SizedBox(height: 32),
                    
                    // Timer Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: Color(0xff64748b),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '01:54',
                          style: TextStyle(
                            fontFamily: 'Liberation Mono', // As specified in design data
                            fontSize: 16,
                            color: const Color(0xff64748b),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Resend Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the code? ",
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            color: const Color(0xff64748b),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: Implement Resend
                          },
                          child: Text(
                            "Resend Code",
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff002855),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PersonalInfoScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff002855),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0x33002855),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Verify Email',
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
          color: filled ? const Color(0xff002855) : const Color(0xffe2e8f0),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _focusNodes[index].hasFocus ? const Color(0xff002855) : const Color(0x4d002855), // 0.3 opacity
          width: 2,
        ),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: GoogleFonts.lexend(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xff002855),
          ),
          decoration: const InputDecoration(
            counterText: "",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }
}
