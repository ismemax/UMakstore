import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          'Terms of Service',
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
              'UMak App Store Terms of Service',
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

            // Terms Content
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing and using the UMak App Store, you accept and agree to be bound by the terms and provision of this agreement.',
              colorScheme,
            ),
            
            _buildSection(
              '2. Use License',
              'Permission is granted to temporarily download one copy of the materials on UMak App Store for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n'
              'a. modify or copy the materials\n'
              'b. use the materials for any commercial purpose or for any public display\n'
              'c. attempt to reverse engineer any software contained on UMak App Store\n'
              'd. remove any copyright or other proprietary notations from the materials',
              colorScheme,
            ),
            
            _buildSection(
              '3. Disclaimer',
              'The materials on UMak App Store are provided on an \'as is\' basis. UMak App Store makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
              colorScheme,
            ),
            
            _buildSection(
              '4. Limitations',
              'In no event shall UMak App Store or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on UMak App Store, even if UMak App Store or an authorized representative has been notified orally or in writing of the possibility of such damage.',
              colorScheme,
            ),
            
            _buildSection(
              '5. Accuracy of Materials',
              'The materials appearing on UMak App Store could include technical, typographical, or photographic errors. UMak App Store does not warrant that any of the materials on its website are accurate, complete, or current. UMak App Store may make changes to the materials contained on its website at any time without notice.',
              colorScheme,
            ),
            
            _buildSection(
              '6. Links',
              'UMak App Store has not reviewed all of the sites linked to our website and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by UMak App Store of the site. Use of any such linked website is at the user\'s own risk.',
              colorScheme,
            ),
            
            _buildSection(
              '7. Modifications',
              'UMak App Store may revise these terms of service for its website at any time without notice. By using this website, you are agreeing to be bound by the then current version of these terms of service.',
              colorScheme,
            ),
            
            _buildSection(
              '8. Governing Law',
              'These terms and conditions are governed by and construed in accordance with the laws of the Philippines and you irrevocably submit to the exclusive jurisdiction of the courts in that state or location.',
              colorScheme,
            ),

            const SizedBox(height: 32),
            
            // Contact Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Us',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If you have any questions about these Terms of Service, please contact us at:\n\n'
                    'Email: support@umak.edu.ph\n'
                    'Phone: +63 2 123-4567\n'
                    'Address: University of Makati, J.P. Rizal Extension, West Rembo, Makati City',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: colorScheme.onPrimary.withValues(alpha: 0.9),
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
