import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screenshots_screen.dart';
import 'about_app_screen.dart';
import 'reviews_screen.dart';
import 'write_review_screen.dart';
import 'models/app_model.dart';
import 'services/installer_service.dart';

class AppDetailsScreen extends StatefulWidget {
  final AppModel app;
  const AppDetailsScreen({super.key, required this.app});

  @override
  State<AppDetailsScreen> createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends State<AppDetailsScreen> {
  late InstallerService _installer;

  @override
  void initState() {
    super.initState();
    _installer = InstallerService();
    _installer.addListener(_updateState);
    // Verify current status on entry
    _installer.updateAppStatus(widget.app);
  }

  @override
  void dispose() {
    _installer.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) {
      if (widget.app.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.app.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        // Clear it so it doesn't show again
        widget.app.errorMessage = null;
      }
      setState(() {});
    }
  }

  void _onInstallPressed() {
    _installer.installApp(widget.app);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: colorScheme.primary,
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: colorScheme.primary,
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
            _buildDataRetentionInfo(),
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
          widget.app.title,
          style: GoogleFonts.lexend(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            widget.app.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
          _buildStatItem('${widget.app.rating} ★', 'RATING'),
          _buildStatDivider(),
          _buildStatItem('${widget.app.reviews}+', 'REPORTS'),
          _buildStatDivider(),
          _buildStatItem(widget.app.size, 'SIZE'),
          _buildStatDivider(),
          _buildStatItem(widget.app.id.length > 3 ? widget.app.id.substring(0, 3) : widget.app.id, 'CATEGORY'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 24, width: 1, color: Theme.of(context).colorScheme.outlineVariant);
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.app.status == AppStatus.notInstalled) {
                  _onInstallPressed();
                } else if (widget.app.status == AppStatus.installed) {
                  _installer.launchApp(widget.app);
                }
              },
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: widget.app.status == AppStatus.installed
                      ? const Color(0xff2094f3)
                      : const Color(0xff2094f3),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff2094f3).withValues(alpha: 0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                      spreadRadius: -3,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    if (widget.app.status == AppStatus.downloading)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            value: widget.app.progress == -1.0
                                ? null
                                : widget.app.progress,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                    Center(
                      child: Text(
                        widget.app.status == AppStatus.downloading
                            ? (widget.app.progress == -1.0
                                ? 'Downloading...'
                                : '${(widget.app.progress * 100).toInt()}%')
                            : (widget.app.status == AppStatus.installing
                                ? 'Installing...'
                                : (widget.app.status == AppStatus.installed
                                    ? 'Open'
                                    : (widget.app.isInLibrary ? 'Reinstall' : 'Install'))),
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
          GestureDetector(
            onTap: () {
              if (widget.app.status == AppStatus.installed) {
                _showUninstallConfirmationDialog(context);
              }
            },
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xfff1f5f9), width: 2),
              ),
              child: Icon(
                widget.app.status == AppStatus.installed
                    ? Icons.delete_outline_rounded
                    : Icons.bookmark_border_rounded,
                color: const Color(0xff64748b),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRetentionInfo() {
    if (widget.app.status != AppStatus.installed) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xfff1f5f9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                size: 16, color: Color(0xff64748b)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You can choose to keep your app data when uninstalling to preserve your settings.',
                style: GoogleFonts.lexend(
                  fontSize: 11,
                  color: const Color(0xff64748b),
                ),
              ),
            ),
          ],
        ),
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
            'Finally, an app that keeps our accounts safe. Reporting a suspicious phishing email was super easy with the reporting feature.',
            5,
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            'K1198765',
            'Oct 18, 2023',
            'Great UI, needs minor fixes',
            'The interface is clean and modern. The real-time scam alerts are very informative, though notifications sometimes arrive a bit late.',
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

  void _showUninstallConfirmationDialog(BuildContext context) {
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
                'Uninstall ${widget.app.title}?',
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
                              'Keep ${widget.app.size} of app data',
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
                    final error = await _installer.uninstallApp(widget.app);
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
