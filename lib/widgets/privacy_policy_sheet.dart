import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicySheet extends StatefulWidget {
  const PrivacyPolicySheet({super.key});

  @override
  State<PrivacyPolicySheet> createState() => _PrivacyPolicySheetState();
}

class _PrivacyPolicySheetState extends State<PrivacyPolicySheet> {
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
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xffd1d5db),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 17),
            child: Column(
              children: [
                Text(
                  'Privacy Policy',
                  style: GoogleFonts.lexend(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff0f172a),
                    letterSpacing: -0.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Last updated: October 24, 2023',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff6b7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xfff3f4f6)),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to the UMak App Store. Your privacy is\ncritically important to us. This policy outlines how\nthe University of Makati collects, uses, and protects\nyour personal and academic data while using our\nplatform.',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xff374151),
                      height: 1.625,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildSection(
                    icon: Icons.fingerprint,
                    title: '1. Information We Collect',
                    content: 'To provide a seamless academic experience, we\ncollect specific data points directly linked to your\nstudent profile:\n\n• **Academic Identity:** Student ID number, full\n  name, enrolled course, year level, and section.\n• **Contact Details:** University email address\n  (@umak.edu.ph) and registered mobile\n  number.\n• **Device Information:** Device model, OS\n  version, and unique identifiers for security\n  authentication.',
                  ),
                  const SizedBox(height: 32),
                  
                  _buildSection(
                    icon: Icons.pie_chart_outline,
                    title: '2. How We Use Your Data',
                    content: 'Your data is utilized strictly for academic and\nadministrative purposes within the university\necosystem:',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: const Color(0xfff8fafc),
                      border: Border.all(color: const Color(0xfff3f4f6)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personalization',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff0f172a),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tailoring app recommendations and academic\nnotifications based on your specific course and year\nlevel.',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff4b5563),
                            height: 1.625,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: const Color(0xfff8fafc),
                      border: Border.all(color: const Color(0xfff3f4f6)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Authentication & Security',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff0f172a),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Verifying your enrollment status in real-time to grant\naccess to student-only resources.',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff4b5563),
                            height: 1.625,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  _buildSection(
                    icon: Icons.share_outlined,
                    title: '3. Third-Party Services',
                    content: 'We may employ third-party companies and\nindividuals due to the following reasons:\n\n✓ To facilitate our Service;\n✓ To provide the Service on our behalf;\n✓ To perform Service-related services; or',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 17.6),
                    decoration: BoxDecoration(
                      color: const Color(0xffeff6ff),
                      border: Border.all(color: const Color(0xffdbeafe)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: const Color(0xff0f172a),
                          height: 1.625,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Note: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'We do not sell your personal data to\nadvertisers. External sharing is limited strictly to\nacademic partners authorized by the University\nRegistrar.',
                            style: TextStyle(fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  _buildSection(
                    icon: Icons.shield_outlined,
                    title: '4. Data Retention',
                    content: 'We will retain your personal information only for\nas long as is necessary for the purposes set out in\nthis Privacy Policy. We will retain and use your\ninformation to the extent necessary to comply\nwith our legal obligations.',
                  ),
                  
                  const SizedBox(height: 128), // Padding equivalent
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(16, 17, 16, 48),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xfff3f4f6)),
              ),
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
                        side: const BorderSide(color: Color(0xffd1d5db)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'I have read and agree to the terms.',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff4b5563),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isAccepted
                        ? () => Navigator.of(context).pop(true)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2094f3),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xffe2e8f0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: _isAccepted ? 4 : 0,
                      shadowColor: const Color(0x332094f3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Accept & Continue',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required String content}) {
    List<TextSpan> parseContent(String text) {
      final spans = <TextSpan>[];
      final regex = RegExp(r'\*\*([^*]+)\*\*'); // Match text between **
      int currentIndex = 0;
      
      for (final match in regex.allMatches(text)) {
        if (match.start > currentIndex) {
          spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
        }
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff0f172a)),
        ));
        currentIndex = match.end;
      }
      
      if (currentIndex < text.length) {
        spans.add(TextSpan(text: text.substring(currentIndex)));
      }
      
      return spans;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xff0f172a)),
            const SizedBox(width: 12),
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
        RichText(
          text: TextSpan(
            style: GoogleFonts.lexend(
               fontSize: 14,
               fontWeight: FontWeight.w400,
               color: const Color(0xff374151),
               height: 1.625,
            ),
            children: parseContent(content),
          ),
        ),
      ],
    );
  }
}
