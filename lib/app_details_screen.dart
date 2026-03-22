import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screenshots_screen.dart';
import 'about_app_screen.dart';
import 'reviews_screen.dart';
import 'write_review_screen.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:async';

class AppDetailsScreen extends StatefulWidget {
  const AppDetailsScreen({super.key});

  @override
  State<AppDetailsScreen> createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends State<AppDetailsScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _isInstalled = false;

  // ⚠️ PASTE YOUR GITHUB RELEASE URL HERE!
  final String _apkUrl =
      "https://github.com/ismemax/scamester_apk/releases/download/Test/ScamesterV.0.1.2.4a.apk";

  Future<void> _downloadAndInstallApp() async {
    if (_isDownloading || _isInstalled) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final String savePath = "${tempDir.path}/umak_portal.apk";

      await dio.download(
        _apkUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      setState(() {
        _isDownloading = false;
        _isInstalled = true;
      });

      // Trigger native installation
      final result = await OpenFilex.open(savePath);

      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Installation failed: ${result.message}')),
        );
        setState(() => _isInstalled = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error downloading app: $e')));
      }
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Color(0xff2094f3),
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: Color(0xff2094f3),
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildStats(),
            _buildActionButtons(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(color: Color(0xfff1f5f9), height: 1),
            ),
            _buildPreviewSection(context),
            const SizedBox(height: 32),
            _buildAboutSection(context),
            const SizedBox(height: 32),
            _buildRatingsSection(context),
            const SizedBox(height: 32),
            _buildDeveloperSection(),
            const SizedBox(height: 48),
            _buildFooter(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xffef4444),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xffef4444).withValues(alpha: 0.1),
                  blurRadius: 25,
                  offset: const Offset(0, 20),
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: const Color(0xffef4444).withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 8),
                  spreadRadius: -6,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SECURITY',
                    style: GoogleFonts.lexend(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Scamester',
          style: GoogleFonts.lexend(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xff0a192f),
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Your essential academic companion for grades, schedules, and campus news.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: const Color(0xff64748b),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem('4.8 ★', 'RATING'),
          _buildStatDivider(),
          _buildStatItem('12k+', 'REPORTS'),
          _buildStatDivider(),
          _buildStatItem('12 MB', 'SIZE'),
          _buildStatDivider(),
          _buildStatItem('Sec', 'CATEGORY'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xff0a192f),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xff94a3b8),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 24, width: 1, color: const Color(0xfff1f5f9));
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _isDownloading || _isInstalled
                  ? null
                  : _downloadAndInstallApp,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: _isInstalled
                      ? const Color(0xff4ade80)
                      : const Color(0xff2094f3),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isInstalled
                                  ? const Color(0xff4ade80)
                                  : const Color(0xff2094f3))
                              .withValues(alpha: 0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                      spreadRadius: -3,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    if (_isDownloading)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            value: _downloadProgress,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                    Center(
                      child: Text(
                        _isDownloading
                            ? '${(_downloadProgress * 100).toInt()}%'
                            : (_isInstalled ? 'Installed' : 'Install'),
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xff2094f3).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              color: Color(0xff2094f3),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Preview',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff0a192f),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ScreenshotsScreen(appName: 'Scamester'),
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff2094f3),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildScreenshotCard(context, const Color(0xfffef3c7)),
              const SizedBox(width: 16),
              _buildScreenshotCard(context, const Color(0xfffee2e2)),
              const SizedBox(width: 16),
              _buildScreenshotCard(context, const Color(0xffdbeafe)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScreenshotCard(BuildContext context, Color bgColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const ScreenshotsScreen(appName: 'UMak Portal'),
          ),
        );
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffe2e8f0)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xff0a192f).withValues(alpha: 0.1),
                    width: 4,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: Color(0xfff1f5f9),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xfff1f5f9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xfff8fafc),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About This App',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0a192f),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Scamester is your all-in-one security shield for the UMak campus. Designed to identify, report, and prevent scams targeting students and faculty, it keeps our digital environment safe and secure.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: const Color(0xff475569),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutAppScreen()),
              );
            },
            child: Text(
              'Read More',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xff2094f3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ratings & Reviews',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff0a192f),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReviewsScreen(),
                    ),
                  );
                },
                child: Text(
                  'See All',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff2094f3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    '4.8',
                    style: GoogleFonts.lexend(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff0a192f),
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'out of 5',
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff94a3b8),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, 0.85),
                    const SizedBox(height: 8),
                    _buildRatingBar(4, 0.1),
                    const SizedBox(height: 8),
                    _buildRatingBar(3, 0.03),
                    const SizedBox(height: 8),
                    _buildRatingBar(2, 0.01),
                    const SizedBox(height: 8),
                    _buildRatingBar(1, 0.01),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '1,248 Ratings',
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff94a3b8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WriteReviewScreen(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xff0a192f), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.mode_edit_outline_outlined,
                    color: Color(0xff0a192f),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Write a Review',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff0a192f),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildReviewCard(
            'K1123456',
            'Oct 20, 2023',
            'Super helpful!',
            'Finally, an app that works smoothly. Checking grades and schedules is so much easier now compared to the old website.',
            5,
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            'K1198765',
            'Oct 18, 2023',
            'Great UI, needs minor fixes',
            'The interface is clean and modern. Notifications sometimes come in a bit late, but overall a solid experience for students.',
            4,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int star, double percent) {
    return Row(
      children: [
        SizedBox(
          width: 12,
          child: Text(
            '$star',
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0a192f),
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.star_rounded, color: Color(0xff0a192f), size: 10),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xfff1f5f9),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xff0a192f),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(
    String user,
    String date,
    String title,
    String content,
    int rating,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xfff1f5f9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff0a192f),
                    ),
                  ),
                  Text(
                    date,
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      color: const Color(0xff94a3b8),
                    ),
                  ),
                ],
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star_rounded,
                    color: index < rating
                        ? const Color(0xff0a192f)
                        : const Color(0xffe2e8f0),
                    size: 14,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0a192f),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.lexend(
              fontSize: 12,
              color: const Color(0xff475569),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Developer',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0a192f),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xfff1f5f9)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xff2094f3).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.code_rounded,
                      color: Color(0xff2094f3),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UMak Security Dept.',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff1e293b),
                        ),
                      ),
                      Text(
                        'Visit Website',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: const Color(0xff2094f3),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xff2094f3),
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFooterLink(Icons.privacy_tip_outlined, 'Privacy Policy'),
              const SizedBox(width: 24),
              _buildFooterLink(Icons.description_outlined, 'Terms of Service'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xff64748b)),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            color: const Color(0xff64748b),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'Version 2.4.1 • Updated Oct 24, 2023',
        style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xff94a3b8)),
      ),
    );
  }
}
