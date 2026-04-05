import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/developer_service.dart';
import 'services/bookmark_service.dart';
import 'models/app_model.dart';
import 'app_details_screen.dart';
import 'services/auth_service.dart';
import 'services/installer_service.dart';
import 'services/language_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final LanguageService _languageService = LanguageService();
  late InstallerService _installer;
  StreamSubscription? _appsSubscription;
  late Stream<List<AppModel>> _appsStream;

  @override
  void initState() {
    super.initState();
    _installer = InstallerService();
    _installer.addListener(_updateState);
    _languageService.addListener(_updateState);
    _appsStream = DeveloperService().getStoreApps();

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

    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: StreamBuilder<List<AppModel>>(
            stream: _appsStream,
            builder: (context, appsSnapshot) {
              return StreamBuilder<List<String>>(
                stream: BookmarkService().getBookmarkedAppIds(),
                builder: (context, bookmarksSnapshot) {
                  if (appsSnapshot.hasError || bookmarksSnapshot.hasError) {
                    final error = appsSnapshot.error ?? bookmarksSnapshot.error;
                    final isPermissionDenied =
                        error.toString().contains('PERMISSION_DENIED');

                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isPermissionDenied
                                  ? Icons.lock_person_rounded
                                  : Icons.error_outline_rounded,
                              size: 64,
                              color: colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isPermissionDenied ? _languageService.translate('access_denied') : 'Error',
                              style: GoogleFonts.lexend(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isPermissionDenied
                                  ? "Missing permissions to access favorites. Please check your setup."
                                  : 'Failed to load: $error',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lexend(
                                  color: colorScheme.onSurface.withOpacity(0.6)),
                            ),
                            if (isPermissionDenied) ...[
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => AuthService().signOutUser(),
                                child: const Text('Sign Out & Retry'),
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  }

                  if (appsSnapshot.connectionState == ConnectionState.waiting ||
                      bookmarksSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allApps = appsSnapshot.data ?? [];
                  final bookmarkedIds = bookmarksSnapshot.data ?? [];
                  final favoriteApps =
                      allApps.where((app) => bookmarkedIds.contains(app.id)).toList();

                  if (favoriteApps.isEmpty) {
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
                            _languageService.translate('no_favorites'),
                            style: GoogleFonts.lexend(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Save apps you love to find them later.',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              color: colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favoriteApps.length,
                    itemBuilder: (context, index) {
                      final app = favoriteApps[index];
                      return _buildFavoriteCard(context, app);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: colorScheme.surface,
      child: Row(
        children: [
          Text(
            _languageService.translate('favorites'),
            style: GoogleFonts.lexend(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              letterSpacing: -0.75,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, AppModel app) {
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: app.iconAsset.startsWith('http')
                    ? Image.network(app.iconAsset, fit: BoxFit.cover)
                    : Icon(Icons.apps_rounded, color: colorScheme.primary, size: 32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.title,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    app.publisher,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (app.status == AppStatus.installed)
                    Text(
                      'INSTALLED',
                      style: GoogleFonts.lexend(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff22c55e),
                        letterSpacing: 0.5,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.bookmark_rounded, color: colorScheme.primary),
              onPressed: () async {
                final success = await BookmarkService().toggleBookmark(app.id);
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to remove bookmark.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
