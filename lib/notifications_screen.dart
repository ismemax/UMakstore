import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/notification_service.dart';
import 'models/notification_model.dart';
import 'services/language_service.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final LanguageService _languageService = LanguageService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_updateUI);
  }

  @override
  void dispose() {
    _languageService.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _languageService.translate('notifications'),
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            letterSpacing: -0.45,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: colorScheme.outlineVariant, height: 1.0),
        ),
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _notificationService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                _languageService.translate('notifications_failed'),
                style: GoogleFonts.lexend(color: colorScheme.error),
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Dismissible(
                key: Key(notification.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  _notificationService.deleteNotification(notification.id);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildNotificationCard(context, notification),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            _languageService.translate('no_notifications'),
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _languageService.translate('notifications_desc'),
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel notification) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUnread = !notification.isRead;

    // Determine icon and colors based on type
    final iconData = _getIconForType(notification.type);
    final iconColor = _getColorForType(notification.type, colorScheme);
    
    return InkWell(
      onTap: () {
        if (isUnread) {
          _notificationService.markAsRead(notification.id);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isUnread 
              ? colorScheme.primary.withValues(alpha: 0.05) 
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread ? colorScheme.primary.withValues(alpha: 0.2) : colorScheme.outlineVariant,
            width: isUnread ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(iconData, color: iconColor, size: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: isUnread
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTimeAgo(notification.timestamp),
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
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

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.success: return Icons.check_circle_rounded;
      case NotificationType.warning: return Icons.warning_rounded;
      case NotificationType.error: return Icons.error_rounded;
      case NotificationType.appUpdate: return Icons.system_update_rounded;
      case NotificationType.promotional: return Icons.celebration_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(NotificationType type, ColorScheme colorScheme) {
    switch (type) {
      case NotificationType.success: return const Color(0xff10b981);
      case NotificationType.warning: return const Color(0xfffb923c);
      case NotificationType.error: return colorScheme.error;
      case NotificationType.appUpdate: return colorScheme.primary;
      case NotificationType.promotional: return const Color(0xff8b5cf6);
      default: return colorScheme.secondary;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return _languageService.translate('time_now');
    if (diff.inMinutes < 60) return '${diff.inMinutes}${_languageService.translate('time_m_ago')}';
    if (diff.inHours < 24) return '${diff.inHours}${_languageService.translate('time_h_ago')}';
    if (diff.inDays < 7) return '${diff.inDays}${_languageService.translate('time_d_ago')}';
    return DateFormat.yMMMd().format(dateTime);
  }
}
