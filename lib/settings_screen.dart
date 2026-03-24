import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeService _themeService = ThemeService();
  bool _downloadWifiOnly = false;
  bool _autoUpdate = true;
  bool _allowNotifications = true;

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_updateUI);
  }

  @override
  void dispose() {
    _themeService.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() => setState(() {});

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
                'Settings',
                style: GoogleFonts.lexend(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.75,
                ),
              ),
            ),

            _buildSectionHeader('APPEARANCE', colorScheme),
            const SizedBox(height: 8),
            _buildSettingsCard([_buildThemeSelectionRow(colorScheme)], colorScheme),

            const SizedBox(height: 24),
            _buildSectionHeader('GENERAL', colorScheme),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildNavigationItem(
                icon: Icons.language_rounded,
                iconColor: const Color(0xfff97316),
                iconBgColor: const Color(0xfffff7ed),
                title: 'Language',
                trailingText: 'English',
                onTap: () {},
                colorScheme: colorScheme,
              ),
            ], colorScheme),

            const SizedBox(height: 24),
            _buildSectionHeader('DOWNLOADS', colorScheme),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildToggleItem(
                icon: Icons.wifi_rounded,
                iconColor: const Color(0xff10b981),
                iconBgColor: const Color(0xffecfdf5),
                title: 'Download over Wi-Fi only',
                value: _downloadWifiOnly,
                onChanged: (val) => setState(() => _downloadWifiOnly = val),
                colorScheme: colorScheme,
              ),
              _buildDivider(colorScheme),
              _buildToggleItem(
                icon: Icons.autorenew_rounded,
                iconColor: const Color(0xffa855f7),
                iconBgColor: const Color(0xfffaf5ff),
                title: 'Auto-update apps',
                value: _autoUpdate,
                onChanged: (val) => setState(() => _autoUpdate = val),
                colorScheme: colorScheme,
              ),
            ], colorScheme),

            const SizedBox(height: 24),
            _buildSectionHeader('NOTIFICATIONS', colorScheme),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildToggleItem(
                icon: Icons.notifications_none_rounded,
                iconColor: const Color(0xffef4444),
                iconBgColor: const Color(0xfffef2f2),
                title: 'Allow Notifications',
                value: _allowNotifications,
                onChanged: (val) => setState(() => _allowNotifications = val),
                colorScheme: colorScheme,
              ),
            ], colorScheme),

            const SizedBox(height: 24),
            _buildSectionHeader('STORAGE', colorScheme),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildStorageActionItem(
                icon: Icons.cleaning_services_rounded,
                iconColor: const Color(0xff3b82f6),
                iconBgColor: const Color(0xffeff6ff),
                title: 'Clear cache',
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
                    '124 MB',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                onTap: () {},
                colorScheme: colorScheme,
              ),
              _buildDivider(colorScheme),
              _buildStorageActionItem(
                icon: Icons.delete_outline_rounded,
                iconColor: const Color(0xffef4444),
                iconBgColor: const Color(0xfffef2f2),
                title: 'Clear data',
                titleColor: const Color(0xffef4444),
                onTap: () {},
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
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.store_rounded, color: Colors.white),
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
                _buildThemeTag('Light', ThemeMode.light, colorScheme),
                _buildThemeTag('Dark', ThemeMode.dark, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTag(String label, ThemeMode mode, ColorScheme colorScheme) {
    bool isSelected = _themeService.themeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _themeService.setTheme(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
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
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildStorageActionItem({
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
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
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
