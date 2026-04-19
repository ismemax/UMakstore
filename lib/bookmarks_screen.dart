import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/bookmark_service.dart';
import 'services/developer_service.dart';
import 'services/installer_service.dart';
import 'services/language_service.dart';
import 'models/app_model.dart';
import 'app_details_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final LanguageService _languageService = LanguageService();
  final BookmarkService _bookmarkService = BookmarkService();
  final DeveloperService _developerService = DeveloperService();
  late InstallerService _installer;
  StreamSubscription? _appsSubscription;
  late Stream<List<AppModel>> _appsStream;

  @override
  void initState() {
    super.initState();
    _installer = InstallerService();
    _installer.addListener(_updateState);
    _languageService.addListener(_updateState);
    _appsStream = _developerService.getStoreApps();

    // Subscribe to update statuses whenever new apps arrive
    _appsSubscription = _appsStream.listen((apps) {
      if (mounted) {
        _installer.updateAllStatuses(apps);
      }
    });
  }

  @override
  void dispose() {
    _appsSubscription?.cancel();
    _installer.removeListener(_updateState);
    _languageService.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

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
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Bookmarks',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            letterSpacing: -0.45,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: colorScheme.outlineVariant, height: 1.0),
        ),
      ),
      body: StreamBuilder<List<AppModel>>(
        stream: _developerService.getStoreApps(),
        builder: (context, appsSnapshot) {
          return StreamBuilder<List<String>>(
            stream: _bookmarkService.getBookmarkedAppIds(),
            builder: (context, bookmarksSnapshot) {
              if (appsSnapshot.connectionState == ConnectionState.waiting ||
                  bookmarksSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (appsSnapshot.hasError || bookmarksSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading bookmarks',
                    style: GoogleFonts.lexend(color: colorScheme.error),
                  ),
                );
              }

              final allApps = appsSnapshot.data ?? [];
              final bookmarkedIds = bookmarksSnapshot.data ?? [];
              final bookmarkedApps = allApps
                  .where((app) => bookmarkedIds.contains(app.id))
                  .toList();

              if (bookmarkedApps.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                itemCount: bookmarkedApps.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'SAVED APPS',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          letterSpacing: 1.2,
                        ),
                      ),
                    );
                  }
                  final app = bookmarkedApps[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildBookmarkItem(context, app),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_outline_rounded,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'No bookmarks yet',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Apps you bookmark will appear here.',
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkItem(BuildContext context, AppModel app) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppDetailsScreen(app: app),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: app.iconAsset.startsWith('http')
                    ? Image.network(app.iconAsset, fit: BoxFit.cover)
                    : Icon(Icons.widgets_rounded, 
                        color: colorScheme.primary, size: 32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          app.title,
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.bookmark_rounded, 
                          color: colorScheme.primary, size: 24),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          await _bookmarkService.toggleBookmark(app.id);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    app.publisher,
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (app.status == AppStatus.installed) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xff22c55e).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xff22c55e).withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'INSTALLED',
                        style: GoogleFonts.lexend(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff22c55e),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        app.rating,
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xfffbbf24),
                        size: 14,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        app.category,
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  if (app.status == AppStatus.installed) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _installer.launchApp(app),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: Text(
                          _languageService.translate('open'),
                          style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.bold),
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
}
