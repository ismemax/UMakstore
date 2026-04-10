import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UpdateMessageWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final bool showIcon;
  final IconData? iconData;
  final String? svgAsset;

  const UpdateMessageWidget({
    super.key,
    required this.title,
    required this.message,
    this.actionText,
    this.onActionPressed,
    this.showIcon = true,
    this.iconData,
    this.svgAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (showIcon) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildIcon(context),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          if (actionText != null && onActionPressed != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onActionPressed,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(actionText!),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (svgAsset != null) {
      return SvgPicture.asset(
        svgAsset!,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.primary,
          BlendMode.srcIn,
        ),
      );
    }
    
    if (iconData != null) {
      return Icon(
        iconData,
        size: 24,
        color: Theme.of(context).colorScheme.primary,
      );
    }
    
    return Icon(
      Icons.info_outline,
      size: 24,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}

class SuccessUpdateMessage extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const SuccessUpdateMessage({
    super.key,
    required this.message,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return UpdateMessageWidget(
      title: 'Success',
      message: message,
      actionText: actionText,
      onActionPressed: onActionPressed,
      iconData: Icons.check_circle_outline,
    );
  }
}

class ErrorUpdateMessage extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const ErrorUpdateMessage({
    super.key,
    required this.message,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return UpdateMessageWidget(
      title: 'Error',
      message: message,
      actionText: actionText,
      onActionPressed: onActionPressed,
      iconData: Icons.error_outline,
    );
  }
}

class InfoUpdateMessage extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const InfoUpdateMessage({
    super.key,
    required this.message,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return UpdateMessageWidget(
      title: 'Information',
      message: message,
      actionText: actionText,
      onActionPressed: onActionPressed,
      iconData: Icons.info_outline,
    );
  }
}

class WarningUpdateMessage extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const WarningUpdateMessage({
    super.key,
    required this.message,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return UpdateMessageWidget(
      title: 'Warning',
      message: message,
      actionText: actionText,
      onActionPressed: onActionPressed,
      iconData: Icons.warning_amber_outlined,
    );
  }
}
