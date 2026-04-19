import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
          style: GoogleFonts.lexend(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'UMak App Store Privacy Policy',
              style: GoogleFonts.lexend(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: April 2026',
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Privacy Content
            _buildSection(
              '1. Information We Collect',
              'We collect information you provide directly to us, such as when you create an account, use our services, or contact us for support. This includes:\n\n'
              'a. Account information (name, email address, student ID)\n'
              'b. Device information (device type, operating system, unique device identifiers)\n'
              'c. Usage information (how you use the app, features accessed, time spent)\n'
              'd. Academic information (college, course, academic year)',
              colorScheme,
            ),
            
            _buildSection(
              '2. How We Use Your Information',
              'We use the information we collect to:\n\n'
              'a. Provide, maintain, and improve our services\n'
              'b. Process transactions and send related information\n'
              'c. Send technical notices, updates, security alerts, and support messages\n'
              'd. Respond to your comments, questions, and requests\n'
              'e. Monitor and analyze trends and usage to improve your experience\n'
              'f. Detect, prevent, and address technical issues',
              colorScheme,
            ),
            
            _buildSection(
              '3. Information Sharing',
              'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy:\n\n'
              'a. With service providers acting on our behalf to provide services\n'
              'b. To comply with legal obligations\n'
              'c. To protect and defend the rights or property of UMak App Store\n'
              'd. In connection with a merger, acquisition, or sale of assets',
              colorScheme,
            ),
            
            _buildSection(
              '4. Data Security',
              'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the Internet or method of electronic storage is 100% secure.',
              colorScheme,
            ),
            
            _buildSection(
              '5. Data Retention',
              'We retain your personal information for as long as necessary to provide the services to you and for the purposes outlined in this privacy policy, unless a longer retention period is required or permitted by law.',
              colorScheme,
            ),
            
            _buildSection(
              '6. Your Rights',
              'You have the right to:\n\n'
              'a. Access and update your personal information\n'
              'b. Request deletion of your personal information\n'
              'c. Opt out of certain communications\n'
              'd. Request a copy of your personal information\n'
              'e. Object to processing of your personal information',
              colorScheme,
            ),
            
            _buildSection(
              '7. Children\'s Privacy',
              'Our services are not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If you become aware that a child has provided us with personal information, please contact us.',
              colorScheme,
            ),
            
            _buildSection(
              '8. Changes to This Policy',
              'We may update this privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page and updating the "Last updated" date.',
              colorScheme,
            ),
            
            _buildSection(
              '9. Contact Information',
              'If you have any questions about this Privacy Policy, please contact us at:\n\n'
              'Email: privacy@umak.edu.ph\n'
              'Phone: +63 2 123-4567\n'
              'Address: University of Makati, J.P. Rizal Extension, West Rembo, Makati City',
              colorScheme,
            ),

            const SizedBox(height: 32),
            
            // Data Protection Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: colorScheme.onError, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Data Protection',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onError,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your privacy is important to us. We are committed to protecting your personal information and will only use it in accordance with this privacy policy and applicable data protection laws.',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: colorScheme.onError.withValues(alpha: 0.9),
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

  Widget _buildSection(String title, String content, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.lexend(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
