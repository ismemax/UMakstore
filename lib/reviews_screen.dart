import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/developer_service.dart';
import 'models/app_model.dart';
import 'services/language_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewsScreen extends StatefulWidget {
  final AppModel app;
  const ReviewsScreen({super.key, required this.app});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final LanguageService _languageService = LanguageService();
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', '5 ★', '4 ★', '3 ★', '2 ★', '1 ★'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: colorScheme.primary,
                  size: 32,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                _languageService.translate('ratings_reviews'),
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              shape: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: DeveloperService().getAppReviews(widget.app.id),
        builder: (context, snapshot) {
          final allReviews = snapshot.data ?? [];
          final filteredReviews = _filterReviews(allReviews);
          final distribution = _calculateDistribution(allReviews);

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 56 + 24),
                _buildRatingSummary(distribution, allReviews.length, colorScheme),
                _buildFilterTabs(colorScheme),
                _buildReviewList(filteredReviews, colorScheme),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingSummary(Map<int, double> distribution, int totalCount, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                widget.app.rating,
                style: GoogleFonts.lexend(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: -3,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _languageService.translate('out_of_5'),
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(5, distribution[5] ?? 0.0, colorScheme),
                const SizedBox(height: 6),
                _buildRatingBar(4, distribution[4] ?? 0.0, colorScheme),
                const SizedBox(height: 6),
                _buildRatingBar(3, distribution[3] ?? 0.0, colorScheme),
                const SizedBox(height: 6),
                _buildRatingBar(2, distribution[2] ?? 0.0, colorScheme),
                const SizedBox(height: 6),
                _buildRatingBar(1, distribution[1] ?? 0.0, colorScheme),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$totalCount Ratings',
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
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

  Widget _buildRatingBar(int stars, double progress, ColorScheme colorScheme) {
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
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(ColorScheme colorScheme) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
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
                color: isSelected ? colorScheme.primary : colorScheme.surface,
                borderRadius: BorderRadius.circular(9999),
                border: isSelected
                    ? null
                    : Border.all(color: colorScheme.primary),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewList(List<Map<String, dynamic>> reviews, ColorScheme colorScheme) {
    if (reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.rate_review_outlined, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.1)),
              const SizedBox(height: 16),
              Text(
                _languageService.translate('no_reviews'),
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: reviews.map((review) {
          final timestamp = review['createdAt'] as Timestamp?;
          final dateStr = timestamp != null
              ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
              : 'Just now';

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildReviewCard(
              initials: review['userName']?.substring(0, 1).toUpperCase() ?? 'U',
              username: review['userName'] ?? 'User',
              date: dateStr,
              rating: (review['rating'] as num?)?.toInt() ?? 5,
              title: '',
              content: review['comment'] ?? '',
              helpfulCount: 0,
              bgColor: colorScheme.primary.withValues(alpha: 0.1),
              textColor: colorScheme.primary,
              borderColor: colorScheme.primary.withValues(alpha: 0.2),
              colorScheme: colorScheme,
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Map<String, dynamic>> _filterReviews(List<Map<String, dynamic>> reviews) {
    if (_selectedFilter == 'All') return reviews;
    int targetStars = int.parse(_selectedFilter.substring(0, 1));
    return reviews.where((r) => (r['rating'] as num?)?.toInt() == targetStars).toList();
  }

  Map<int, double> _calculateDistribution(List<Map<String, dynamic>> reviews) {
    if (reviews.isEmpty) return {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    
    Map<int, int> counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var review in reviews) {
      int rating = (review['rating'] as num?)?.toInt() ?? 0;
      if (rating >= 1 && rating <= 5) {
        counts[rating] = (counts[rating] ?? 0) + 1;
      }
    }
    
    return counts.map((key, value) => MapEntry(key, value / reviews.length));
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
    required ColorScheme colorScheme,
    Map<String, String>? developerResponse,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
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
                          color: colorScheme.onSurface,
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
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerHighest,
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
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
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
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: GoogleFonts.lexend(
              fontSize: 14,
              height: 1.6,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 13),
          const Divider(height: 1),
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
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
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
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          if (developerResponse != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 4, 12, 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(color: colorScheme.primary, width: 2),
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
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        developerResponse['date']!,
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
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
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
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
