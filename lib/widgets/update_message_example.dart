import 'package:flutter/material.dart';
import 'update_message_widget.dart';

class UpdateMessageExample extends StatelessWidget {
  const UpdateMessageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Message Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SuccessUpdateMessage(
              message: 'Your profile has been successfully updated!',
              actionText: 'View Profile',
              onActionPressed: null,
            ),
            const SizedBox(height: 16),
            const ErrorUpdateMessage(
              message: 'Failed to upload file. Please check your internet connection and try again.',
              actionText: 'Retry',
              onActionPressed: null,
            ),
            const SizedBox(height: 16),
            const InfoUpdateMessage(
              message: 'A new version of this app is available. Update to get the latest features and security improvements.',
              actionText: 'Update Now',
              onActionPressed: null,
            ),
            const SizedBox(height: 16),
            const WarningUpdateMessage(
              message: 'Your storage is almost full. Consider removing unused apps or files to free up space.',
              actionText: 'Manage Storage',
              onActionPressed: null,
            ),
            const SizedBox(height: 16),
            UpdateMessageWidget(
              title: 'DDoS Protection Enabled',
              message: 'Security features have been enhanced to protect against DDoS attacks. Your app is now more secure.',
              actionText: 'Learn More',
              onActionPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Security documentation opened'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              iconData: Icons.security,
            ),
          ],
        ),
      ),
    );
  }
}
