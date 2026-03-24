import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'updates_screen.dart';
import 'services/installer_service.dart';
import 'models/app_model.dart';
import 'app_details_screen.dart';

class ManageAppsScreen extends StatefulWidget {
  const ManageAppsScreen({super.key});

  @override
  State<ManageAppsScreen> createState() => _ManageAppsScreenState();
}

class _ManageAppsScreenState extends State<ManageAppsScreen> {
  static const platform = MethodChannel('com.example.umakstore/storage');
  int _selectedTabIndex = 0;
  late InstallerService _installer;
  bool _isScamesterSelected = false;

  // Real Storage States
  double _totalStorage = 0;
  double _freeStorage = 0;
  double _usedStorage = 0;
  bool _isLoadingStorage = true;

  @override
  void initState() {
    super.initState();
    _installer = InstallerService();
    _installer.addListener(_onInstallerUpdate);
    _fetchStorageInfo();
  }

  void _onInstallerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _installer.removeListener(_onInstallerUpdate);
    super.dispose();
  }

  Future<void> _fetchStorageInfo() async {
    try {
      final dynamic storageInfo = await platform.invokeMethod('getStorageInfo');

      if (storageInfo != null) {
        final totalBytes = storageInfo['totalSpace'] as int? ?? 0;
        final freeBytes = storageInfo['freeSpace'] as int? ?? 0;

        setState(() {
          // 1024^3 for GB (Gibibytes)
          _totalStorage = totalBytes.toDouble() / (1024 * 1024 * 1024);
          _freeStorage = freeBytes.toDouble() / (1024 * 1024 * 1024);
          _usedStorage = _totalStorage - _freeStorage;
          _isLoadingStorage = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching storage: $e');
      setState(() => _isLoadingStorage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Manage Apps & Device',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            letterSpacing: -0.45,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: _selectedTabIndex == 1 ? 100 : 32,
              ),
              child: Column(
                children: [
                  _buildTabs(colorScheme),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _selectedTabIndex == 0
                        ? Column(
                            children: [
                              _buildUpdatesCard(),
                              const SizedBox(height: 16),
                              _buildStorageCard(),
                              const SizedBox(height: 24),
                              _buildRecentlyUpdatedSection(),
                            ],
                          )
                        : _buildManageTab(),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedTabIndex == 1)
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: _buildUninstallButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildTabs(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'Overview',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _selectedTabIndex == 0
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'Manage',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _selectedTabIndex == 1
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
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

  Widget _buildUpdatesCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.system_update_alt_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Updates available',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '5 pending updates',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniAppIcon(colorScheme.primary), // Use dynamic colors
              const SizedBox(width: 4),
              _buildMiniAppIcon(const Color(0xfff97316)),
              const SizedBox(width: 4),
              _buildMiniAppIcon(const Color(0xff0284c7)),
              const SizedBox(width: 4),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+2',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UpdatesScreen()),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xff2094f3),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                'Update all',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAppIcon(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Center(
        child: Icon(Icons.widgets_rounded, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildStorageCard() {
    final colorScheme = Theme.of(context).colorScheme;
    if (_isLoadingStorage) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
      );
    }

    final usedPercent = (_totalStorage > 0)
        ? (_usedStorage / _totalStorage)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sd_storage_outlined,
                color: colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Storage',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${_usedStorage.toStringAsFixed(1)}GB',
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'used',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              Text(
                '${_totalStorage.toStringAsFixed(0)}GB total',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: usedPercent,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_freeStorage.toStringAsFixed(1)}GB free for new apps and data',
            style: GoogleFonts.lexend(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyUpdatedSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recently Updated',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xff1e293b),
              ),
            ),
            Text(
              'See all',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xff2094f3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xffe2e8f0)),
          ),
          child: Column(
            children: [
              _buildRecentAppItem(
                title: 'UMak Portal',
                subtitle: 'Updated yesterday • 45 MB',
                gradient: const LinearGradient(
                  colors: [Color(0xff3b82f6), Color(0xff4f46e5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                iconData: Icons.school_rounded,
                hasBorder: true,
              ),
              _buildRecentAppItem(
                title: 'Library Scan',
                subtitle: 'Updated 2 days ago • 15 MB',
                gradient: const LinearGradient(
                  colors: [Color(0xff34d399), Color(0xff0d9488)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                iconData: Icons.menu_book_rounded,
                hasBorder: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xffe2e8f0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xff1e293b),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ratings & Reviews',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff1e293b),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Manage your posted reviews',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: const Color(0xff64748b),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xff94a3b8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAppItem({
    required String title,
    required String subtitle,
    required Gradient gradient,
    required IconData iconData,
    required bool hasBorder,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: hasBorder
            ? const Border(
                bottom: BorderSide(color: Color(0xfff1f5f9), width: 1),
              )
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Center(child: Icon(iconData, color: Colors.white, size: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff1e293b),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: const Color(0xff64748b),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xff94a3b8),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildManageTab() {
    final installedApps = AppModel.sampleApps.where((app) => app.status == AppStatus.installed).toList();
    final libraryApps = AppModel.sampleApps.where((app) => app.isInLibrary && app.status != AppStatus.installed).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffe2e8f0)),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sort_rounded,
                        color: Color(0xff475569),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Recently used',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff475569),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 1, height: 16, color: const Color(0xffe2e8f0)),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffcbd5e1)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Select all',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff475569),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              '${AppModel.sampleApps.length} apps',
              style: GoogleFonts.lexend(
                fontSize: 12,
                color: const Color(0xff94a3b8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        if (installedApps.isNotEmpty) ...[
          _buildSectionLabel('Installed apps'),
          const SizedBox(height: 12),
          ...installedApps.map((app) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildManageAppCard(
              title: app.title,
              version: 'Version ${app.version}',
              size: app.size,
              usage: 'Used today',
              iconWidget: _buildPhotoIcon(
                app.iconData ?? Icons.widgets_rounded,
                app.themeColor ?? const Color(0xff64748b),
              ),
              isSelected: _isScamesterSelected, // Currently only 1 app, so we use this state
              isUsageGreen: true,
              onTap: () {
                setState(() {
                  _isScamesterSelected = !_isScamesterSelected;
                });
              },
            ),
          )),
        ],

        if (libraryApps.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSectionLabel('In Library (Uninstalled)'),
          const SizedBox(height: 12),
          ...libraryApps.map((app) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildManageAppCard(
              title: app.title,
              version: 'Version ${app.version}',
              size: app.size,
              usage: 'Ready to re-install',
              iconWidget: _buildPhotoIcon(
                app.iconData ?? Icons.widgets_rounded,
                app.themeColor ?? const Color(0xff64748b),
              ),
              isSelected: false,
              isUsageGreen: false,
              onRemove: () => _installer.removeFromLibrary(app),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppDetailsScreen(app: app)),
                );
              },
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.lexend(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: const Color(0xff94a3b8),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildManageAppCard({
    required String title,
    required String version,
    required String size,
    required String usage,
    required Widget iconWidget,
    required bool isSelected,
    required VoidCallback onTap,
    VoidCallback? onRemove,
    bool isUsageGreen = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xff2094f3).withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xff2094f3) : const Color(0xffe2e8f0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 48, height: 48, child: iconWidget),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff0f172a),
                        ),
                      ),
                      Text(
                        size,
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff475569),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    version,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff0f172a).withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isUsageGreen) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xff10b981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        usage,
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          color: const Color(0xff475569),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            onRemove != null 
            ? GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close_rounded, color: Color(0xff94a3b8), size: 20),
              )
            : Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xff2094f3) : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xff2094f3)
                        : const Color(0xffcbd5e1),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoIcon(IconData iconData, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xfff1f5f9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 24,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(child: Icon(iconData, color: Colors.white, size: 16)),
        ),
      ),
    );
  }

  Widget _buildUninstallButton() {
    int selectedCount = _isScamesterSelected ? 1 : 0;
    
    return GestureDetector(
      onTap: () {
        if (_isScamesterSelected && AppModel.sampleApps[0].status == AppStatus.installed) {
          _showUninstallConfirmationDialog(context, AppModel.sampleApps[0]);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x332094f3),
              blurRadius: 50,
              offset: Offset(0, 25),
            ),
          ],
        ),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xff2094f3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 15,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Uninstall selected',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$selectedCount',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
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
              title: Text(
                'Uninstall ${app.title}?',
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: const Color(0xff0a192f),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChecklistItem(Icons.delete_sweep_outlined, 'Removes app files from your device', true),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => setState(() => keepData = !keepData),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            keepData ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                            color: const Color(0xff2094f3),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Keep ${app.size} of app data',
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      'Recommended if you reinstall later',
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        color: const Color(0xff94a3b8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildChecklistItem(Icons.library_books_outlined, 'Keeps record in your library', true),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'CANCEL',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff64748b),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (keepData) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Note: Tap "Keep data" in the system prompt below!'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }
                    final error = await _installer.uninstallApp(app);
                    if (error != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffef4444),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text(
                    'UNINSTALL',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildChecklistItem(IconData icon, String text, bool checked) {
    return Row(
      children: [
        Icon(
          checked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 20,
          color: checked ? const Color(0xff10b981) : const Color(0xffcbd5e1),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: const Color(0xff475569),
            ),
          ),
        ),
      ],
    );
  }
}
