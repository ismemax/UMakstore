import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'updates_screen.dart';
import 'services/installer_service.dart';
import 'services/developer_service.dart';
import 'models/app_model.dart';
import 'app_details_screen.dart';

class ManageAppsScreen extends StatefulWidget {
  final Function(int)? onTabSelected;
  const ManageAppsScreen({super.key, this.onTabSelected});

  @override
  State<ManageAppsScreen> createState() => _ManageAppsScreenState();
}

class _ManageAppsScreenState extends State<ManageAppsScreen> {
  late InstallerService _installer;
  bool _isLoadingStorage = true;
  StreamSubscription? _appsSubscription;
  StreamSubscription? _bookmarksSubscription;
  late Stream<List<AppModel>> _appsStream;
  final ValueNotifier<List<AppModel>?> _appsNotifier = ValueNotifier(null);
  List<String> _bookmarkedIds = [];
  Set<String> _selectedAppIds = {}; // For multi-select batches
  bool _showTroubleshooting = false;
  bool _isRecentlyUsedFilterActive = false; // Simulated sort toggle
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    debugPrint('ManageAppsScreen: Initializing Marketplace connection...');
    _installer = InstallerService();
    _installer.addListener(_onInstallerUpdate);
    
    _appsStream = DeveloperService().getStoreApps().asBroadcastStream();
    _startPrimingFetch();
    _startTroubleshootingTimer();

    // Persist data in ValueNotifier to avoid "Broadcast Stream misses" in the UI
    _appsSubscription = _appsStream.listen((apps) {
      if (mounted) {
        debugPrint('ManageAppsScreen: Received ${apps.length} apps. Updating Notifier.');
        _appsNotifier.value = apps;
        _installer.updateAllStatuses(apps);
      }
    });

    // Subscribe to bookmarks for the current user
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _bookmarksSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .snapshots()
          .listen((snapshot) {
            if (mounted) {
              setState(() {
                _bookmarkedIds = snapshot.docs.map((doc) => doc.id).toList();
              });
            }
          });
    }
    
    _fetchStorageInfo();
  }

  void _startPrimingFetch() {
    FirebaseFirestore.instance
        .collection('submitted_apps')
        .limit(1)
        .get(const GetOptions(source: Source.serverAndCache))
        .then((snapshot) {
           debugPrint('ManageAppsScreen: Priming successful - ${snapshot.docs.length} docs found.');
        }).catchError((e) {
           debugPrint('ManageAppsScreen: Priming failed - $e');
        });
  }

  void _startTroubleshootingTimer() {
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 6), () {
      debugPrint('ManageAppsScreen: Troubleshooting timer fired. StorageLoaded: $_isLoadingStorage, Mounted: $mounted');
      if (mounted && _isLoadingStorage == false) {
         debugPrint('ManageAppsScreen: Showing troubleshooting options after timeout.');
         setState(() => _showTroubleshooting = true);
      }
    });
  }

  void _onInstallerUpdate() {
    if (mounted) setState(() {});
  }

  double _totalSpace = 64.0; 
  double _usedSpace = 48.0;
  double _freeSpace = 16.0;

  Future<void> _fetchStorageInfo() async {
    const channel = MethodChannel('com.tbl.makstore/storage');
    try {
      final Map<dynamic, dynamic>? result = await channel.invokeMethod('getStorageInfo');
      if (result != null && mounted) {
        setState(() {
          // Convert bytes to GB
          _totalSpace = (result['totalSpace'] as int) / (1024 * 1024 * 1024);
          _freeSpace = (result['freeSpace'] as int) / (1024 * 1024 * 1024);
          _usedSpace = _totalSpace - _freeSpace;
          _isLoadingStorage = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching storage: $e');
      if (mounted) setState(() => _isLoadingStorage = false);
    }
  }

  @override
  void dispose() {
    _appsSubscription?.cancel();
    _bookmarksSubscription?.cancel();
    _loadingTimer?.cancel();
    _installer.removeListener(_onInstallerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xff0f172a), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Manage Apps & Device',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xff0f172a),
              letterSpacing: -0.45,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                height: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xfff1f5f9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  dividerColor: Colors.transparent,
                  labelColor: const Color(0xff2094f3),
                  unselectedLabelColor: const Color(0xff64748b),
                  labelStyle: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500),
                  unselectedLabelStyle: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Manage'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                _buildOverviewTab(),
                _buildManageTab(),
              ],
            ),
            // Bottom Navigation (Visible when no apps are selected)
            if (_selectedAppIds.isEmpty) Positioned(
              bottom: 0, left: 0, right: 0,
              child: _buildBottomNav(),
            ),
            // Floating Action Button for Uninstallation (Visible when apps are selected)
            if (_selectedAppIds.isNotEmpty) Positioned(
              bottom: 40, left: 16, right: 16,
              child: _buildUninstallFloatingButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ValueListenableBuilder<List<AppModel>?>(
      valueListenable: _appsNotifier,
      builder: (context, apps, _) {
        final installedApps = (apps ?? []).where((a) => a.status == AppStatus.installed).toList();
        final updateApps = (apps ?? []).where((a) => a.status == AppStatus.updateAvailable).toList();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Status Card
              _buildStatusCard(updateApps.length),
              const SizedBox(height: 24),
              
              // 2. Storage Card
              _buildStorageCard(),
              const SizedBox(height: 24),
              
              // 3. Recently Updated
              if (installedApps.isNotEmpty) ...[
                _buildSectionHeader('Recently Updated'),
                const SizedBox(height: 8),
                _buildRecentlyUpdatedList(installedApps.take(2).toList()),
                const SizedBox(height: 24),
              ],
              
              // 4. Ratings & Reviews
              _buildLargeActionCard(
                icon: Icons.star_outline_rounded,
                title: 'Ratings & Reviews',
                subtitle: 'Manage your posted reviews',
                onTap: () {
                   // Navigate to reviews
                },
              ),
              const SizedBox(height: 120),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(int updateCount) {
    final bool allUpToDate = updateCount == 0;
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe2e8f0)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: allUpToDate ? const Color(0xfff0fdf4) : const Color(0xfffef2f2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              allUpToDate ? Icons.check_circle_outline_rounded : Icons.system_update_rounded, 
              color: allUpToDate ? const Color(0xff10b981) : const Color(0xffef4444), 
              size: 20
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allUpToDate ? 'All apps are up to date' : 'Updates available',
                  style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xff1e293b)),
                ),
                Text(
                  allUpToDate ? 'Last checked: 1 hour ago' : '$updateCount pending updates', 
                  style: GoogleFonts.lexend(fontSize: 14, color: const Color(0xff64748b))
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe2e8f0)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storage_rounded, size: 16, color: Color(0xff1e293b)),
              const SizedBox(width: 12),
              Text('Storage', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xff1e293b))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${_usedSpace.toStringAsFixed(0)}GB ', style: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xff1e293b))),
                  Text('used', style: GoogleFonts.lexend(fontSize: 14, color: const Color(0xff64748b))),
                ],
              ),
              Text('${_totalSpace.toStringAsFixed(0)}GB total', style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xff64748b))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: _totalSpace > 0 ? (_usedSpace / _totalSpace) : 0,
              backgroundColor: const Color(0xfff1f5f9),
              color: const Color(0xff2094f3),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Text('${_freeSpace.toStringAsFixed(0)}GB free for new apps and data', style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xff64748b))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xff1e293b))),
        TextButton(onPressed: () {}, child: Text('See all', style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xff2094f3)))),
      ],
    );
  }

  Widget _buildRecentlyUpdatedList(List<AppModel> apps) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe2e8f0)),
      ),
      child: Column(
        children: apps.asMap().entries.map((entry) {
          final index = entry.key;
          final app = entry.value;
          return Column(
            children: [
              _buildRecentlyUpdatedItem(app),
              if (index < apps.length - 1) Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: const Color(0xfff1f5f9)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentlyUpdatedItem(AppModel app) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildAppIcon(app),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.title, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xff1e293b))),
                Text('Updated 1 hour ago • ${app.size}', style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xff64748b))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xff64748b)),
        ],
      ),
    );
  }

  Widget _buildLargeActionCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffe2e8f0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xff64748b)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xff1e293b))),
                  Text(subtitle, style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xff64748b))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xff64748b)),
          ],
        ),
      ),
    );
  }

  Widget _buildManageTab() {
    return ValueListenableBuilder<List<AppModel>?>(
      valueListenable: _appsNotifier,
      builder: (context, allApps, child) {
        try {
          // Show loading state if we have no data and haven't timed out yet
          if (allApps == null) {
             return _buildLoadingState();
          }

          final displayApps = [...allApps];
          
          // Apply local bookmarks status
          for (var app in displayApps) {
            if (_bookmarkedIds.contains(app.id)) app.isInLibrary = true;
          }

          final installedApps = displayApps.where((app) => app.status == AppStatus.installed).toList();
          
          // Simulated filter: if "Recently used" is active, we just show installed ones (or sort them if data were real)
          if (_isRecentlyUsedFilterActive) {
             // In a real app, you would sort by last_used here.
          }

          final libraryApps = displayApps.where((app) => app.isInLibrary && app.status != AppStatus.installed).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildFilterBar(installedApps),
              const SizedBox(height: 16),
              if (installedApps.isEmpty && libraryApps.isEmpty) _buildNoAppsState(),
              
              ...installedApps.map((app) => _buildManageAppCard(
                app: app,
                isSelected: _selectedAppIds.contains(app.id),
                onToggle: () {
                  setState(() {
                    if (_selectedAppIds.contains(app.id)) {
                      _selectedAppIds.remove(app.id);
                    } else {
                      _selectedAppIds.add(app.id);
                    }
                  });
                },
              )),

              if (libraryApps.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildSectionLabel('In Library'),
                const SizedBox(height: 12),
                ...libraryApps.map((app) => _buildManageAppCard(
                  app: app,
                  isSelected: false,
                  onToggle: () {},
                )),
              ],
              const SizedBox(height: 120),
            ],
          );
        } catch (e) {
          debugPrint('ManageAppsScreen: Crash in _buildManageTab - $e');
          return _buildCrashState(e.toString());
        }
      },
    );
  }

  List<AppModel> _getFallbackApps() {
    return [
      AppModel(
        id: 'scamester',
        title: 'Scamester',
        publisher: 'UMak IT',
        description: 'Phising detection tool',
        iconAsset: 'assets/scamester_logo.png',
        category: 'Security',
        college: 'University-wide',
        downloadUrl: '',
        version: '1.4.0',
        size: '14 MB',
        rating: '4.8',
        reviews: '120',
        packageName: 'com.example.umakstore.scamester',
        status: AppStatus.installed,
      ),
      AppModel(
        id: 'portal',
        title: 'UMak Portal',
        publisher: 'University of Makati',
        description: 'Student portal',
        iconAsset: 'assets/umak_logo.png',
        category: 'Education',
        college: 'University-wide',
        downloadUrl: '',
        version: '2.4.1',
        size: '45 MB',
        rating: '4.5',
        reviews: '500',
        packageName: 'com.umak.portal',
        status: AppStatus.installed,
      ),
      AppModel(
        id: 'campus_map',
        title: 'Campus Map',
        publisher: 'UMak IT',
        description: 'Navigate the university',
        iconAsset: 'assets/map_icon.png',
        category: 'Utilities',
        college: 'University-wide',
        downloadUrl: '',
        version: '3.1.0',
        size: '82 MB',
        rating: '4.9',
        reviews: '85',
        packageName: 'com.umak.campusmap',
        status: AppStatus.installed,
      ),
    ];
  }

  Widget _buildFilterBar(List<AppModel> installedApps) {
    bool allSelected = installedApps.isNotEmpty && installedApps.every((a) => _selectedAppIds.contains(a.id));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isRecentlyUsedFilterActive = !_isRecentlyUsedFilterActive),
          child: Row(
            children: [
              Text(
                'Recently used',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _isRecentlyUsedFilterActive ? const Color(0xff2094f3) : const Color(0xff0f172a),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded, 
                size: 18, 
                color: _isRecentlyUsedFilterActive ? const Color(0xff2094f3) : const Color(0xff0f172a)
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (allSelected) {
                _selectedAppIds.clear();
              } else {
                _selectedAppIds.addAll(installedApps.map((a) => a.id));
              }
            });
          },
          child: Text(
            allSelected ? 'Deselect all' : 'Select all',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xff2094f3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffe2e8f0)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff475569), size: 14),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xff475569))),
        ],
      ),
    );
  }

  Widget _buildSelectAll() {
    return Row(
      children: [
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(border: Border.all(color: const Color(0xffcbd5e1)), borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text('Select all', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xff475569))),
      ],
    );
  }

  Widget _buildManageAppCard({required AppModel app, required bool isSelected, required VoidCallback onToggle}) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x0D2094f3) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xff2094f3) : const Color(0xffe2e8f0), width: 1),
          boxShadow: isSelected ? [const BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))] : null,
        ),
        child: Row(
          children: [
            _buildAppIcon(app),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(app.title, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xff0f172a))),
                      Text(app.size, style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xff475569))),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('Version ${app.version}', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xCC0f172a))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6, height: 6, 
                        decoration: BoxDecoration(
                          color: app.status == AppStatus.uninstalling ? const Color(0xffef4444) : const Color(0xff10b981), 
                          shape: BoxShape.circle
                        )
                      ),
                      const SizedBox(width: 6),
                      Text(
                        app.status == AppStatus.uninstalling ? 'Removing...' : 'Used today', 
                        style: GoogleFonts.lexend(fontSize: 10, color: const Color(0xff475569))
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (app.status == AppStatus.uninstalling)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xffef4444)))
            else
              _buildCheckbox(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(AppModel app) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: (app.themeColor ?? const Color(0xff2094f3)).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: app.iconAsset.startsWith('http')
            ? Image.network(app.iconAsset, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(app.iconData ?? Icons.widgets_rounded, color: app.themeColor ?? const Color(0xff2094f3)))
            : Icon(app.iconData ?? Icons.widgets_rounded, color: app.themeColor ?? const Color(0xff2094f3), size: 24),
      ),
    );
  }

  Widget _buildCheckbox(bool isSelected) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xff2094f3) : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isSelected ? const Color(0xff2094f3) : const Color(0xffcbd5e1)),
      ),
      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
    );
  }

  Widget _buildUninstallFloatingButton() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xff2094f3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x332094f3), blurRadius: 50, offset: Offset(0, 25)),
          BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, 10)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showBatchUninstallConfirmationDialog(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('Uninstall selected', style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                  child: Text('${_selectedAppIds.length}', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBatchUninstallConfirmationDialog(BuildContext context) {
    if (_selectedAppIds.isEmpty) return;
    
    final apps = _appsNotifier.value ?? [];
    final selectedApps = apps.where((a) => _selectedAppIds.contains(a.id)).toList();
    if (selectedApps.isEmpty) return; // Fallback in case list changed
    
    bool keepData = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                _selectedAppIds.length == 1 
                  ? 'Uninstall ${selectedApps.first.title}?' 
                  : 'Uninstall ${_selectedAppIds.length} apps?', 
                style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 18)
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildChecklistItem(Icons.delete_sweep_outlined, 'Removes files from your device.', true),
                   const SizedBox(height: 12),
                   InkWell(
                    onTap: () => setLocalState(() => keepData = !keepData),
                    child: Row(
                      children: [
                        Icon(keepData ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: const Color(0xff2094f3), size: 20),
                        const SizedBox(width: 8),
                        Text('Keep app data', style: GoogleFonts.lexend(fontSize: 13, color: const Color(0xff0f172a))),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCEL', style: GoogleFonts.lexend(color: const Color(0xff64748b)))),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Removing ${selectedApps.length} apps...', style: GoogleFonts.lexend()),
                        backgroundColor: const Color(0xff0f172a),
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    for (var app in selectedApps) {
                      await _installer.uninstallApp(app);
                    }
                    
                    setState(() {
                      _selectedAppIds.clear();
                    });

                    // Success announcement
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Uninstallation triggered for ${selectedApps.length} apps.', style: GoogleFonts.lexend()),
                        backgroundColor: const Color(0xff10b981),
                        action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffef4444), elevation: 0),
                  child: Text('UNINSTALL', style: GoogleFonts.lexend(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // State Builders (Error, Loading, etc)
  Widget _buildErrorState(String error) => Center(child: Text('Error: $error', style: GoogleFonts.lexend(color: Colors.red)));
  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          children: [
            const CircularProgressIndicator(color: Color(0xff2094f3), strokeWidth: 3),
            const SizedBox(height: 24),
            Text(
              'Connecting to Marketplace...',
              style: GoogleFonts.lexend(
                color: const Color(0xff64748b),
                fontSize: 14,
              ),
            ),
            if (_showTroubleshooting) ...[
               const SizedBox(height: 32),
               _buildTroubleshootingBox(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfffef2f2).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xfffee2e2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Color(0xffef4444), size: 24),
          const SizedBox(height: 12),
          Text(
            'Taking longer than usual...',
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: const Color(0xff0f172a),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'View apps already on your device while the connection is established.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 12,
              color: const Color(0xff64748b),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    final fallback = _getFallbackApps();
                    _appsStream = Stream.value(fallback);
                    _appsNotifier.value = fallback; // IMMEDIATELY update UI
                    _showTroubleshooting = false;
                  });
                },
                child: Text('Offline Mode', style: GoogleFonts.lexend(color: const Color(0xff2094f3), fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showTroubleshooting = false;
                    _appsNotifier.value = null; // Forces loading spinner again
                    _appsStream = DeveloperService().getStoreApps().asBroadcastStream();
                  });
                  _startPrimingFetch();
                  _startTroubleshootingTimer();
                },
                child: Text('Retry', style: GoogleFonts.lexend(color: const Color(0xff64748b), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildNoAppsState() => Center(child: Padding(padding: const EdgeInsets.all(48), child: Column(children: [Icon(Icons.layers_clear_rounded, size: 48, color: const Color(0x1A0f172a)), const SizedBox(height: 16), Text('No apps found', style: GoogleFonts.lexend(color: const Color(0x660f172a)))])));
  Widget _buildCrashState(String error) => Center(child: Text('Crash: $error', style: GoogleFonts.lexend(color: Colors.orange)));

  Widget _buildSectionLabel(String label) {
    return Text(label.toUpperCase(), style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xff94a3b8), letterSpacing: 0.5));
  }

  Widget _buildBottomNav() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xffe2e8f0), width: 1)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        currentIndex: 3, // Manage Screen is usually part of Profile (index 3)
        onTap: (index) {
          if (index != 3) {
             // Home, Search, Favorites - notify parent to switch tab and pop
             if (widget.onTabSelected != null) {
               widget.onTabSelected!(index);
             }
             Navigator.of(context).pop();
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff2094f3),
        unselectedItemColor: const Color(0xff94a3b8),
        selectedLabelStyle: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded, size: 22),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded, size: 22),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_rounded, size: 22),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded, size: 22),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _showUninstallConfirmationDialog(BuildContext context, AppModel app) {
    bool keepData = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Uninstall ${app.title}?', style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xff0a192f))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChecklistItem(Icons.delete_sweep_outlined, 'Removes app files from your device', true),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => setState(() => keepData = !keepData),
                    child: Row(children: [Icon(keepData ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: const Color(0xff2094f3)), const SizedBox(width: 8), Text('Keep app data', style: GoogleFonts.lexend(fontSize: 13))]),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
                ElevatedButton(onPressed: () async {
                  Navigator.pop(context);
                  await _installer.uninstallApp(app);
                }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffef4444)), child: const Text('UNINSTALL')),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildChecklistItem(IconData icon, String text, bool checked) {
    return Row(children: [Icon(checked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 20, color: checked ? const Color(0xff10b981) : const Color(0xffcbd5e1)), const SizedBox(width: 12), Text(text, style: GoogleFonts.lexend(fontSize: 14, color: const Color(0xff475569)))]);
  }
}
