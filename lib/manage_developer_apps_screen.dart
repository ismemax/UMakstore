import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/developer_service.dart';
import 'add_app_screen.dart';

class ManageDeveloperAppsScreen extends StatelessWidget {
  const ManageDeveloperAppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Applications',
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: DeveloperService().getDeveloperApps(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: colorScheme.primary));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)));
          }

          final apps = snapshot.data ?? [];

          if (apps.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apps_outlined, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                  Text(
                    'No applications yet',
                    style: GoogleFonts.lexend(color: colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildAppItem(context, app, colorScheme),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAppItem(BuildContext context, Map<String, dynamic> app, ColorScheme colorScheme) {
    final title = app['title'] ?? 'Untitled';
    final version = 'V. ${app['version'] ?? '1.0.0'}';
    final status = app['status'] ?? 'Pending';
    final iconUrl = app['iconUrl'];
    final subtitle = app['createdAt'] != null 
        ? 'Submitted on ${(app['createdAt'] as Timestamp).toDate().toString().split(' ')[0]}'
        : 'Just now';
    
    final isDark = colorScheme.brightness == Brightness.dark;
    final iconColor = colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: iconUrl != null && iconUrl.startsWith('http')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(iconUrl, width: 56, height: 56, fit: BoxFit.cover),
                      )
                    : Icon(Icons.apps_rounded, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      version,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          if (app['screenshots'] != null && (app['screenshots'] as List).isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (app['screenshots'] as List).length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(app['screenshots'][index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subtitle,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  color: status == 'Rejected' ? Colors.redAccent.withValues(alpha: 0.6) : colorScheme.onSurface.withValues(alpha: 0.2),
                ),
              ),
              Row(
                children: [
                  _buildIconButton(
                    Icons.edit_outlined, 
                    colorScheme.onSurface.withValues(alpha: 0.6), 
                    colorScheme,
                    onTap: () => _editApp(context, app),
                  ),
                  const SizedBox(width: 12),
                  _buildIconButton(
                    Icons.delete_outline_rounded, 
                    Colors.redAccent.withValues(alpha: 0.4), 
                    colorScheme,
                    onTap: () => _deleteApp(context, app),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Live':
        color = Colors.greenAccent;
        break;
      case 'Pending':
        color = Colors.amberAccent;
        break;
      case 'Rejected':
        color = Colors.redAccent;
        break;
      default:
        color = Colors.white24;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status,
        style: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, ColorScheme colorScheme, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.03),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  void _editApp(BuildContext context, Map<String, dynamic> app) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAppScreen(appData: app),
      ),
    );
  }

  void _deleteApp(BuildContext context, Map<String, dynamic> app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Application', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${app['title']}"? This action cannot be undone.', style: GoogleFonts.lexend()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.lexend(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await DeveloperService().deleteApp(app['id']);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Application deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting application: $e')),
                  );
                }
              }
            },
            child: Text('Delete', style: GoogleFonts.lexend(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
