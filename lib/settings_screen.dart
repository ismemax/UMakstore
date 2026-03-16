import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTheme = 'Light';
  bool _downloadWifiOnly = false;
  bool _autoUpdate = true;
  bool _allowNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xff64748b)),
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
                  color: const Color(0xff0f172a),
                  letterSpacing: -0.75,
                ),
              ),
            ),
            
            _buildSectionHeader('APPEARANCE'),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildThemeSelectionRow(),
            ]),
            
            const SizedBox(height: 24),
            _buildSectionHeader('GENERAL'),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildNavigationItem(
                icon: Icons.language_rounded,
                iconColor: const Color(0xfff97316),
                iconBgColor: const Color(0xfffff7ed),
                title: 'Language',
                trailingText: 'English',
                onTap: () {},
              ),
            ]),
            
            const SizedBox(height: 24),
            _buildSectionHeader('DOWNLOADS'),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildToggleItem(
                icon: Icons.wifi_rounded,
                iconColor: const Color(0xff10b981),
                iconBgColor: const Color(0xffecfdf5),
                title: 'Download over Wi-Fi only',
                value: _downloadWifiOnly,
                onChanged: (val) => setState(() => _downloadWifiOnly = val),
              ),
              _buildDivider(),
              _buildToggleItem(
                icon: Icons.autorenew_rounded,
                iconColor: const Color(0xffa855f7),
                iconBgColor: const Color(0xfffaf5ff),
                title: 'Auto-update apps',
                value: _autoUpdate,
                onChanged: (val) => setState(() => _autoUpdate = val),
              ),
            ]),
            
            const SizedBox(height: 24),
            _buildSectionHeader('NOTIFICATIONS'),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildToggleItem(
                icon: Icons.notifications_none_rounded,
                iconColor: const Color(0xffef4444),
                iconBgColor: const Color(0xfffef2f2),
                title: 'Allow Notifications',
                value: _allowNotifications,
                onChanged: (val) => setState(() => _allowNotifications = val),
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionHeader('STORAGE'),
            const SizedBox(height: 8),
            _buildSettingsCard([
               _buildStorageActionItem(
                icon: Icons.cleaning_services_rounded,
                iconColor: const Color(0xff3b82f6),
                iconBgColor: const Color(0xffeff6ff),
                title: 'Clear cache',
                trailingWidget: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xfff1f5f9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '124 MB',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff64748b),
                    ),
                  ),
                ),
                onTap: () {},
              ),
              _buildDivider(),
              _buildStorageActionItem(
                icon: Icons.delete_outline_rounded,
                iconColor: const Color(0xffef4444),
                iconBgColor: const Color(0xfffef2f2),
                title: 'Clear data',
                titleColor: const Color(0xffef4444),
                onTap: () {},
              ),
            ]),
            
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
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 15,
                          offset: Offset(0, 10),
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
                      color: const Color(0xff64748b),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.5 (Build 240)',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: const Color(0xff94a3b8),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xff0f2e53),
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe2e8f0)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildThemeSelectionRow() {
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
                  color: const Color(0xfff1f5f9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.dark_mode_outlined, color: Color(0xff0f172a), size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                'Theme',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff0f172a),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xfff1f5f9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildThemeTag('System'),
                _buildThemeTag('Light'),
                _buildThemeTag('Dark'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTag(String label) {
    bool isSelected = _selectedTheme == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTheme = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xff0a2342) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xff64748b),
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
                color: const Color(0xff0f172a),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xff2094f3),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xffe2e8f0),
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
    Color titleColor = const Color(0xff0f172a),
    Widget? trailingWidget,
    required VoidCallback onTap,
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
                  color: titleColor,
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
                  color: const Color(0xff0f172a),
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
                    color: const Color(0xff94a3b8),
                  ),
                ),
              ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xff94a3b8), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xfff1f5f9),
    );
  }
}
