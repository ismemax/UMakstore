import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', '5 ★', '4 ★', '3 ★', '2 ★', '1 ★'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xff1e3a8a),
                  size: 32,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Reviews',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1e293b),
                ),
              ),
              shape: const Border(
                bottom: BorderSide(color: Color(0xfff1f5f9), width: 1),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 56 + 24),
            _buildRatingSummary(),
            _buildFilterTabs(),
            _buildReviewList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xfff1f5f9))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                '4.8',
                style: GoogleFonts.lexend(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1e3a8a),
                  letterSpacing: -3,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'out of 5',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff64748b),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(5, 0.85),
                const SizedBox(height: 6),
                _buildRatingBar(4, 0.1),
                const SizedBox(height: 6),
                _buildRatingBar(3, 0.03),
                const SizedBox(height: 6),
                _buildRatingBar(2, 0.01),
                const SizedBox(height: 6),
                _buildRatingBar(1, 0.01),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '1,248 Ratings',
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff64748b),
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

  Widget _buildRatingBar(int stars, double progress) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: List.generate(5, (index) {
              return Icon(
                Icons.star_rounded,
                size: 8,
                color: index < stars
                    ? const Color(0xff1e3a8a)
                    : const Color(0xfff1f5f9),
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xfff1f5f9),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xff1e3a8a),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xff1e3a8a) : Colors.white,
                borderRadius: BorderRadius.circular(9999),
                border: isSelected
                    ? null
                    : Border.all(color: const Color(0xff1e3a8a)),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  filter,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xff1e3a8a),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildReviewCard(
            initials: 'K1',
            username: 'K1123456',
            date: 'Oct 20, 2023',
            rating: 5,
            title: 'Super helpful!',
            content:
                'Finally, an app that works smoothly. Checking grades and schedules is so much easier now compared to the old website. The notification feature for class cancellations is a lifesaver!',
            helpfulCount: 12,
            bgColor: const Color(0xffdbeafe),
            textColor: const Color(0xff1e3a8a),
            borderColor: const Color(0xffbfdbfe),
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            initials: 'K2',
            username: 'K1198765',
            date: 'Oct 18, 2023',
            rating: 4,
            title: 'Great UI, needs minor fixes',
            content:
                'The interface is clean and modern. Notifications sometimes come in a bit late, but overall a solid experience for students. Would love to see a dark mode toggle inside the app settings directly.',
            helpfulCount: 5,
            bgColor: const Color(0xfff3e8ff),
            textColor: const Color(0xff7e22ce),
            borderColor: const Color(0xffe9d5ff),
            developerResponse: {
              'date': 'Oct 19, 2023',
              'content':
                  "Hi K1198765, thanks for the feedback! We've noted the issue with notifications and will include a fix in the next patch. Dark mode toggle is coming in v2.5!",
            },
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            initials: 'A2',
            username: 'A2200102',
            date: 'Sep 05, 2023',
            rating: 5,
            title: 'Essential for Freshmen',
            content:
                'As a freshman, I was getting lost finding rooms. The schedule with room numbers is perfect. Highly recommend downloading this immediately.',
            helpfulCount: 28,
            bgColor: const Color(0xffd1fae5),
            textColor: const Color(0xff047857),
            borderColor: const Color(0xffa7f3d0),
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            initials: 'K1',
            username: 'K1144221',
            date: 'Aug 21, 2023',
            rating: 3,
            title: 'Crashing on login',
            content:
                "The app crashes whenever I try to log in with my student ID. I've reinstalled it twice. Please fix this ASAP as enrollment is starting.",
            helpfulCount: 3,
            bgColor: const Color(0xffffedd5),
            textColor: const Color(0xffc2410c),
            borderColor: const Color(0xfffed7aa),
            developerResponse: {
              'date': 'Aug 22, 2023',
              'content':
                  'We apologize for the inconvenience. This was a server-side issue that has now been resolved. Please try logging in again.',
            },
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            initials: 'K3',
            username: 'K3309112',
            date: 'Aug 10, 2023',
            rating: 5,
            title: 'Simple and Effective',
            content:
                'Does exactly what it says. No clutter. Just grades and sched. Perfect.',
            helpfulCount: 8,
            bgColor: const Color(0xfffce7f3),
            textColor: const Color(0xffbe185d),
            borderColor: const Color(0xfffbcfe8),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required String initials,
    required String username,
    required String date,
    required int rating,
    required String title,
    required String content,
    required int helpfulCount,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
    Map<String, String>? developerResponse,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xfff1f5f9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [bgColor, borderColor],
                      ),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: borderColor),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff1e3a8a),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: List.generate(5, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Icon(
                              Icons.star_rounded,
                              size: 11,
                              color: index < rating
                                  ? const Color(0xff1e3a8a)
                                  : const Color(0xfff1f5f9),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                date,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff64748b),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0f172a),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: GoogleFonts.lexend(
              fontSize: 14,
              height: 1.6,
              color: const Color(0xff1e293b).withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 13),
          const Divider(color: Color(0xfff8fafc), height: 1),
          const SizedBox(height: 13),
          Row(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.thumb_up_alt_outlined,
                    size: 14,
                    color: Color(0xff64748b),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Helpful ($helpfulCount)',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff64748b),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Text(
                'Report',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff3b82f6),
                ),
              ),
            ],
          ),
          if (developerResponse != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 4, 12, 12),
              decoration: BoxDecoration(
                color: const Color(0xfff8fafc),
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: Color(0xff1e3a8a), width: 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Developer Response',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff1e3a8a),
                        ),
                      ),
                      Text(
                        developerResponse['date']!,
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          color: const Color(0xff64748b),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    developerResponse['content']!,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      height: 1.6,
                      color: const Color(0xff1e293b).withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
