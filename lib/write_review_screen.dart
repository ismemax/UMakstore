import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'review_submitted_screen.dart';

class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 4;
  bool _isAnonymous = false;
  final TextEditingController _reviewController = TextEditingController();
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _reviewController.addListener(() {
      setState(() {
        _charCount = _reviewController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  String _getRatingLabel() {
    switch (_rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: AppBar(
              backgroundColor: Colors.white.withValues(alpha: 0.95),
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leadingWidth: 100,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.chevron_left_rounded, color: Color(0xff2094f3), size: 28),
                      Text(
                        'Back',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff2094f3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              title: Text(
                'Write a Review',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff0a1f35),
                ),
              ),
              shape: const Border(
                bottom: BorderSide(color: Color(0xfff3f4f6), width: 1),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Tap a star to rate',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff1e3a5f),
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => setState(() => _rating = index + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.star_rounded,
                          size: 48,
                          color: index < _rating ? const Color(0xffffc107) : const Color(0xffcbd5e1),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text(
                  _getRatingLabel(),
                  style: GoogleFonts.lexend(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff0a1f35),
                  ),
                ),
                const SizedBox(height: 48),
                Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Share your thoughts ',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff0a1f35),
                          ),
                        ),
                        TextSpan(
                          text: '(optional)',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff1e3a5f).withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xfff9fafb),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffe5e7eb)),
                  ),
                  child: Stack(
                    children: [
                      TextField(
                        controller: _reviewController,
                        maxLines: null,
                        maxLength: 500,
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff0a1f35),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tell others what you think about this app. Was it helpful? Easy to use?',
                          hintStyle: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff9ca3af),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(17),
                          counterText: '',
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            '$_charCount/500',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff9ca3af),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: const Color(0xfff9fafb),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffe5e7eb)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(color: const Color(0xfff3f4f6)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.visibility_off_outlined, color: Color(0xff1e3a5f), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Post anonymously',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff0a1f35),
                              ),
                            ),
                            Text(
                              "Your name won't be displayed",
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                color: const Color(0xff1e3a5f).withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _isAnonymous,
                        activeColor: const Color(0xff2094f3),
                        onChanged: (value) => setState(() => _isAnonymous = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120), // Space for bottom button
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 25, 24, 32),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    border: const Border(top: BorderSide(color: Color(0xfff3f4f6))),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xff2094f3),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff2094f3).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Submit review action
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReviewSubmittedScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: Text(
                            'Submit Review',
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
