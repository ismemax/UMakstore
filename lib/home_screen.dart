import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'models/app_model.dart';
import 'services/installer_service.dart';
import 'services/notification_service.dart';
import 'services/language_service.dart';
import 'services/device_service.dart';
import 'services/bookmark_service.dart';
import 'services/developer_service.dart';
import 'app_details_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'screenshots_screen.dart';
import 'reviews_screen.dart';
import 'widgets/update_message_widget.dart';
import 'widgets/shimmer_widget.dart';
import 'splash_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LanguageService _languageService = LanguageService();
  final InstallerService _installer = InstallerService();
  final NotificationService _notificationService = NotificationService();
  final DeviceService _deviceService = DeviceService();
  final BookmarkService _bookmarkService = BookmarkService();
  final DeveloperService _developerService = DeveloperService();
  int _selectedIndex = 0;
  int _initialSearchFilterIndex = 0;
  int _selectedTabIndex = 0;
  late Stream<List<AppModel>> _appsStream;
  List<AppModel>? _lastApps;
  bool _isPrecached = false;
  bool _isCompletingPrecache = false;

  StreamSubscription? _appsSubscription;

  @override
  void initState() {
    super.initState();
    _appsStream = _developerService.getStoreApps();
    if (!kIsWeb) {
      _initializeNotifications();
    }
    _loadApps();
    _preloadAppIcons();
    _checkForUpdates();
    _initializeLanguage();
    _initializeDeviceValidation();
    _installer.addListener(_updateState);
    _languageService.addListener(_updateState);
    _appsSubscription = _appsStream.listen((apps) {
      if (mounted) {
         _installer.updateAllStatuses(apps);
         // Force immediate UI update after status check
         Future.delayed(const Duration(milliseconds: 500), () {
           if (mounted) setState(() {});
         });
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

  void _initializeNotifications() {
    // Initialize notifications
  }

  void _loadApps() {
    // Load apps
  }

  void _preloadAppIcons() {
    // Preload app icons
  }

  void _checkForUpdates() {
    // Check for updates
  }

  void _initializeLanguage() {
    // Initialize language
  }

  void _initializeDeviceValidation() {
    // Initialize device validation
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: _selectedIndex == 0
            ? StreamBuilder<List<AppModel>>(
                  stream: _appsStream,
                  builder: (context, snapshot) {
                    final liveApps = snapshot.data ?? (_lastApps ?? []);
                    
                    // Logic to handle pre-caching only when data actually changes
                    if (snapshot.hasData) {
                      bool isNewData = _lastApps == null || _lastApps!.length != snapshot.data!.length;
                      if (!isNewData) {
                        for (int i = 0; i < liveApps.length; i++) {
                          final app = liveApps[i];
                          final lastApp = _lastApps![i];
                          
                          // More thorough check for ANY property change
                          if (app.id != lastApp.id || 
                              app.iconAsset != lastApp.iconAsset ||
                              app.screenshots.length != lastApp.screenshots.length ||
                              (app.screenshots.isNotEmpty && lastApp.screenshots.isNotEmpty && app.screenshots[0] != lastApp.screenshots[0])) {
                            isNewData = true;
                            debugPrint('Changes detected in app ${app.title}');
                            break;
                          }
                        }
                      }

                      if (isNewData && !_isCompletingPrecache) {
                        _isPrecached = false;
                        _isCompletingPrecache = true;
                        _precacheApps(liveApps);
                      }
                      
                      // Always update _lastApps to current data so the UI isn't stale
                      _lastApps = snapshot.data;
                    }

                    // Only show skeleton if we have literally nothing yet
                    if ((snapshot.connectionState == ConnectionState.waiting && _lastApps == null) || 
                        (!_isPrecached && _lastApps == null)) {
                      return RefreshIndicator(
                        onRefresh: () async {
                           // Trigger new fetch
                           setState(() {});
                           await Future.delayed(const Duration(seconds: 1));
                        },
                        child: _buildSkeletonLoading(),
                      );
                    }
  
                    if (liveApps.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                           // Allow manual forced update
                           _installer.updateAllStatuses(liveApps);
                           await Future.delayed(const Duration(seconds: 1));
                           if (mounted) setState(() {});
                        },
                        child: ListView( // Use ListView so it can pull-to-refresh
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            _buildHeader(),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.apps_outage_rounded, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.1)),
                                    const SizedBox(height: 16),
                                    Text(
                                      _languageService.translate('no_apps'),
                                      style: GoogleFonts.lexend(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Pull down to refresh or visit Developer Portal.',
                                      style: GoogleFonts.lexend(
                                        fontSize: 14,
                                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
  
                    return Column(
                      children: [
                        _buildHeader(),
                        _buildTabs(),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              await _installer.updateAllStatuses(liveApps);
                              await Future.delayed(const Duration(seconds: 1));
                              if (mounted) setState(() {});
                            },
                            child: _selectedTabIndex == 0
                                ? _buildForYouTab(liveApps)
                                : _buildTopRatedTab(liveApps),
                          ),
                        ),
                      ],
                    );
                  },
                )
            : (_selectedIndex == 1
                ? SearchScreen(initialFilterIndex: _initialSearchFilterIndex)
                : (_selectedIndex == 2 
                    ? const FavoritesScreen()
                    : ProfileScreen(
                        onTabSelected: (index) {
                          setState(() => _selectedIndex = index);
                        },
                      ))),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colorScheme.outlineVariant, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              if (index == 1) _initialSearchFilterIndex = 0;
            });
          },
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
          selectedLabelStyle: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.grid_view_rounded, size: 22, key: const Key('nav_home')),
              ),
              label: _languageService.translate('home'),
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.search_rounded, size: 22, key: const Key('nav_search')),
              ),
              label: _languageService.translate('search'),
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.bookmark_rounded, size: 22, key: const Key('nav_favorites')),
              ),
              label: _languageService.translate('favorites'),
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.person_outline_rounded, size: 22, key: const Key('nav_profile')),
              ),
              label: _languageService.translate('profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _languageService.translate('apps'),
            style: GoogleFonts.lexend(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              letterSpacing: -0.75,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        color: colorScheme.onSurface,
                        size: 20,
                      ),
                      StreamBuilder<int>(
                        stream: _notificationService.getUnreadCount(),
                        builder: (context, snapshot) {
                          final unreadCount = snapshot.data ?? 0;
                          if (unreadCount == 0) return const SizedBox.shrink();
                          
                          return Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xffef4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant, width: 1)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          _buildTab(_languageService.translate('for_you'), 0),
          const SizedBox(width: 24),
          _buildTab(_languageService.translate('top_rated'), 1),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    bool isSelected = _selectedTabIndex == index;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
          Container(
            height: 4,
            width: label == 'For You' ? 69 : 91,
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForYouTab(List<AppModel> apps) {
    if (apps.isEmpty) return const SizedBox.shrink();
    final featuredApp = apps[0];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildFeaturedAppCard(featuredApp),
          const SizedBox(height: 32),
          _buildHorizontalListSection(
            title1: 'For College of\n',
            title2: 'Computer and Information Science',
            apps: apps,
          ),
          const SizedBox(height: 32),
          _buildRecentlyUpdatedSection(apps),
        ],
      ),
    );
  }

  Widget _buildTopRatedTab(List<AppModel> apps) {
    // Sort apps by rating (highest first)
    final sortedApps = List<AppModel>.from(apps);
    sortedApps.sort((a, b) {
      try {
        final ratingA = double.tryParse(a.rating) ?? 0.0;
        final ratingB = double.tryParse(b.rating) ?? 0.0;
        return ratingB.compareTo(ratingA); // Descending order (highest first)
      } catch (e) {
        return 0;
      }
    });

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.62,
              ),
              itemCount: sortedApps.length,
              itemBuilder: (context, index) {
                final app = sortedApps[index];
                return _buildTopRatedAppCard(
                  rank: index + 1,
                  app: app,
                  isButtonOutlined: index > 0,
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _languageService.translate('browse_category'),
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildCategoryChip(
                  _languageService.translate('academic'),
                  Icons.school_rounded,
                  const Color(0xff3b82f6),
                  onTap: () => setState(() {
                    _initialSearchFilterIndex = 9; // Academic
                    _selectedIndex = 1;
                  }),
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  'CCIS',
                  Icons.code_rounded,
                  const Color(0xffef4444),
                  onTap: () => setState(() {
                    _initialSearchFilterIndex = 2; // CCIS
                    _selectedIndex = 1;
                  }),
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  'CBFS',
                  Icons.account_balance_rounded,
                  const Color(0xff10b981),
                  onTap: () => setState(() {
                    _initialSearchFilterIndex = 3; // CBFS
                    _selectedIndex = 1;
                  }),
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  _languageService.translate('utility'),
                  Icons.settings_suggest_rounded,
                  const Color(0xff64748b),
                  onTap: () => setState(() {
                    _initialSearchFilterIndex = 10; // Utility
                    _selectedIndex = 1;
                  }),
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  'COE',
                  Icons.history_edu_rounded,
                  const Color(0xfff59e0b),
                  onTap: () => setState(() {
                    _initialSearchFilterIndex = 5; // COE
                    _selectedIndex = 1;
                  }),
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  'COHS',
                  Icons.medical_services_rounded,
                  const Color(0xffef4444),
                  onTap: () => setState(() {
                    _initialSearchFilterIndex = 6; // COHS
                    _selectedIndex = 1;
                  }),
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  _languageService.translate('student_life'),
                  Icons.movie_rounded,
                  const Color(0xfff97316),
                  onTap: () => setState(() {
                    _initialSearchFilterIndex = 11; // Social
                    _selectedIndex = 1;
                  }),
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  'Gaming',
                  Icons.sports_esports_rounded,
                  const Color(0xffeab308),
                  onTap: () => setState(() {
                    _initialSearchFilterIndex = 12; // Gaming
                    _selectedIndex = 1;
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRatedAppCard({
    required int rank,
    required AppModel app,
    required bool isButtonOutlined,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppDetailsScreen(
              app: app,
            ),
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
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Text(
                  '#$rank',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 80, 
                    height: 80, 
                    child: app.iconData != null 
                        ? Icon(app.iconData, size: 40, color: app.themeColor ?? colorScheme.primary)
                        : (app.iconAsset.startsWith('http') 
                            ? Image.network(app.iconAsset, fit: BoxFit.contain)
                            : Icon(Icons.apps_rounded, size: 40, color: colorScheme.primary)),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        app.title,
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.publisher,
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xfffbbf24),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            app.rating,
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${app.reviews})',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTopRatedActionButton(app, isButtonOutlined, colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRatedActionButton(AppModel app, bool isButtonOutlined, ColorScheme colorScheme) {
    final status = app.status;
    final progress = app.progress;

    return GestureDetector(
      onTap: () {
        if (status == AppStatus.notInstalled) {
          _installer.installApp(app);
        } else if (status == AppStatus.installed) {
          _installer.launchApp(app);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isButtonOutlined ? Colors.transparent : colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
          border: isButtonOutlined
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: Text(
          status == AppStatus.downloading
              ? '${(progress * 100).toInt()}%'
              : (status == AppStatus.installed ? _languageService.translate('open') : _languageService.translate('install')),
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isButtonOutlined ? colorScheme.primary : colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData iconData, Color iconColor, {VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, color: iconColor, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedAppCard(AppModel app) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppDetailsScreen(
              app: app,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          height: 224,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 10),
                spreadRadius: -3,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Placeholder for background image (can be randomized or based on app theme)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: app.screenshots.isNotEmpty 
                    ? CachedNetworkImage(
                        imageUrl: _developerService.getOptimizedImageUrl(app.screenshots[0], width: 600),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: colorScheme.surface),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (app.themeColor ?? colorScheme.primary).withValues(alpha: 0.1),
                                colorScheme.surface,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (app.themeColor ?? colorScheme.primary).withValues(alpha: 0.1),
                              colorScheme.surface,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                ),
              ),
              // Gradient overlay at the bottom
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          colorScheme.shadow.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: app.themeColor ?? const Color(0xff2094f3),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: (app.themeColor ?? const Color(0xff2094f3)).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'FEATURED APP',
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 64,
                           height: 64,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: app.iconData != null 
                              ? Icon(app.iconData, color: app.themeColor ?? const Color(0xffef4444), size: 32)
                              : (app.iconAsset.startsWith('http')
                                ? Image.network(app.iconAsset, width: 32, height: 32)
                                : Icon(Icons.apps_rounded, color: colorScheme.primary, size: 32)),
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
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(color: colorScheme.shadow.withValues(alpha: 0.8), blurRadius: 4, offset: const Offset(0, 1)),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                app.description,
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  color: colorScheme.shadow.withValues(alpha: 0.6),
                                  shadows: [
                                    Shadow(color: colorScheme.shadow.withValues(alpha: 0.8), blurRadius: 4, offset: const Offset(0, 1)),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (app.status == AppStatus.notInstalled) {
                                _installer.installApp(app);
                              } else if (app.status == AppStatus.installed) {
                                _installer.launchApp(app);
                              }
                            },
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: app.themeColor ?? const Color(0xff2094f3),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: (app.themeColor ?? const Color(0xff2094f3)).withValues(alpha: 0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 10),
                                    spreadRadius: -3,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    app.status == AppStatus.installed
                                        ? Icons.open_in_new_rounded
                                        : Icons.download_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    app.status == AppStatus.downloading
                                        ? '${(app.progress * 100).toInt()}%'
                                        : (app.status == AppStatus.installed
                                            ? 'Open'
                                            : 'Install'),
                                    style: GoogleFonts.lexend(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        StreamBuilder<bool>(
                          stream: _bookmarkService.isBookmarked(app.id),
                          builder: (context, snapshot) {
                            final isBookmarked = snapshot.data ?? false;
                            return Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colorScheme.outlineVariant),
                              ),
                              child: Center(
                                child: GestureDetector(
                                  onTap: () async {
                                    await _bookmarkService.toggleBookmark(app.id);
                                  },
                                  child: Icon(
                                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                                    color: isBookmarked ? Colors.blue : (app.themeColor ?? colorScheme.primary),
                                    size: 20,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalListSection({
    required String title1,
    required String title2,
    required List<AppModel> apps,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      height: 1.375,
                    ),
                    children: [
                      TextSpan(text: title1),
                      TextSpan(
                        text: title2,
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = 1),
                child: Text(
                  'See All',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 232,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: apps.map((app) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _buildAppCardSmall(app: app),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAppCardSmall({
    required AppModel app,
  }) {
    final title = app.title;
    final rating = app.rating;
    final iconData = app.iconData ?? Icons.apps_rounded;
    final iconColor = app.themeColor ?? const Color(0xff3b82f6);
    final category = app.category;
    final colorScheme = Theme.of(context).colorScheme;
    final isInstalled = app.status == AppStatus.installed;
    final isDownloading = app.status == AppStatus.downloading;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppDetailsScreen(
              app: app,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 144,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 144,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: app.screenshots.isNotEmpty 
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: _developerService.getOptimizedImageUrl(app.screenshots[0], width: 300),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: colorScheme.surface),
                                errorWidget: (context, url, error) => Container(
                                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                ),
                              ),
                              // Scrim for readability
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      colorScheme.shadow.withValues(alpha: 0.7),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.surfaceContainerHighest,
                                  colorScheme.surface,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                    ),
                  ),
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              colorScheme.surface.withValues(alpha: 0.6),
                              colorScheme.surface.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: app.iconAsset.startsWith('http')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CachedNetworkImage(
                                imageUrl: _developerService.getOptimizedImageUrl(app.iconAsset, width: 64, height: 64),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: colorScheme.surface),
                                errorWidget: (context, url, error) => Icon(Icons.apps_rounded, size: 16, color: colorScheme.primary),
                              ),
                            )
                          : Icon(iconData, color: iconColor, size: 16),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: StreamBuilder<bool>(
                      stream: _bookmarkService.isBookmarked(app.id),
                      builder: (context, snapshot) {
                        final isBookmarked = snapshot.data ?? false;
                        return GestureDetector(
                          onTap: () async {
                            await _bookmarkService.toggleBookmark(app.id);
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                            ),
                            child: Center(
                              child: Icon(
                                isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                                color: isBookmarked ? Colors.blue : colorScheme.primary,
                                size: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  category,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 2,
                  height: 2,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xfffbbf24),
                  size: 12,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isInstalled ? colorScheme.primary.withValues(alpha: 0.1) : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(9999),
                border: isInstalled ? Border.all(color: colorScheme.primary.withValues(alpha: 0.2)) : null,
              ),
              child: Text(
                isDownloading 
                    ? '${(app.progress * 100).toInt()}%'
                    : (isInstalled ? _languageService.translate('open') : _languageService.translate('get')),
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyUpdatedSection(List<AppModel> apps) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recently Updated',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = 1),
                child: Text(
                  'See All',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: apps.map((app) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildListAppCard(app: app),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildListAppCard({
    required AppModel app,
  }) {
    final title = app.title;
    final subtitle = app.publisher;
    final version = 'v${app.version}';
    final timeAgo = 'Just now';
    final iconColor = app.themeColor ?? const Color(0xff3b82f6);
    final iconData = app.iconData ?? Icons.apps_rounded;
    final isInstalled = app.status == AppStatus.installed;
    final isDownloading = app.status == AppStatus.downloading;
    final actionText = isDownloading 
        ? '${(app.progress * 100).toInt()}%' 
        : (isInstalled ? _languageService.translate('open') : _languageService.translate('get'));
    final isUpdate = app.status == AppStatus.updateAvailable;
    
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppDetailsScreen(
              app: app,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              child: app.iconAsset.startsWith('http')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(app.iconAsset, width: 64, height: 64, fit: BoxFit.cover),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: iconColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(iconData, color: Colors.white, size: 32),
                  ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff22c55e).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xff22c55e).withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          version,
                          style: GoogleFonts.lexend(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff22c55e),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeAgo,
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildActionButton(actionText, isUpdate || isInstalled, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, bool isHighlight, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlight ? colorScheme.primary.withValues(alpha: 0.1) : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: isHighlight ? Border.all(color: colorScheme.primary.withValues(alpha: 0.2)) : Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        text,
        style: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isHighlight ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  
  
  Future<void> _precacheApps(List<AppModel> apps) async {
    if (!mounted) return;
    
    try {
      final List<Future<void>> futures = [];
      for (var app in apps) {
        // Precache Icons
        if (app.iconAsset.startsWith('http')) {
          futures.add(precacheImage(NetworkImage(app.iconAsset), context));
        }
        // Precache Screenshots (at least the first one)
        if (app.screenshots.isNotEmpty && app.screenshots[0].startsWith('http')) {
          futures.add(precacheImage(NetworkImage(app.screenshots[0]), context));
        }
      }
      
      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }
      
      if (mounted) {
        setState(() {
          _isPrecached = true;
          _isCompletingPrecache = false;
        });
      }
    } catch (e) {
      debugPrint('Error precaching images: $e');
      if (mounted) {
        setState(() {
          _isPrecached = true;
          _isCompletingPrecache = false;
        });
      }
    }
  }

  Widget _buildSkeletonLoading() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        _buildHeader(),
        _buildTabs(),
        Expanded(
          child: ShimmerWidget.fromColors(
            baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(height: 24, width: 150, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Container(width: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(height: 24, width: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 16),
                  ...List.generate(3, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(height: 16, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                              const SizedBox(height: 8),
                              Container(height: 12, width: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
