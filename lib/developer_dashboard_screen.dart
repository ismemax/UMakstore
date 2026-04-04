import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_app_screen.dart';
import 'manage_developer_apps_screen.dart';
import 'services/developer_service.dart';

class DeveloperDashboardScreen extends StatefulWidget {
  const DeveloperDashboardScreen({super.key});

  @override
  State<DeveloperDashboardScreen> createState() => _DeveloperDashboardScreenState();
}

class _DeveloperDashboardScreenState extends State<DeveloperDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = colorScheme.surface;
    final cardColor = isDark ? colorScheme.surfaceContainer : colorScheme.surfaceContainerLow;
    final accentColor = colorScheme.primary;
    final textColor = colorScheme.onSurface;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DeveloperService().getDeveloperApps(),
      builder: (context, snapshot) {
        final apps = snapshot.data ?? [];
        final liveAppsCount = apps.where((a) => a['status'] == 'Live').length;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Developer Portal',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 20,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(textColor),
                const SizedBox(height: 32),
                _buildStatsGrid(accentColor, colorScheme.secondary, liveAppsCount, colorScheme),
                const SizedBox(height: 32),
                _buildSectionHeader('YOUR APPLICATIONS', textColor, accentColor, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageDeveloperAppsScreen()),
                  );
                }),
                const SizedBox(height: 16),
                _buildAppList(apps, colorScheme),
                const SizedBox(height: 40),
                _buildDeployButton(accentColor, colorScheme.secondary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeHeader(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Console Overview',
          style: GoogleFonts.lexend(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your ecosystem and track deployments',
          style: GoogleFonts.lexend(
            fontSize: 14,
            color: textColor.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Color accent, Color secondary, int liveAppsCount, ColorScheme colorScheme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard('Total Downloads', '0', Icons.download_rounded, accent, colorScheme),
        _buildStatCard('Active Users', '0', Icons.people_outline_rounded, secondary, colorScheme),
        _buildStatCard('Average Rating', '0.0', Icons.star_rounded, Colors.amber, colorScheme),
        _buildStatCard('Live Apps', liveAppsCount.toString(), Icons.rocket_launch_rounded, Colors.greenAccent, colorScheme),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color iconColor, ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '+12%',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor, Color accentColor, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor.withValues(alpha: 0.4),
            letterSpacing: 1.5,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            'See All',
            style: GoogleFonts.lexend(
              fontSize: 12,
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppList(List<Map<String, dynamic>> apps, ColorScheme colorScheme) {
    if (apps.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Text(
            'No applications deployed yet.',
            style: GoogleFonts.lexend(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }
    return Column(
      children: apps.take(3).map((app) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildAppCard(
          app['title'] ?? 'Unknown',
          'V. ${app['version'] ?? '1.0.0'}',
          app['status'] ?? 'Pending',
          Icons.apps_rounded,
          colorScheme,
          iconUrl: app['iconUrl'],
        ),
      )).toList(),
    );
  }

  Widget _buildAppCard(String title, String version, String status, IconData icon, ColorScheme colorScheme, {String? iconUrl}) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final iconColor = colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: iconUrl != null && iconUrl.startsWith('http')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(iconUrl, width: 48, height: 48, fit: BoxFit.cover),
                  )
                : Icon(icon, color: iconColor, size: 24),
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
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  version,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'Live' ? Colors.green.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: status == 'Live' ? Colors.green.withValues(alpha: 0.2) : Colors.amber.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              status,
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: status == 'Live' ? Colors.greenAccent : Colors.amberAccent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: colorScheme.onSurface.withValues(alpha: 0.2)),
        ],
      ),
    );
  }

  Widget _buildDeployButton(Color accent, Color secondary) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddAppScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent, secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                'Deploy New App',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
