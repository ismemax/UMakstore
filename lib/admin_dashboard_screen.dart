import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/developer_service.dart';
import 'services/installer_service.dart';
import 'services/feedback_service.dart';
import 'models/app_model.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// The administrative nerve center for application moderation and system feedback.
/// 
/// Provides high-level visibility into pending submissions, user feedback arrays, 
/// and global store metrics.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bgColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            'Admin Dashboard',
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 20,
            ),
          ),
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: textColor.withValues(alpha: 0.5),
            indicatorColor: colorScheme.primary,
            labelStyle: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'APP REVIEWS', icon: Icon(Icons.app_registration_rounded, size: 20)),
              Tab(text: 'USER FEEDBACK', icon: Icon(Icons.feedback_outlined, size: 20)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AdminDashboardBody(),
            _FeedbackDashboardBody(),
          ],
        ),
      ),
    );
  }
}

class _FeedbackDashboardBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FeedbackService().getAllFeedback(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final feedbacks = snapshot.data ?? [];
        if (feedbacks.isEmpty) {
          return Center(
            child: Text('No feedback received yet', 
              style: GoogleFonts.lexend(color: textColor.withValues(alpha: 0.3))),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            final f = feedbacks[index];
            return _FeedbackCard(feedback: f);
          },
        );
      },
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final Map<String, dynamic> feedback;
  const _FeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rawTimestamp = feedback['timestamp'];
    String dateStr = 'Unknown date';
    if (rawTimestamp is Timestamp) {
      dateStr = DateFormat('MMM dd, yyyy • HH:mm').format(rawTimestamp.toDate());
    } else if (rawTimestamp is String) {
      final dateTime = DateTime.tryParse(rawTimestamp);
      if (dateTime != null) {
        dateStr = DateFormat('MMM dd, yyyy • HH:mm').format(dateTime);
      }
    }
    final status = feedback['status'] ?? 'New';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  feedback['category']?.toUpperCase() ?? 'OTHER',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback['subject'] ?? 'No Subject',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'From: ${feedback['userEmail'] ?? 'Anonymous'}',
            style: GoogleFonts.lexend(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          Text(
            dateStr,
            style: GoogleFonts.lexend(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              feedback['details'] ?? 'No details provided.',
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (status == 'New')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => FeedbackService().updateFeedbackStatus(feedback, 'Acknowledged'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Mark as Read', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
                  ),
                ),
              if (status == 'Acknowledged')
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => FeedbackService().updateFeedbackStatus(feedback, 'Resolved'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Resolved', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
                  ),
                ),
              if (status == 'Resolved')
                const Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                        SizedBox(width: 8),
                        Text('Resolved', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
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
      case 'New': color = Colors.amber; break;
      case 'Acknowledged': color = Colors.blue; break;
      case 'Resolved': color = Colors.green; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(status, style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

class _AdminDashboardBody extends StatefulWidget {
  @override
  State<_AdminDashboardBody> createState() => _AdminDashboardBodyState();
}

class _AdminDashboardBodyState extends State<_AdminDashboardBody> {
  final Map<String, AppModel> _appCache = {};
  final List<String> _lastIds = [];

  AppModel _getAppModel(Map<String, dynamic> data) {
    final id = data['id'];
    if (_appCache.containsKey(id)) {
      return _appCache[id]!;
    }
    
    final newApp = AppModel(
      id: id,
      title: data['title'] ?? 'Untitled',
      publisher: data['publisher'] ?? 'Unknown',
      description: data['description'] ?? '',
      iconAsset: data['iconUrl'] ?? 'assets/logo.svg',
      category: data['category'] ?? 'App',
      college: data['college'] ?? 'University-wide',
      downloadUrl: data['downloadUrl'] ?? '',
      packageName: data['packageName'],
      version: data['version'] ?? '1.0.0',
      size: data['size'] ?? '0 MB',
      rating: data['rating'] ?? '0.0',
      reviews: data['reviews'] ?? '0',
      screenshots: List<String>.from(data['screenshots'] ?? []),
      permissions: List<String>.from(data['permissions'] ?? []),
    );
    _appCache[id] = newApp;
    return newApp;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DeveloperService().getAllAppsAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rawApps = snapshot.data ?? [];
        if (rawApps.isEmpty) {
          return Center(
            child: Text('No apps pending review', 
              style: GoogleFonts.lexend(color: textColor.withValues(alpha: 0.3))),
          );
        }

        final apps = rawApps.map((data) => _getAppModel(data)).toList();
        final currentIds = apps.map((e) => e.id).toList();

        // Only update statuses if the collection of apps has changed
        if (currentIds.length != _lastIds.length || !currentIds.every((id) => _lastIds.contains(id))) {
          _lastIds.clear();
          _lastIds.addAll(currentIds);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            InstallerService().updateAllStatuses(apps);
          });
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            return _AdminAppCard(
              app: apps[index],
              approvalStatus: rawApps[index]['status'] ?? 'Pending',
            );
          },
        );
      },
    );
  }
}

class _AdminAppCard extends StatefulWidget {
  final AppModel app;
  final String approvalStatus;

  const _AdminAppCard({required this.app, required this.approvalStatus});

  @override
  State<_AdminAppCard> createState() => _AdminAppCardState();
}

class _AdminAppCardState extends State<_AdminAppCard> {
  late InstallerService _installer;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _installer = InstallerService();
    _installer.addListener(_update);
  }

  @override
  void dispose() {
    _installer.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = widget.app.status;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: (widget.app.iconAsset.startsWith('http'))
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(widget.app.iconAsset, fit: BoxFit.cover),
                      )
                    : Icon(Icons.apps_rounded, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.app.title,
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'from ${widget.app.publisher}',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(widget.approvalStatus),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STEP 1: TEST THE APPLICATION',
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (status == AppStatus.downloading)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: widget.app.progress >= 0 ? widget.app.progress : null,
                            minHeight: 4,
                            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                          ),
                        )
                      else
                        Text(
                          _getStatusText(status),
                          style: GoogleFonts.lexend(fontSize: 11, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildTestButton(widget.app, colorScheme),
              ],
            ),
          ),
          
          // MAK Guard: Permissions Review & Health Check
          const SizedBox(height: 12),
          _MAKGuardPanel(app: widget.app),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: (_isUpdating || widget.approvalStatus == 'Rejected') ? null : () => _updateStatus(context, widget.app.id, 'Rejected'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isUpdating 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent))
                    : Text('Reject', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: (_isUpdating || widget.approvalStatus == 'Live') ? null : () => _updateStatus(context, widget.app.id, 'Live'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isUpdating 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54))
                    : Text('Approve', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(AppModel app, ColorScheme colorScheme) {
    switch (app.status) {
      case AppStatus.downloading:
      case AppStatus.installing:
        return Container(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(4),
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      case AppStatus.installed:
        return TextButton.icon(
          onPressed: () => _installer.launchApp(app),
          icon: const Icon(Icons.play_arrow_rounded, size: 18),
          label: const Text('Launch'),
        );
      default:
        return TextButton.icon(
          onPressed: () => _installer.installApp(app),
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Test'),
        );
    }
  }

  String _getStatusText(AppStatus status) {
    switch (status) {
      case AppStatus.installed: return 'App is ready for testing';
      case AppStatus.installing: return 'Installing...';
      case AppStatus.downloading: return 'Downloading APK...';
      default: return 'Needs testing';
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Live': color = Colors.greenAccent; break;
      case 'Pending': color = Colors.amberAccent; break;
      case 'Rejected': color = Colors.redAccent; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(status, style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  void _updateStatus(BuildContext context, String appId, String status) async {
    String? reason;
    
    // If rejecting, show dialog for reason
    if (status == 'Rejected') {
      reason = await showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
            title: Text('Reason for Rejection', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
            content: TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason (e.g. Broken link, invalid icon)',
                hintStyle: GoogleFonts.lexend(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                child: const Text('Confirm Reject'),
              ),
            ],
          );
        },
      );
      
      // If admin cancelled, stop here
      if (reason == null) return;
    }

    setState(() => _isUpdating = true);
    debugPrint('ADMIN ACTION: Updating App $appId to $status (Reason: $reason)');
    try {
      await DeveloperService().updateAppStatus(appId, status, reason: reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('App status updated to $status'), backgroundColor: status == 'Live' ? Colors.green : Colors.red),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }
}

class _MAKGuardPanel extends StatefulWidget {
  final AppModel app;
  const _MAKGuardPanel({required this.app});

  @override
  State<_MAKGuardPanel> createState() => _MAKGuardPanelState();
}

class _MAKGuardPanelState extends State<_MAKGuardPanel> {
  bool _isChecking = false;
  Map<String, bool?> _results = {};

  Future<void> _runHealthCheck() async {
    setState(() {
      _isChecking = true;
      _results = {};
    });

    final links = {
      'APK Link': widget.app.downloadUrl,
      'App Icon': widget.app.iconAsset,
    };
    for (int i = 0; i < widget.app.screenshots.length; i++) {
      links['Screenshot ${i + 1}'] = widget.app.screenshots[i];
    }

    final Map<String, bool?> newResults = {};
    for (var entry in links.entries) {
      if (entry.value.isEmpty || !entry.value.startsWith('http')) {
        newResults[entry.key] = false;
        continue;
      }
      try {
        final resp = await http.head(Uri.parse(entry.value)).timeout(const Duration(seconds: 5));
        newResults[entry.key] = resp.statusCode == 200;
      } catch (_) {
        newResults[entry.key] = false;
      }
    }

    if (mounted) {
      setState(() {
        _results = newResults;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                   Icon(Icons.security_rounded, size: 16, color: colorScheme.secondary),
                   const SizedBox(width: 8),
                   Text(
                    'MAK GUARD REVIEW',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              if (!_isChecking && _results.isEmpty)
                GestureDetector(
                  onTap: _runHealthCheck,
                  child: Text(
                    'RUN HEALTH CHECK',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                )
              else if (_isChecking)
                const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
              else
                Icon(Icons.check_circle_rounded, size: 16, color: Colors.greenAccent),
            ],
          ),
          
          if (widget.app.permissions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'REQUESTED PERMISSIONS:',
              style: GoogleFonts.lexend(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.app.permissions.map((p) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  p.toUpperCase(),
                  style: GoogleFonts.firaCode(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              )).toList(),
            ),
          ],

          if (_results.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ..._results.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    e.value == true ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                    size: 12,
                    color: e.value == true ? Colors.greenAccent : Colors.redAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    e.key,
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }
}
