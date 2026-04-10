import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/auth_service.dart';
import 'services/device_service.dart';
import 'widgets/sign_out_dialog.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  bool _isLoading = false;
  bool _isRevoking = false;
  Map<String, dynamic>? _deviceInfo;
  String? _activeDeviceId;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _deviceInfo = userData['devices'] ?? {};
            _activeDeviceId = userData['activeDeviceId'];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading device info: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _revokeAllDevices() async {
    final confirmed = await _showRevokeConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isRevoking = true);
    try {
      final success = await AuthService().revokeAllDevices();
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All devices revoked successfully'),
              backgroundColor: Colors.green,
            ),
          );
          await AuthService().signOutUser();
          Navigator.of(context).pushReplacementNamed('/auth');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error revoking devices: $e')),
        );
      }
    } finally {
      setState(() => _isRevoking = false);
    }
  }

  Future<bool> _showRevokeConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Revoke All Devices',
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will sign you out from all devices and require you to sign in again on your current device. Are you sure?',
          style: GoogleFonts.lexend(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.lexend(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Revoke All',
              style: GoogleFonts.lexend(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Device Management',
          style: GoogleFonts.lexend(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Device Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.phone_android,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Current Device',
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_activeDeviceId != null) ...[
                    Text(
                      'Device ID: ${_activeDeviceId!.substring(0, 8)}...',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: Active',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Security Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Single-Device Access',
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your UMak App Store account is configured to allow access from only one device at a time. This enhances security and prevents unauthorized access.',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'If you try to sign in from a new device, you will be automatically signed out from your current device.',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            if (_deviceInfo != null && _deviceInfo!.isNotEmpty) ...[
              Text(
                'Registered Devices',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ..._deviceInfo!.entries.map((entry) => _buildDeviceCard(entry.key, entry.value)),
            ],
            
            const SizedBox(height: 32),
            
            // Revoke All Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isRevoking ? null : _revokeAllDevices,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isRevoking
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Revoking...'),
                        ],
                      )
                    : const Text(
                        'Revoke All Devices',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(String deviceId, Map<String, dynamic> deviceData) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = deviceData['isActive'] == true;
    final lastActive = deviceData['lastActive'];
    final platform = deviceData['platform'] ?? 'Unknown';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? colorScheme.primary : colorScheme.outline,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive ? colorScheme.primary : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              platform == 'Android' ? Icons.phone_android : Icons.phone_iphone,
              color: isActive ? Colors.white : colorScheme.onSurface,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      platform,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Last active: ${_formatDate(lastActive)}',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
