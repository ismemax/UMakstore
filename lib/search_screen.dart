import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_details_screen.dart';
import 'models/app_model.dart';
import 'services/installer_service.dart';
import 'services/developer_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = [
    'All Apps',
    'Official',
    'CCIS Dept',
    'Utility',
    'Events',
  ];
  late InstallerService _installer;

  StreamSubscription? _appsSubscription;
  late Stream<List<AppModel>> _appsStream;

  @override
  void initState() {
    super.initState();
    _installer = InstallerService();
    _installer.addListener(_updateState);
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
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(colorScheme),
          _buildFilters(colorScheme),
          Expanded(
            child: StreamBuilder<List<AppModel>>(
              stream: _appsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final apps = snapshot.data ?? [];
                
                // For now, filtering is simulated or can be implemented here
                final filteredApps = apps.where((app) {
                  if (_selectedFilterIndex == 0) return true;
                  return app.publisher.contains(_filters[_selectedFilterIndex]); // Simple simulation
                }).toList();

                if (filteredApps.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: colorScheme.onSurface.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text(
                          'No apps found',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 96, left: 16, right: 16),
                  itemCount: filteredApps.length,
                  itemBuilder: (context, index) {
                    final app = filteredApps[index];
                    return Column(
                      children: [
                        _buildAppListItem(
                          context,
                          app: app,
                          chipLabel: 'OFFICIAL', // Could be dynamic based on a flag
                          chipColor: const Color(0xff2563eb),
                          chipBgColor: const Color(0xffeff6ff),
                          chipBorderColor: const Color(0xffdbeafe),
                        ),
                        if (index < filteredApps.length - 1) const SizedBox(height: 16),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(color: colorScheme.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search',
            style: GoogleFonts.lexend(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              letterSpacing: -0.75,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Apps, professors, events...',
                            hintStyle: GoogleFonts.lexend(
                              fontSize: 14,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Center(
                  child: Icon(
                    Icons.tune_rounded,
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

  Widget _buildFilters(ColorScheme colorScheme) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(_filters[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              backgroundColor: colorScheme.surface,
              selectedColor: colorScheme.primary.withValues(alpha: 0.1),
              labelStyle: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
                side: BorderSide(
                  color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppListItem(
    BuildContext context, {
    required AppModel app,
    required String chipLabel,
    required Color chipColor,
    required Color chipBgColor,
    required Color chipBorderColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = app.status;
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
        color: Colors.transparent, // For hit testing
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _buildAppIcon(
              app.iconData ?? Icons.apps_rounded,
              app.themeColor ?? colorScheme.primary,
              iconUrl: app.iconAsset.startsWith('http') ? app.iconAsset : null,
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
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    app.publisher,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
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
                          color: chipBgColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: chipBorderColor),
                        ),
                        child: Text(
                          chipLabel,
                          style: GoogleFonts.lexend(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: chipColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        app.rating,
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xfffbbf24),
                        size: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              status == AppStatus.installed ? 'OPEN' : 'GET',
              onTap: () {
                if (status == AppStatus.installed) {
                  _installer.launchApp(app);
                } else {
                  _installer.installApp(app);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, {VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          text,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(color: colorScheme.outlineVariant, height: 1, thickness: 1),
    );
  }

  Widget _buildAppIcon(IconData iconData, Color iconColor, {String? iconUrl}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: iconUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(iconUrl, width: 64, height: 64, fit: BoxFit.cover),
              )
            : Icon(iconData, color: iconColor, size: 32),
      ),
    );
  }
}
