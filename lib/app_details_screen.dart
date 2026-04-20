import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reviews_screen.dart';
import 'write_review_screen.dart';
import 'widgets/full_screen_image.dart';
import 'models/app_model.dart';
import 'services/installer_service.dart';
import 'services/developer_service.dart';
import 'services/bookmark_service.dart';
import 'services/language_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A comprehensive view of a single application's metadata, reviews, and installation options.
/// 
/// This screen coordinates the [flutter_downloader] for APK retrieval and 
/// enables user interaction with Cloudinary screenshots and Firestore reviews.
class AppDetailsScreen extends StatefulWidget {
  final AppModel app;
  const AppDetailsScreen({super.key, required this.app});

  @override
  State<AppDetailsScreen> createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends State<AppDetailsScreen> {
  final LanguageService _languageService = LanguageService();
  late InstallerService _installer;
  Future<Map<String, dynamic>?>? _userReviewFuture;
  late ColorScheme _colorScheme;

  @override
  void initState() {
    super.initState();
    _installer = InstallerService();
    _installer.addListener(_updateState);
    _languageService.addListener(_updateState);
    // Verify current status on entry
    _installer.updateAppStatus(widget.app);
    _loadUserReview();
  }

  void _loadUserReview() {
    setState(() {
      _userReviewFuture = DeveloperService().getUserReview(widget.app.id);
    });
  }

  @override
  void dispose() {
    _installer.removeListener(_updateState);
    _languageService.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) {
      if (widget.app.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.app.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        // Clear it so it doesn't show again
        widget.app.errorMessage = null;
      }
      setState(() {});
    }
  }

  void _onInstallPressed() {
    _installer.installApp(widget.app);
  }

  @override
  Widget build(BuildContext context) {
    _colorScheme = Theme.of(context).colorScheme;
    final colorScheme = _colorScheme;
        
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: colorScheme.primary,
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          StreamBuilder<bool>(
            stream: BookmarkService().isBookmarked(widget.app.id),
            builder: (context, snapshot) {
              final isBookmarked = snapshot.data ?? false;
              return IconButton(
                icon: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color: isBookmarked
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 24,
                ),
                onPressed: () async {
                  final success = await BookmarkService().toggleBookmark(widget.app.id);
                  if (mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isBookmarked
                            ? _languageService.translate('bookmark_removed')
                            : _languageService.translate('bookmark_added')),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              );
            },
          ),
          if (widget.app.status == AppStatus.installed)
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: colorScheme.error,
                size: 24,
              ),
              onPressed: () => _showUninstallConfirmationDialog(context),
            ),
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildStats(),
            _buildActionButtons(),
            _buildDataRetentionInfo(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
            ),
            _buildPreviewSection(context),
            if (widget.app.permissions.isNotEmpty) ...[
              const SizedBox(height: 32),
              _buildPermissionsSection(context),
            ],
            const SizedBox(height: 32),
            _buildAboutSection(context),
            const SizedBox(height: 32),
            _buildRatingsSection(context),
            const SizedBox(height: 32),
            _buildDeveloperSection(),
            const SizedBox(height: 48),
            _buildFooter(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = _colorScheme;
    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: Hero(
            tag: 'app_icon_${widget.app.id}',
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: widget.app.iconAsset.startsWith('http')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: CachedNetworkImage(
                      imageUrl: DeveloperService.getOptimizedUrl(widget.app.iconAsset, width: 240, height: 240),
                      width: 120, 
                      height: 120, 
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.1)),
                      errorWidget: (context, url, error) => Icon(Icons.apps_rounded, size: 48, color: colorScheme.outline),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.app.iconData ?? Icons.apps_rounded,
                            color: colorScheme.onPrimary,
                            size: 48,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'APPLICATION',
                            style: GoogleFonts.lexend(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary.withValues(alpha: 0.8),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          widget.app.title,
          style: GoogleFonts.lexend(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            widget.app.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStats() {
    final colorScheme = _colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem('${widget.app.rating} ★', _languageService.translate('stat_rating')),
          _buildStatDivider(),
          _buildStatItem('${widget.app.reviews}+', _languageService.translate('stat_reports')),
          _buildStatDivider(),
          _buildStatItem(widget.app.size, _languageService.translate('stat_size')),
          _buildStatDivider(),
          _buildStatItem(widget.app.category, _languageService.translate('stat_category')),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    final colorScheme = _colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 24, width: 1, color: _colorScheme.outlineVariant);
  }

  Widget _buildActionButtons() {
    final colorScheme = _colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.app.status == AppStatus.notInstalled) {
                  _onInstallPressed();
                } else if (widget.app.status == AppStatus.installed) {
                  _installer.launchApp(widget.app);
                }
              },
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                      spreadRadius: -3,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    if (widget.app.status == AppStatus.downloading)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            value: widget.app.progress == -1.0
                                ? null
                                : widget.app.progress,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                    Center(
                      child: Text(
                        widget.app.status == AppStatus.downloading
                            ? (widget.app.progress == -1.0
                                ? _languageService.translate('downloading')
                                : '${(widget.app.progress * 100).toInt()}%')
                            : (widget.app.status == AppStatus.installing
                                ? _languageService.translate('installing')
                                : (widget.app.status == AppStatus.installed
                                    ? _languageService.translate('open')
                                    : (widget.app.isInLibrary ? _languageService.translate('reinstall') : _languageService.translate('install')))),
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          StreamBuilder<bool>(
            stream: BookmarkService().isBookmarked(widget.app.id),
            builder: (context, snapshot) {
              final isBookmarked = snapshot.data ?? false;

              return GestureDetector(
                onTap: () async {
                  final success = await BookmarkService().toggleBookmark(widget.app.id);
                  if (mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isBookmarked
                            ? _languageService.translate('bookmark_removed')
                            : _languageService.translate('bookmark_added')),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant, width: 2),
                  ),
                  child: Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isBookmarked ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataRetentionInfo() {
    if (widget.app.status != AppStatus.installed) return const SizedBox.shrink();
    final colorScheme = _colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded,
                size: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You can choose to keep your app data when uninstalling to preserve your settings.',
                style: GoogleFonts.lexend(
                  fontSize: 11,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(BuildContext context) {
    final colorScheme = _colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _languageService.translate('preview'),
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (widget.app.screenshots.isEmpty)
                Text(
                  _languageService.translate('screenshots_soon'),
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: widget.app.screenshots.isNotEmpty
            ? ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: widget.app.screenshots.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildRealScreenshot(context, widget.app.screenshots[index], index),
                  );
                },
              )
            : ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildScreenshotPlaceholder(context, 'Core Interface'),
                  const SizedBox(width: 16),
                  _buildScreenshotPlaceholder(context, 'Data Visualization'),
                  const SizedBox(width: 16),
                  _buildScreenshotPlaceholder(context, 'Settings & Profile'),
                ],
              ),
        ),
      ],
    );
  }

  Widget _buildRealScreenshot(BuildContext context, String url, int index) {
    final colorScheme = _colorScheme;
    final tag = 'preview_${widget.app.id}_$index';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImage(imageUrl: url, tag: tag),
          ),
        );
      },
      child: Hero(
        tag: tag,
        child: Container(
          width: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: DeveloperService.getOptimizedUrl(url, width: 400),
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                ),
              ),
              errorWidget: (context, url, error) => Center(
                child: Icon(Icons.broken_image_outlined, color: colorScheme.outline),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreenshotPlaceholder(BuildContext context, String label) {
    final colorScheme = _colorScheme;
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, color: colorScheme.onSurface.withValues(alpha: 0.2), size: 32),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final colorScheme = _colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _languageService.translate('about_app'),
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.app.description,
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(Icons.verified_user_outlined, 'Secure Deployment'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.update_rounded, 'Latest Version ${widget.app.version}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    final colorScheme = _colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.lexend(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingsSection(BuildContext context) {
    final colorScheme = _colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewsScreen(app: widget.app),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      _languageService.translate('ratings_reviews'),
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WriteReviewScreen(
                        appId: widget.app.id,
                        appName: widget.app.title,
                        iconUrl: widget.app.iconAsset,
                      ),
                    ),
                  );
                  _loadUserReview();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_note_rounded, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      FutureBuilder<Map<String, dynamic>?>(
                        future: _userReviewFuture,
                        builder: (context, snapshot) {
                          final hasReviewed = snapshot.data != null;
                          return Text(
                            hasReviewed ? _languageService.translate('edit_review') : _languageService.translate('write_review'),
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: DeveloperService().getAppReviews(widget.app.id),
            builder: (context, snapshot) {
              final reviews = snapshot.data ?? [];
              final distribution = _calculateDistribution(reviews);
              final total = reviews.length;

              return Column(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            widget.app.rating,
                            style: GoogleFonts.lexend(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _languageService.translate('out_of_5'),
                            style: GoogleFonts.lexend(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            _buildRatingBar(5, distribution[5] ?? 0.0),
                            const SizedBox(height: 8),
                            _buildRatingBar(4, distribution[4] ?? 0.0),
                            const SizedBox(height: 8),
                            _buildRatingBar(3, distribution[3] ?? 0.0),
                            const SizedBox(height: 8),
                            _buildRatingBar(2, distribution[2] ?? 0.0),
                            const SizedBox(height: 8),
                            _buildRatingBar(1, distribution[1] ?? 0.0),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '$total ${_languageService.translate('stat_reports')}',
                                style: GoogleFonts.lexend(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (reviews.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.rate_review_outlined, size: 48, color: colorScheme.onSurface.withValues(alpha: 0.1)),
                          const SizedBox(height: 16),
                          Text(
                            _languageService.translate('no_reviews'),
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              color: colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...reviews.take(3).map((review) {
                      final timestamp = review['createdAt'] as Timestamp?;
                      final dateStr = timestamp != null
                        ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
                        : 'Just now';
                        
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildReviewCard(
                          review['userName'] ?? 'User',
                          dateStr,
                          '', // Title
                          review['comment'] ?? '',
                          (review['rating'] as num?)?.toInt() ?? 5,
                        ),
                      );
                    }).toList(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int star, double percent) {
    final colorScheme = _colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 12,
          child: Text(
            '$star',
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.star_rounded, color: colorScheme.onSurface.withValues(alpha: 0.5), size: 10),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              if (percent > 0)
                FractionallySizedBox(
                  widthFactor: percent,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(
    String user,
    String date,
    String title,
    String content,
    int rating,
  ) {
    final colorScheme = _colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      user.isEmpty ? 'U' : user[0].toUpperCase(),
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user,
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star_rounded,
                    color: index < rating
                        ? const Color(0xffFFC107)
                        : colorScheme.outlineVariant,
                    size: 14,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.lexend(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: GoogleFonts.lexend(
              fontSize: 10,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection() {
    final colorScheme = _colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEVELOPER',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.code_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.app.publisher,
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.verified_rounded, size: 14, color: colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Verified Publisher',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildFooterLink(Icons.privacy_tip_outlined, 'Privacy Policy'),
              const SizedBox(width: 24),
              _buildFooterLink(Icons.description_outlined, 'Terms of Service'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(IconData icon, String label) {
    final colorScheme = _colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final colorScheme = _colorScheme;
    return Center(
      child: Column(
        children: [
          Text(
            'Version ${widget.app.version}',
            style: GoogleFonts.lexend(
              fontSize: 12, 
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.4)
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Managed Deployment • PolyStore Certification',
            style: GoogleFonts.lexend(
              fontSize: 10, 
              color: colorScheme.onSurface.withValues(alpha: 0.3)
            ),
          ),
        ],
      ),
    );
  }

  void _showUninstallConfirmationDialog(BuildContext context) {
    final colorScheme = _colorScheme;
    bool keepData = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              title: Text(
                'Uninstall ${widget.app.title}?',
                softWrap: true,
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: colorScheme.onSurface,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChecklistItem(Icons.delete_sweep_outlined, 'Removes app files from your device', true),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => setState(() => keepData = !keepData),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: keepData ? colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            keepData ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            color: keepData ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Keep ${widget.app.size} of app data',
                                  softWrap: true,
                                  style: GoogleFonts.lexend(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  'Recommended if you reinstall later',
                                  softWrap: true,
                                  style: GoogleFonts.lexend(
                                    fontSize: 11,
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildChecklistItem(Icons.library_books_outlined, 'Keeps record in your library', true),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'CANCEL',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (keepData) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Note: Tap "Keep data" in the system prompt below!',
                            softWrap: true,
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                    final error = await _installer.uninstallApp(widget.app);
                    if (error != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    'UNINSTALL',
                    style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPermissionsSection(BuildContext context) {
    final colorScheme = _colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security_rounded, color: colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                'PERMISSIONS REQUIRED',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This application requests access to the following features on your device:',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.app.permissions.map((p) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      p,
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(IconData icon, String text, bool checked) {
    final colorScheme = _colorScheme;
    return Row(
      children: [
        Icon(
          checked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 20,
          color: checked ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.2),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            softWrap: true,
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
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
}
