import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'services/auth_service.dart';
import 'personal_info_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  
  int _secondsRemaining = 120; // 2 minutes
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (var f in _focusNodes) {
      f.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  String get _timerText {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
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
          icon: const Icon(Icons.arrow_back, color: Color(0xff00205b)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Header Icon Container
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xfff1f5f9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.verified_user_outlined,
                          color: Color(0xff00205b),
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Title
                    Text(
                      'Verifying Details',
                      style: GoogleFonts.lexend(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff00205b),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: "We’ve sent a 6-digit verification code to\n"),
                          TextSpan(
                            text: widget.email,
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff0f172a),
                            ),
                          ),
                          const TextSpan(text: ". Please enter it below."),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 15,
                        color: const Color(0xff64748b),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) => _buildOtpBox(index)),
                    ),
                    const SizedBox(height: 40),
                    
                    // Timer display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_outlined, size: 18, color: Color(0xff64748b)),
                        const SizedBox(width: 8),
                        Text(
                          'Resend code in $_timerText',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            color: const Color(0xff64748b),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Resend Link
                    if (_secondsRemaining == 0)
                      GestureDetector(
                        onTap: _startTimer,
                        child: Text(
                          "Resend Code",
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff0056d2),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Confirm Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    String code = _controllers.map((c) => c.text).join();
                    if (code.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter the 6-digit code')),
                      );
                      return;
                    }

                    setState(() => _isLoading = true);
                    try {
                      // Note: confirmUser is mocked to delay 1s in AuthService
                      await AuthService().confirmUser(
                        email: widget.email, 
                        confirmationCode: code,
                      );
                      if (!mounted) return;
                      // Navigate to PersonalInfoScreen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PersonalInfoScreen(email: widget.email),
                        ),
                      );
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Verification failed: $e')),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0056d2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Confirm Code',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

  Widget _buildOtpBox(int index) {
    bool isFocused = _focusNodes[index].hasFocus;
    return Container(
      width: 46,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? const Color(0xff0056d2) : const Color(0xffe2e8f0),
          width: isFocused ? 2 : 1.5,
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
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xff0f172a),
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
