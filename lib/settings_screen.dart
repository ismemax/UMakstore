import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/theme_service.dart';
import 'services/language_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeService _themeService = ThemeService();
  final LanguageService _languageService = LanguageService();
  bool _downloadWifiOnly = false;
  bool _autoUpdate = true;
  bool _allowNotifications = true;
  String _cacheSize = '0 KB';
  String _dataSize = '0 KB';
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_updateUI);
    _loadStorageSizes();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _downloadWifiOnly = prefs.getBool('download_wifi_only') ?? false;
        _autoUpdate = prefs.getBool('auto_update') ?? true;
        _allowNotifications = prefs.getBool('allow_notifications') ?? true;
      });
    }
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _loadStorageSizes() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final appDir = await getApplicationDocumentsDirectory();

      final tempSize = await _calculateDirectorySize(tempDir);
      final appSize = await _calculateDirectorySize(appDir);

      if (mounted) {
        setState(() {
          _cacheSize = _formatSize(tempSize);
          _dataSize = _formatSize(appSize);
        });
      }
    } catch (e) {
      debugPrint('Error loading storage sizes: $e');
    }
  }

  Future<int> _calculateDirectorySize(Directory dir) async {
    int totalSize = 0;
    try {
      if (await dir.exists()) {
        await for (var entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (e) {
      debugPrint('Error calculating size for ${dir.path}: $e');
    }
    return totalSize;
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 KB';
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes > 0) ? (bytes.toString().length - 1) ~/ 3 : 0;
    // We want at least KB for better UX
    if (i == 0) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (math.pow(1024, i))).toStringAsFixed(1)} ${suffixes[i]}';
  }

  Future<void> _clearCache() async {
    setState(() => _isClearing = true);
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (var entity in tempDir.list()) {
          await entity.delete(recursive: true);
        }
      }
      await _loadStorageSizes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    } finally {
      if (mounted) setState(() => _isClearing = false);
    }
  }

  Future<void> _clearData() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear App Data?'),
        content: const Text(
          'This will delete all your settings, preferences, and locally saved profile photos. You will need to sign in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('CLEAR EVERYTHING'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    setState(() => _isClearing = true);
    try {
      // 1. Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 2. Clear Documents directory
      final appDir = await getApplicationDocumentsDirectory();
      if (await appDir.exists()) {
        await for (var entity in appDir.list()) {
          await entity.delete(recursive: true);
        }
      }

      // 3. Clear Cache as well
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (var entity in tempDir.list()) {
          await entity.delete(recursive: true);
        }
      }

      await _loadStorageSizes();
      // 4. Sign out since credentials are gone
      await FirebaseAuth.instance.signOut();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All app data cleared. Session ended.')),
        );
        // Navigate to login or home (which will redirect to login if auth is required)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      debugPrint('Error clearing data: $e');
    } finally {
      if (mounted) setState(() => _isClearing = false);
    }
  }

  @override
  void dispose() {
    _themeService.removeListener(_updateUI);
    _languageService.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() => setState(() {});

  Future<void> _showLanguageDialog() async {
    final colorScheme = Theme.of(context).colorScheme;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Select Language',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', 'en', colorScheme),
            _buildLanguageOption('Filipino', 'tl', colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String name, String code, ColorScheme colorScheme) {
    bool isSelected = _languageService.locale.languageCode == code;
    return ListTile(
      title: Text(
        name,
        style: GoogleFonts.lexend(
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: colorScheme.primary) : null,
      onTap: () {
        _languageService.setLanguage(code);
        Navigator.pop(context);
      },
    );
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
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface.withValues(alpha: 0.6)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 24.0),
              child: Text(
                _languageService.translate('settings'),
                style: GoogleFonts.lexend(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.75,
                ),
              ),
            ),

            _buildSectionHeader(_languageService.translate('appearance'), colorScheme),
            const SizedBox(height: 8),
            _buildSettingsCard([_buildThemeSelectionRow(colorScheme)], colorScheme),

            const SizedBox(height: 24),
            _buildSectionHeader(_languageService.translate('general'), colorScheme),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildNavigationItem(
                key: const Key('tile_language'),
                icon: Icons.language_rounded,
                iconColor: const Color(0xfff97316),
                iconBgColor: const Color(0xfffff7ed),
                title: _languageService.translate('language'),
                trailingText: _languageService.currentLanguageName,
                onTap: _showLanguageDialog,
                colorScheme: colorScheme,
              ),
            ], colorScheme),

            const SizedBox(height: 24),
            _buildSectionHeader(_languageService.translate('downloads'), colorScheme),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildToggleItem(
                icon: Icons.wifi_rounded,
                iconColor: const Color(0xff10b981),
                iconBgColor: const Color(0xffecfdf5),
                title: _languageService.translate('wifi_only'),
                value: _downloadWifiOnly,
                onChanged: (val) {
                  setState(() => _downloadWifiOnly = val);
                  _saveSetting('download_wifi_only', val);
                },
                colorScheme: colorScheme,
              ),
              _buildDivider(colorScheme),
              _buildToggleItem(
                icon: Icons.autorenew_rounded,
                iconColor: const Color(0xffa855f7),
                iconBgColor: const Color(0xfffaf5ff),
                title: _languageService.translate('auto_update'),
                value: _autoUpdate,
                onChanged: (val) {
                  setState(() => _autoUpdate = val);
                  _saveSetting('auto_update', val);
                },
                colorScheme: colorScheme,
              ),
            ], colorScheme),

            const SizedBox(height: 24),
            _buildSectionHeader(_languageService.translate('notifications_title'), colorScheme),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildToggleItem(
                icon: Icons.notifications_none_rounded,
                iconColor: const Color(0xffef4444),
                iconBgColor: const Color(0xfffef2f2),
                title: _languageService.translate('allow_notifications'),
                value: _allowNotifications,
                onChanged: (val) {
                  setState(() => _allowNotifications = val);
                  _saveSetting('allow_notifications', val);
                },
                colorScheme: colorScheme,
              ),
            ], colorScheme),

            const SizedBox(height: 24),
            _buildSectionHeader(_languageService.translate('storage'), colorScheme),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildStorageActionItem(
                key: const Key('tile_clear_cache'),
                icon: Icons.cleaning_services_rounded,
                iconColor: const Color(0xff3b82f6),
                iconBgColor: const Color(0xffeff6ff),
                title: _languageService.translate('clear_cache'),
                trailingWidget: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _isClearing ? '...' : _cacheSize,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                onTap: _isClearing ? () {} : _clearCache,
                colorScheme: colorScheme,
              ),
              _buildDivider(colorScheme),
              _buildStorageActionItem(
                icon: Icons.delete_outline_rounded,
                iconColor: const Color(0xffef4444),
                iconBgColor: const Color(0xfffef2f2),
                title: _languageService.translate('clear_data'),
                titleColor: const Color(0xffef4444),
                trailingWidget: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    _dataSize,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: const Color(0xffef4444).withValues(alpha: 0.5),
                    ),
                  ),
                ),
                onTap: _isClearing ? () {} : _clearData,
                colorScheme: colorScheme,
              ),
            ], colorScheme),

            const SizedBox(height: 48),

            // App Info footer
            Center(
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff2094f3), Color(0xff2563eb)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(Icons.store_rounded, color: colorScheme.onPrimary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'UMak App Store',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.1.0',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildThemeSelectionRow(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _themeService.themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: colorScheme.onSurface,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Theme',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildThemeTag(_languageService.translate('light'), ThemeMode.light, colorScheme),
                _buildThemeTag(_languageService.translate('dark'), ThemeMode.dark, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTag(String label, ThemeMode mode, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () async {
        debugPrint('Settings: Theme tag tapped - setting to ${mode.toString()}');
        await _themeService.setTheme(mode);
        debugPrint('Settings: Theme set to ${_themeService.themeMode.toString()}');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _themeService.themeMode == mode ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _themeService.themeMode == mode ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _themeService.themeMode == mode ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: colorScheme.primary,
            inactiveThumbColor: colorScheme.surface,
            inactiveTrackColor: colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildStorageActionItem({
    Key? key,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    Color? titleColor,
    Widget? trailingWidget,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? colorScheme.onSurface,
                ),
              ),
            ),
            if (trailingWidget != null) trailingWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    Key? key,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  trailingText,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ColorScheme colorScheme) {
    return Container(height: 1, color: colorScheme.outlineVariant);
  }
}
