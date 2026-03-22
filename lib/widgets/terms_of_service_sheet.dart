import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceSheet extends StatefulWidget {
  const TermsOfServiceSheet({super.key});

  @override
  State<TermsOfServiceSheet> createState() => _TermsOfServiceSheetState();
}

class _TermsOfServiceSheetState extends State<TermsOfServiceSheet> {
  bool _isAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xffcbd5e1),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terms of Service',
                      style: GoogleFonts.lexend(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff0f172a),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Last Updated: Oct 26, 2023',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff64748b),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xff0f172a),
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xfff1f5f9)),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to UMak App Store. Please read\nthese Terms of Service ("Terms", "Terms of\nService") carefully before using the UMak\nmobile application (the "Service") operated\nby UMak Inc. ("us", "we", or "our").',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff334155),
                      height: 1.625,
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildSection(
                    number: '1',
                    title: 'Acceptance of Terms',
                    content:
                        'By accessing or using the Service you agree to be\nbound by these Terms. If you disagree with any\npart of the terms then you may not access the\nService. Your access to and use of the Service is\nconditioned on your acceptance of and\ncompliance with these Terms. These Terms apply\nto all visitors, users and others who access or use\nthe Service.',
                  ),
                  const SizedBox(height: 32),

                  _buildSection(
                    number: '2',
                    title: 'User Eligibility',
                    content:
                        'The Service is not intended for users under the\nage of 13. By using the Service, you represent and\nwarrant that you meet all of the foregoing\neligibility requirements. If you do not meet all of\nthese requirements, you must not access or use\nthe Service. We reserve the right to refuse\nservice, terminate accounts, remove or edit\ncontent, or cancel orders in our sole discretion.',
                  ),
                  const SizedBox(height: 32),

                  _buildSection(
                    number: '3',
                    title: 'Data Privacy & Security',
                    content:
                        'Your privacy is critical to us. We collect certain\ninformation about you and your device when you\nuse the UMak App Store. This may include:\n\n• Device identifiers and usage data to improve\n  app stability.\n• Account information provided during\n  registration.\n• Installed application history for compatibility\n  checks.\n\nWe implement industry-standard security\nmeasures to protect your data. However, no\nmethod of transmission over the Internet is 100%\nsecure.',
                  ),
                  const SizedBox(height: 32),

                  _buildSection(
                    number: '4',
                    title: 'Content Guidelines',
                    content:
                        'Users are responsible for any content they upload\nor post to the UMak App Store. You agree not to\npost content that:\n\n• Is illegal, threatening, or defamatory.\n• Infringes on the intellectual property rights of\n  others.\n• Contains malware, viruses, or harmful code.',
                  ),
                  const SizedBox(height: 32),

                  _buildSection(
                    number: '5',
                    title: 'Termination',
                    content:
                        'We may terminate or suspend access to our\nService immediately, without prior notice or\nliability, for any reason whatsoever, including\nwithout limitation if you breach the Terms. All\nprovisions of the Terms which by their nature\nshould survive termination shall survive\ntermination.',
                  ),

                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.water_drop,
                          color: Color(0xff94a3b8),
                        ), // Placeholder symbol
                        const SizedBox(height: 8),
                        Text(
                          'End of Document',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            color: const Color(0xff94a3b8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 128), // Padding equivalent
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(24, 25, 24, 40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              border: const Border(top: BorderSide(color: Color(0xccf1f5f9))),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Checkbox(
                        value: _isAccepted,
                        onChanged: (val) {
                          setState(() {
                            _isAccepted = val ?? false;
                          });
                        },
                        activeColor: const Color(0xff2094f3),
                        side: const BorderSide(color: Color(0xffcbd5e1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff334155),
                            height: 1.428,
                          ),
                          children: const [
                            TextSpan(text: 'I have read and agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xff2094f3),
                              ),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xff2094f3),
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Color(0xffe2e8f0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Decline',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff0f172a),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isAccepted
                            ? () => Navigator.of(context).pop(true)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2094f3),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xffe2e8f0),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: _isAccepted ? 4 : 0,
                          shadowColor: const Color(0x332094f3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Accept & Continue',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0x1a2094f3),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Center(
                child: Text(
                  number,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff2094f3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff0f172a),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xff334155),
            height: 1.625,
          ),
        ),
      ],
    );
  }
}
