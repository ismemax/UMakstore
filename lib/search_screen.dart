import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_details_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildFilters(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(
              top: 16,
              bottom: 96,
              left: 16,
              right: 16,
            ),
            children: [
              _buildAppListItem(
                context,
                title: 'UMak Portal',
                subtitle: 'IT Department',
                chipLabel: 'OFFICIAL',
                chipColor: const Color(0xff2563eb),
                chipBgColor: const Color(0xffeff6ff),
                chipBorderColor: const Color(0xffdbeafe),
                rating: '4.8',
                actionWidget: _buildActionButton('OPEN'),
                iconWidget: _buildAppIcon(
                  const Color(0xff0a192f),
                  Icons.grid_view_rounded,
                  Colors.white,
                ),
              ),
              _buildDivider(),
              _buildAppListItem(
                context,
                title: 'Heron Library',
                subtitle: 'Library Services',
                chipLabel: 'ACADEMIC',
                chipColor: const Color(0xff4b5563),
                chipBgColor: const Color(0xfff2f4f6),
                chipBorderColor: const Color(0xffe5e7eb),
                rating: '4.5',
                actionWidget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildActionButton('GET'),
                    const SizedBox(height: 4),
                    Text(
                      'In-App Purchases',
                      style: GoogleFonts.lexend(
                        fontSize: 9,
                        color: const Color(0xff9ca3af),
                      ),
                    ),
                  ],
                ),
                iconWidget: _buildAppIcon(
                  const Color(0xfff97316),
                  Icons.menu_book_rounded,
                  Colors.white,
                ),
              ),
              _buildDivider(),
              _buildAppListItem(
                context,
                title: 'ComSci Calc',
                subtitle: 'Student Project',
                chipLabel: 'CCIS',
                chipColor: const Color(0xff6366f1),
                chipBgColor: const Color(0xffeef2ff),
                chipBorderColor: const Color(0xffe0e7ff),
                rating: '4.2',
                actionWidget: _buildActionButton('GET'),
                iconWidget: _buildAppIcon(
                  const Color(0xff1e293b),
                  Icons.calculate_rounded,
                  const Color(0xff38bdf8),
                ),
              ),
              _buildDivider(),
              _buildAppListItem(
                context,
                title: 'Campus Nav',
                subtitle: 'Admin Office',
                chipLabel: 'UTILITY',
                chipColor: const Color(0xff4b5563),
                chipBgColor: const Color(0xfff2f4f6),
                chipBorderColor: const Color(0xffe5e7eb),
                rating: '3.9',
                actionWidget: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff2094f3).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: const Icon(
                    Icons.cloud_download_outlined,
                    color: Color(0xff2094f3),
                    size: 16,
                  ),
                ),
                iconWidget: _buildAppIcon(
                  const Color(0xff22c55e),
                  Icons.map_rounded,
                  Colors.white,
                ),
              ),
              _buildDivider(),
              Opacity(
                opacity: 0.6,
                child: _buildAppListItem(
                  context,
                  title: 'Old Enroll System',
                  subtitle: 'Registrar',
                  chipLabel: 'DEPRECATED',
                  chipColor: const Color(0xffef4444),
                  chipBgColor: const Color(0xfffef2f2),
                  chipBorderColor: const Color(0xfffee2e2),
                  rating: null,
                  actionWidget: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Unavailable',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff9ca3af),
                      ),
                    ),
                  ),
                  iconWidget: _buildAppIcon(
                    const Color(0xfff3f4f6),
                    Icons.edit_rounded,
                    const Color(0xff9ca3af),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                  Text(
                    'Not finding what you\'re looking for?',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: const Color(0xff9ca3af),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Request an App',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff2094f3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search',
            style: GoogleFonts.lexend(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0a1929),
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
                    color: const Color(0xfff2f4f6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffe5e7eb)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: Color(0xff9ca3af),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            color: const Color(0xff1e3a5f),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Apps, professors, events...',
                            hintStyle: GoogleFonts.lexend(
                              fontSize: 14,
                              color: const Color(
                                0xff1e3a5f,
                              ).withValues(alpha: 0.7),
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
                  color: const Color(0xfff2f4f6),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xffe5e7eb)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.tune_rounded,
                    color: Color(0xff0a1929),
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

  Widget _buildFilters() {
    return Container(
      height: 46,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xfff3f4f6), width: 1)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xff2094f3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xff2094f3)
                      : const Color(0xff0a1929).withValues(alpha: 0.3),
                ),
                boxShadow: isSelected
                    ? [
                        const BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                _filters[index],
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xff0a1929),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppListItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String chipLabel,
    required Color chipColor,
    required Color chipBgColor,
    required Color chipBorderColor,
    required String? rating,
    required Widget actionWidget,
    required Widget iconWidget,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AppDetailsScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconWidget,
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
                      color: const Color(0xff0a1929),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: const Color(0xff6b7280),
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
                      if (rating != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          rating,
                          style: GoogleFonts.lexend(
                            fontSize: 10,
                            color: const Color(0xff9ca3af),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xfffbbf24),
                          size: 10,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            actionWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xfff2f4f6),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        text,
        style: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xff2094f3),
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(color: Color(0xfff3f4f6), height: 1, thickness: 1),
    );
  }

  Widget _buildAppIcon(Color bgColor, IconData iconData, Color iconColor) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xfff3f4f6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(child: Icon(iconData, color: iconColor, size: 32)),
    );
  }
}
