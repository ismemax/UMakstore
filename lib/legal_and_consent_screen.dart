import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/privacy_policy_sheet.dart';
import 'widgets/terms_of_service_sheet.dart';
import 'account_setup_screen.dart';

class LegalAndConsentScreen extends StatefulWidget {
  final String email;
  final String studentId;
  final String lastName;
  final String firstName;
  final String middleName;
  final String college;
  final String course;

  const LegalAndConsentScreen({
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
  State<LegalAndConsentScreen> createState() => _LegalAndConsentScreenState();
}

class _LegalAndConsentScreenState extends State<LegalAndConsentScreen> {
  bool _termsAccepted = false;
  bool _marketingAccepted = false;
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff0f172a)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Step 5 of 5',
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
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  _buildProgressBar(true),
                  const SizedBox(width: 8),
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
                      'Legal & Consent',
                      style: GoogleFonts.lexend(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff0f172a),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Please review and accept our policies to\ncomplete your registration.',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        color: const Color(0xff64748b),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Terms of Service Checkbox Box
                    _buildCheckboxCard(
                      value: _termsAccepted,
                      onChanged: (val) {
                        setState(() {
                          _termsAccepted = val ?? false;
                        });
                      },
                      title: 'Terms of Service',
                      content: RichText(
                        text: TextSpan(
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff64748b),
                            height: 1.625,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final accepted =
                                      await showModalBottomSheet<bool>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            const FractionallySizedBox(
                                              heightFactor: 0.9,
                                              child: TermsOfServiceSheet(),
                                            ),
                                      );
                                  if (accepted == true) {
                                    setState(() {
                                      _termsAccepted = true;
                                    });
                                  }
                                },
                              text: 'Terms of Service',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xff0f172a),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' and\n'),
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final accepted =
                                      await showModalBottomSheet<bool>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            const FractionallySizedBox(
                                              heightFactor: 0.9,
                                              child: PrivacyPolicySheet(),
                                            ),
                                      );
                                  if (accepted == true) {
                                    setState(() {
                                      // Normally you might want a separate checkbox, but since
                                      // the design lumps them together, accepting the privacy policy
                                      // can also check the main terms box if it isn't already, or
                                      // it could just be informational. Let's just check the box
                                      // if both sheets were accepted, or simply checking this box is
                                      // indicating agreement to both. Let's set it to true here as well
                                      // as a convenience.
                                      _termsAccepted = true;
                                    });
                                  }
                                },
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xff0f172a),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  '. This includes\npermission to process my personal\ndata for account management.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Marketing Checkbox Box
                    _buildCheckboxCard(
                      value: _marketingAccepted,
                      onChanged: (val) {
                        setState(() {
                          _marketingAccepted = val ?? false;
                        });
                      },
                      title: 'Marketing Communications',
                      isOptional: true,
                      content: Text(
                        'I consent to receive updates,\nnewsletters, and promotional offers\nvia email. You can unsubscribe at any\ntime in your settings.',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff64748b),
                          height: 1.625, // 22.75/14
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: const Color(0xfff8fafc),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xfff1f5f9)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2.0),
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xff64748b),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your data is encrypted and stored securely. We\nnever sell your personal information to third\nparties without your explicit consent.',
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xff64748b),
                                height: 1.625, // 19.5/12
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),

            // Bottom Button Section
            Container(
              padding: const EdgeInsets.fromLTRB(24, 17, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xffe2e8f0))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_termsAccepted && !_isLoading)
                          ? _handleFinalRegistration
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0f172a),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xffe2e8f0),
                        disabledForegroundColor: const Color(0xff94a3b8),
                        elevation: _termsAccepted ? 4 : 0,
                        shadowColor: const Color(0x330f172a),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Create Account',
                              style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'By creating an account, you agree to our policies.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff64748b),
                    ),
                  ),
                ],
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
          color: filled ? const Color(0xff0f172a) : const Color(0xffe2e8f0),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
    );
  }

  Widget _buildCheckboxCard({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
    required Widget content,
    bool isOptional = false,
  }) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        padding: const EdgeInsets.all(21),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffe2e8f0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000), // 0.05 opacity = 0x0D
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xff0f172a),
                side: const BorderSide(color: Color(0xffd1d5db)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff0f172a),
                    ),
                  ),
                  const SizedBox(height: 4),
                  content,
                  if (isOptional) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xfff1f5f9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Optional',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff475569),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFinalRegistration() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AccountSetupScreen(
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
}
