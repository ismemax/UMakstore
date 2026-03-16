import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpAndFeedbackScreen extends StatefulWidget {
  const HelpAndFeedbackScreen({super.key});

  @override
  State<HelpAndFeedbackScreen> createState() => _HelpAndFeedbackScreenState();
}

class _HelpAndFeedbackScreenState extends State<HelpAndFeedbackScreen> {
  // Simple state to handle tab switching for demonstration
  int _selectedTabIndex = 0; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff1e3a8a),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Help & Feedback',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.45,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            color: const Color(0xff1e3a8a),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTabIndex == 0 ? Colors.white : Colors.transparent,
                            width: 4,
                          ),
                        ),
                      ),
                      child: Text(
                        'FAQs',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: _selectedTabIndex == 0 ? FontWeight.bold : FontWeight.w500,
                          color: _selectedTabIndex == 0 ? Colors.white : Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTabIndex == 1 ? Colors.white : Colors.transparent,
                            width: 4,
                          ),
                        ),
                      ),
                      child: Text(
                        'Feedback',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: _selectedTabIndex == 1 ? FontWeight.bold : FontWeight.w500,
                          color: _selectedTabIndex == 1 ? Colors.white : Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _selectedTabIndex == 0 ? _buildFaqsContent() : _buildFeedbackContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xfff1f5f9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              decoration: InputDecoration(
                icon: const Icon(Icons.search_rounded, color: Color(0xff1e3a8a), size: 18),
                hintText: 'Search FAQs...',
                hintStyle: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff94a3b8),
                ),
                border: InputBorder.none,
              ),
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: const Color(0xff1e3a8a),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('ACCOUNT'),
          const SizedBox(height: 12),
          _buildFaqGroupCard([
            _buildFaqItem('How do I reset my password?'),
            _buildDivider(),
            _buildFaqItem('Can I change my student ID?'),
          ]),

          const SizedBox(height: 24),
          
          _buildSectionHeader('INSTALLATION'),
          const SizedBox(height: 12),
          _buildFaqGroupCard([
            _buildFaqItem('Why is my app not installing?'),
            _buildDivider(),
            _buildFaqItem('Minimum requirements for apps'),
          ]),

          const SizedBox(height: 24),
          
          _buildSectionHeader('SECURITY'),
          const SizedBox(height: 12),
          _buildFaqGroupCard([
            _buildFaqItem('How is my data protected?'),
            _buildDivider(),
            _buildFaqItem('What are license keys?'),
          ]),

          const SizedBox(height: 32),
          
          Center(
            child: Column(
              children: [
                Text(
                  'Still need help?',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: const Color(0xff64748b),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Contact Support',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff2094f3),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.open_in_new_rounded, color: Color(0xff2094f3), size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildFeedbackContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel('Category'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffe2e8f0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text(
                  'Select category',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    color: const Color(0xff64748b),
                  ),
                ),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xff1e3a8a)),
                items: ['Bug Report', 'Feature Request', 'Account Issue', 'Other']
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item, style: GoogleFonts.lexend(fontSize: 16)),
                        ))
                    .toList(),
                onChanged: (_) {},
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          _buildInputLabel('Subject'),
          const SizedBox(height: 8),
          _buildTextField(hintText: 'Brief summary of your feedback'),
          const SizedBox(height: 24),
          
          _buildInputLabel('Details'),
          const SizedBox(height: 8),
          _buildTextField(
            hintText: 'Tell us more about your experience...',
            maxLines: 6,
          ),
          const SizedBox(height: 24),
          
          // Screenshot Attachment
          _DottedBorderContainer(
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    const Icon(Icons.add_a_photo_outlined, color: Color(0xff1e3a8a), size: 32),
                    const SizedBox(height: 12),
                    Text(
                      'Attach Screenshot',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff001f3f),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Optional (JPG, PNG up to 5MB)',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        color: const Color(0xff94a3b8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2094f3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    'Submit Feedback',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.send_rounded, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.lexend(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: const Color(0xff1e3a8a),
      ),
    );
  }

  Widget _buildTextField({required String hintText, int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe2e8f0)),
      ),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.lexend(
            fontSize: 14,
            color: const Color(0xff94a3b8),
          ),
          border: InputBorder.none,
        ),
        style: GoogleFonts.lexend(
          fontSize: 14,
          color: const Color(0xff0f172a),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xff1e3a8a),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFaqGroupCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe2e8f0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000), // very subtle shadow representing Figma mock
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildFaqItem(String title) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w600, // SemiBold
                  color: const Color(0xff1e3a8a),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xff94a3b8), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xfff1f5f9),
    );
  }
}

class _DottedBorderContainer extends StatelessWidget {
  final Widget child;
  const _DottedBorderContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(),
      child: child,
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xffe2e8f0)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 3;
    final RRect rrect = RRect.fromLTRBR(0, 0, size.width, size.height, const Radius.circular(12));
    final Path path = Path()..addRRect(rrect);

    for (var pathMetric in path.computeMetrics()) {
      double distance = 0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
