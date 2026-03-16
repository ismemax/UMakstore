import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'updates_screen.dart';

class ManageAppsScreen extends StatefulWidget {
  const ManageAppsScreen({super.key});

  @override
  State<ManageAppsScreen> createState() => _ManageAppsScreenState();
}

class _ManageAppsScreenState extends State<ManageAppsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xff1e293b), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Manage Apps & Device',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xff1e293b),
            letterSpacing: -0.45,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: _selectedTabIndex == 1 ? 100 : 32),
              child: Column(
                children: [
                  _buildSegmentedControl(),
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

  Widget _buildSegmentedControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xfff1f5f9),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 0 ? const Color(0xff1e293b) : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: _selectedTabIndex == 0
                        ? [const BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'Overview',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _selectedTabIndex == 0 ? Colors.white : const Color(0xff64748b),
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
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 1 ? const Color(0xff1e293b) : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: _selectedTabIndex == 1
                        ? [const BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'Manage',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _selectedTabIndex == 1 ? Colors.white : const Color(0xff64748b),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdatesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe2e8f0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
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
                  color: const Color(0xff1e293b).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.system_update_alt_rounded, color: Color(0xff1e293b), size: 20),
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
                      color: const Color(0xff1e293b),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '5 pending updates',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: const Color(0xff64748b),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniAppIcon(const Color(0xff0a192f)), // Placeholder colors
              const SizedBox(width: 4),
              _buildMiniAppIcon(const Color(0xfff97316)),
              const SizedBox(width: 4),
              _buildMiniAppIcon(const Color(0xff0284c7)),
              const SizedBox(width: 4),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xfff1f5f9),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+2',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff1e293b),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe2e8f0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sd_storage_outlined, color: Color(0xff1e293b), size: 20),
              const SizedBox(width: 12),
              Text(
                'Storage',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff1e293b),
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
                    '48GB',
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff1e293b),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'used',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: const Color(0xff64748b),
                    ),
                  ),
                ],
              ),
              Text(
                '64GB total',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff64748b),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xfff1f5f9),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 48 / 64,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xff1e293b),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '16GB free for new apps and data',
            style: GoogleFonts.lexend(
              fontSize: 12,
              color: const Color(0xff64748b),
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
                gradient: const LinearGradient(colors: [Color(0xff3b82f6), Color(0xff4f46e5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                iconData: Icons.school_rounded,
                hasBorder: true,
              ),
              _buildRecentAppItem(
                title: 'Library Scan',
                subtitle: 'Updated 2 days ago • 15 MB',
                gradient: const LinearGradient(colors: [Color(0xff34d399), Color(0xff0d9488)], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
                const Icon(Icons.star_rounded, color: Color(0xff1e293b), size: 24),
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
                const Icon(Icons.chevron_right_rounded, color: Color(0xff94a3b8), size: 20),
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
        border: hasBorder ? const Border(bottom: BorderSide(color: Color(0xfff1f5f9), width: 1)) : null,
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
            child: Center(
              child: Icon(iconData, color: Colors.white, size: 20),
            ),
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
          const Icon(Icons.chevron_right_rounded, color: Color(0xff94a3b8), size: 20),
        ],
      ),
    );
  }

  Widget _buildManageTab() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffe2e8f0)),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sort_rounded, color: Color(0xff475569), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Recently used',
                        style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xff475569)),
                      )
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
                      style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xff475569)),
                    )
                  ],
                ),
              ],
            ),
            Text(
              '12 apps',
              style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xff94a3b8)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildManageAppCard(
          title: 'UMak Portal',
          version: 'Version 2.4.1',
          size: '45 MB',
          usage: 'Used today',
          iconWidget: _buildPhotoIcon(Icons.phone_iphone_rounded, const Color(0xff10b981)),
          isSelected: true,
          isUsageGreen: true,
        ),
        const SizedBox(height: 12),
        _buildManageAppCard(
          title: 'Library Scan',
          version: 'Version 1.0.5',
          size: '18 MB',
          usage: 'Used 2 days ago',
          iconWidget: _buildPhotoIcon(Icons.center_focus_weak_rounded, const Color(0xff3b82f6)),
          isSelected: false,
        ),
        const SizedBox(height: 12),
        _buildManageAppCard(
          title: 'Campus Map',
          version: 'Version 3.1.0',
          size: '82 MB',
          usage: 'Used 1 week ago',
          iconWidget: _buildPhotoIcon(Icons.map_rounded, const Color(0xff14b8a6)),
          isSelected: false,
        ),
        const SizedBox(height: 12),
        _buildManageAppCard(
          title: 'Events UMak',
          version: 'Version 1.2',
          size: '12 MB',
          usage: 'Used 3 weeks ago',
          iconWidget: Container(
            decoration: BoxDecoration(color: const Color(0xff6366f1), borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('E', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
          ),
          isSelected: false,
        ),
        const SizedBox(height: 12),
        _buildManageAppCard(
          title: 'Shuttle Track',
          version: 'Version 0.9.4',
          size: '28 MB',
          usage: 'Used 1 month ago',
          iconWidget: Container(
            decoration: BoxDecoration(color: const Color(0xfffb923c), borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('S', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
          ),
          isSelected: false,
        ),
      ],
    );
  }

  Widget _buildManageAppCard({
    required String title,
    required String version,
    required String size,
    required String usage,
    required Widget iconWidget,
    required bool isSelected,
    bool isUsageGreen = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xff2094f3).withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? const Color(0xff2094f3) : const Color(0xffe2e8f0)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
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
                    Text(title, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xff0f172a))),
                    Text(size, style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xff475569))),
                  ],
                ),
                Text(version, style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xff0f172a).withValues(alpha: 0.8))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isUsageGreen) ...[
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xff10b981), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                    ],
                    Text(usage, style: GoogleFonts.lexend(fontSize: 10, color: const Color(0xff475569))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xff2094f3) : Colors.white,
              border: Border.all(color: isSelected ? const Color(0xff2094f3) : const Color(0xffcbd5e1)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoIcon(IconData iconData, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xfff1f5f9)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Center(
        child: Container(
          width: 24,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Icon(iconData, color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildUninstallButton() {
    return Container(
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
            BoxShadow(color: Color(0x0D000000), blurRadius: 15, offset: Offset(0, 10)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Uninstall selected',
                  style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
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
                '1',
                style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
