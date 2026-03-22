import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'app_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _selectedIndex == 0
            ? Column(
                children: [
                  _buildHeader(),
                  _buildTabs(),
                  Expanded(
                    child: _selectedTabIndex == 0
                        ? _buildForYouTab()
                        : _buildTopRatedTab(),
                  ),
                ],
              )
            : (_selectedIndex == 1
                  ? const SearchScreen()
                  : const ProfileScreen()),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xffe2e8f0), width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: const Color(0xff2094f3),
          unselectedItemColor: const Color(0xff94a3b8),
          selectedLabelStyle: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.grid_view_rounded, size: 22),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.search_rounded, size: 22),
              ),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.person_outline_rounded, size: 22),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Apps',
            style: GoogleFonts.lexend(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0f172a),
              letterSpacing: -0.75,
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xff2094f3).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.person_outline_rounded,
                color: Color(0xff2094f3),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xffe2e8f0), width: 1)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = 0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    'For You',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _selectedTabIndex == 0
                          ? const Color(0xff2094f3)
                          : const Color(0xff94a3b8),
                    ),
                  ),
                ),
                Container(
                  height: 4,
                  width: 69,
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 0
                        ? const Color(0xff2094f3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = 1),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    'Top Rated',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _selectedTabIndex == 1
                          ? const Color(0xff2094f3)
                          : const Color(0xff94a3b8),
                    ),
                  ),
                ),
                Container(
                  height: 4,
                  width: 91,
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 1
                        ? const Color(0xff2094f3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForYouTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildFeaturedAppCard(),
          const SizedBox(height: 32),
          _buildHorizontalListSection(
            title1: 'For College of\n',
            title2: 'Computer Studies',
          ),
          const SizedBox(height: 32),
          _buildRecentlyUpdatedSection(),
          const SizedBox(height: 32),
          _buildCategoriesSection(),
        ],
      ),
    );
  }

  Widget _buildTopRatedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.62,
              children: [
                _buildTopRatedAppCard(
                  rank: 1,
                  title: 'Scamester',
                  publisher: 'Security Dept',
                  rating: '4.9',
                  reviews: '(12k)',
                  isButtonOutlined: false,
                  iconWidget: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xfff1f5f9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.shield_rounded,
                        size: 40,
                        color: const Color(0xffef4444),
                      ),
                    ),
                  ),
                ),
                _buildTopRatedAppCard(
                  rank: 2,
                  title: 'Canvas',
                  publisher: 'Instructure Inc.',
                  rating: '4.8',
                  reviews: '(8.5k)',
                  isButtonOutlined: true,
                  iconWidget: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff6366f1), Color(0xff9333ea)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.school_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                _buildTopRatedAppCard(
                  rank: 3,
                  title: 'PyCompiler',
                  publisher: 'CodeLabs',
                  rating: '4.7',
                  reviews: '(3.2k)',
                  isButtonOutlined: false,
                  iconWidget: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff0f172a),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.code_rounded,
                        size: 40,
                        color: Color(0xff38bdf8),
                      ),
                    ),
                  ),
                ),
                _buildTopRatedAppCard(
                  rank: 4,
                  title: 'Campus Nav',
                  publisher: 'Facilities Dept',
                  rating: '4.6',
                  reviews: '(2.1k)',
                  isButtonOutlined: false,
                  iconWidget: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff22c55e), Color(0xff059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.map_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                _buildTopRatedAppCard(
                  rank: 5,
                  title: 'Git Graph',
                  publisher: 'Dev Tools',
                  rating: '4.5',
                  reviews: '(900)',
                  isButtonOutlined: false,
                  iconWidget: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff1f2937),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.auto_graph_rounded,
                        size: 40,
                        color: Color(0xff10b981),
                      ),
                    ),
                  ),
                ),
                _buildTopRatedAppCard(
                  rank: 6,
                  title: 'Shuttle Bus',
                  publisher: 'Transport Office',
                  rating: '4.3',
                  reviews: '(1.5k)',
                  isButtonOutlined: true,
                  iconWidget: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xffec4899), Color(0xffe11d48)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.directions_bus_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Browse by Category',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xff1e293b),
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
                  'Academic',
                  Icons.school_rounded,
                  const Color(0xff3b82f6),
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  'Library',
                  Icons.menu_book_rounded,
                  const Color(0xff22c55e),
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  'Campus Services',
                  Icons.business_rounded,
                  const Color(0xffa855f7),
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  'Student Life',
                  Icons.sports_esports_rounded,
                  const Color(0xfff97316),
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  'Dining',
                  Icons.restaurant_rounded,
                  const Color(0xffeab308),
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
    required String title,
    required String publisher,
    required String rating,
    required String reviews,
    required Widget iconWidget,
    required bool isButtonOutlined,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AppDetailsScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffe2e8f0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 2,
              offset: Offset(0, 1),
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
                decoration: const BoxDecoration(
                  color: Color(0xff0a192f),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Text(
                  '#$rank',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 80, height: 80, child: iconWidget),
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff1e293b),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        publisher,
                        style: GoogleFonts.lexend(
                          fontSize: 11,
                          color: const Color(0xff64748b),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        rating,
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff1e293b),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        children: List.generate(
                          5,
                          (index) => const Icon(
                            Icons.star_rounded,
                            color: Color(0xfffbbf24),
                            size: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reviews,
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          color: const Color(0xff94a3b8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isButtonOutlined
                          ? Colors.white
                          : const Color(0xff2094f3),
                      borderRadius: BorderRadius.circular(12),
                      border: isButtonOutlined
                          ? Border.all(
                              color: const Color(
                                0xff2094f3,
                              ).withValues(alpha: 0.2),
                            )
                          : null,
                      boxShadow: isButtonOutlined
                          ? []
                          : const [
                              BoxShadow(
                                color: Color(0x0D000000),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                    ),
                    child: Text(
                      'Install',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isButtonOutlined
                            ? const Color(0xff2094f3)
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData iconData, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color(0xffe2e8f0)),
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
              color: const Color(0xff1e293b),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedAppCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AppDetailsScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          height: 224,
          decoration: BoxDecoration(
            color: Colors
                .white, // In a real app, use DecorationImage for the background
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xfff1f5f9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000), // 0.1 opacity
                blurRadius: 15,
                offset: Offset(0, 10),
                spreadRadius: -3,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Placeholder for background image
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xffe2e8f0), Color(0xfff8fafc)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),
              // White gradient overlay at the bottom
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.95),
                          Colors.white.withValues(alpha: 0.8),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
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
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff2094f3).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xff2094f3).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        'FEATURED APP',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff2094f3),
                          letterSpacing: 0.6,
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xffe2e8f0)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 6,
                                offset: Offset(0, 4),
                                spreadRadius: -1,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.shield_rounded,
                              color: Color(0xffef4444),
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scamester',
                                style: GoogleFonts.lexend(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff0f172a),
                                ),
                              ),
                              Text(
                                'Detect scams & stay secure on campus...',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  color: const Color(0xff64748b),
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
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xff2094f3),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x332094f3),
                                  blurRadius: 15,
                                  offset: Offset(0, 10),
                                  spreadRadius: -3,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.download_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Install',
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
                        const SizedBox(width: 12),
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xfff1f5f9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.bookmark_border_rounded,
                              color: Color(0xff0f172a),
                              size: 22,
                            ),
                          ),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff0f172a),
                    height: 1.375,
                  ),
                  children: [
                    TextSpan(text: title1),
                    TextSpan(
                      text: title2,
                      style: const TextStyle(color: Color(0xff2094f3)),
                    ),
                  ],
                ),
              ),
              Text(
                'See All',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff2094f3),
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
            children: [
              _buildAppCardSmall(
                title: 'PyCompiler Pro',
                category: 'Education',
                rating: '4.9',
                iconData: Icons.code_rounded,
                iconColor: const Color(0xff2094f3),
              ),
              const SizedBox(width: 16),
              _buildAppCardSmall(
                title: 'LogicSim',
                category: 'Tools',
                rating: '4.5',
                iconData: Icons.memory_rounded,
                iconColor: const Color(0xff8b5cf6),
              ),
              const SizedBox(width: 16),
              _buildAppCardSmall(
                title: 'Git Tracker',
                category: 'Dev',
                rating: '4.7',
                iconData: Icons.alt_route_rounded,
                iconColor: const Color(0xfff97316),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppCardSmall({
    required String title,
    required String category,
    required String rating,
    required IconData iconData,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AppDetailsScreen()),
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
                color: const Color(0xfff1f5f9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xffe2e8f0)),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff94a3b8), Color(0xffe2e8f0)],
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
                              Colors.white.withValues(alpha: 0.9),
                              Colors.white.withValues(alpha: 0.0),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xfff1f5f9)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000), // 0.05 opacity
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(iconData, color: iconColor, size: 16),
                      ),
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
                color: const Color(0xff0f172a),
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
                    color: const Color(0xff64748b),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 2,
                  height: 2,
                  decoration: const BoxDecoration(
                    color: Color(0xffcbd5e1),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff475569),
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
                color: const Color(0xfff1f5f9),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                'GET',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff2094f3),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyUpdatedSection() {
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
                  color: const Color(0xff0f172a),
                ),
              ),
              Text(
                'See All',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff2094f3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              _buildListAppCard(
                title: 'Campus Naviga...',
                subtitle: 'New building layouts a...',
                version: 'v3.2',
                timeAgo: '2d ago',
                iconColor: const Color(0xff1e3a8a), // Navy
                iconData: Icons.map_rounded,
                actionText: 'Update',
                isUpdate: true,
              ),
              const SizedBox(height: 16),
              _buildListAppCard(
                title: 'UMak Shuttle',
                subtitle: 'Real-time GPS tracking fi...',
                version: 'v1.5',
                timeAgo: '5d ago',
                iconColor: const Color(0xffe11d48), // Pink/Red
                iconData: Icons.directions_bus_rounded,
                actionText: 'Open',
                isUpdate: false,
              ),
              const SizedBox(height: 16),
              _buildListAppCard(
                title: 'LibAccess',
                subtitle: 'Dark mode support ad...',
                version: 'v4.0',
                timeAgo: '1w ago',
                iconColor: const Color(0xffa16207), // Brownish
                iconData: Icons.menu_book_rounded,
                actionText: 'Update',
                isUpdate: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListAppCard({
    required String title,
    required String subtitle,
    required String version,
    required String timeAgo,
    required Color iconColor,
    required IconData iconData,
    required String actionText,
    required bool isUpdate,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AppDetailsScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xfff1f5f9)),
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
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(iconData, color: Colors.white, size: 28),
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
                      color: const Color(0xff0f172a),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: const Color(0xff64748b),
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
                          color: const Color(0xffdcfce7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xffbbf7d0)),
                        ),
                        child: Text(
                          version,
                          style: GoogleFonts.lexend(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff15803d),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeAgo,
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          color: const Color(0xff94a3b8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: isUpdate
                    ? const Color(0xff2094f3).withValues(alpha: 0.1)
                    : const Color(0xfff1f5f9),
                borderRadius: BorderRadius.circular(9999),
                border: isUpdate
                    ? null
                    : Border.all(color: const Color(0xffe2e8f0)),
              ),
              child: Text(
                actionText,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isUpdate
                      ? const Color(0xff2094f3)
                      : const Color(0xff94a3b8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Categories',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0f172a),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.5, // roughly 160 width / 60 height
            children: [
              _buildCategoryCard('Academic', Icons.school_rounded),
              _buildCategoryCard('Student Life', Icons.sports_esports_rounded),
              _buildCategoryCard('Dining', Icons.restaurant_rounded),
              _buildCategoryCard('Events', Icons.event_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xfff1f5f9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe2e8f0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xff0f172a), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.lexend(
                fontSize: 14, // Adjusted slightly to fit better horizontally
                fontWeight: FontWeight.w500,
                color: const Color(0xff0f172a),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
