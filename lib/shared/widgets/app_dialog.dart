import 'package:flutter/material.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'app_button.dart';
import 'app_text.dart';

enum AppDialogType {
  info,
  success,
  warning,
  error,
}

class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final AppDialogType type;
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final IconData? customIcon;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = AppDialogType.info,
    this.primaryButtonText = 'OK',
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.customIcon,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    AppDialogType type = AppDialogType.info,
    String primaryButtonText = 'OK',
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
    IconData? customIcon,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AppDialog(
        title: title,
        message: message,
        type: type,
        primaryButtonText: primaryButtonText,
        onPrimaryPressed: onPrimaryPressed ?? () => Navigator.of(ctx).pop(),
        secondaryButtonText: secondaryButtonText,
        onSecondaryPressed: onSecondaryPressed ?? () => Navigator.of(ctx).pop(),
        customIcon: customIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconBgColor;
    Color iconColor;

    switch (type) {
      case AppDialogType.info:
        iconData = customIcon ?? Icons.info_outline_rounded;
        iconBgColor = buttonColor1.withValues(alpha: 0.1);
        iconColor = buttonColor1;
        break;
      case AppDialogType.success:
        iconData = customIcon ?? Icons.check_circle_outline_rounded;
        iconBgColor = const Color(0xFFD1FAE5);
        iconColor = const Color(0xFF059669);
        break;
      case AppDialogType.warning:
        iconData = customIcon ?? Icons.warning_amber_rounded;
        iconBgColor = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFD97706);
        break;
      case AppDialogType.error:
        iconData = customIcon ?? Icons.error_outline_rounded;
        iconBgColor = const Color(0xFFFEE2E2);
        iconColor = const Color(0xFFDC2626);
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 30),
            ),
            const SizedBox(height: 16),
            AppText.h3(
              title,
              textAlign: TextAlign.center,
              fontSize: 18,
            ),
            const SizedBox(height: 8),
            AppText(
              message,
              textAlign: TextAlign.center,
              color: Colors.grey.shade600,
              style: AppTextStyle.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (secondaryButtonText != null) ...[
                  Expanded(
                    child: AppButton.outlined(
                      text: secondaryButtonText!,
                      onPressed: onSecondaryPressed,
                      height: 44,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: AppButton(
                    text: primaryButtonText,
                    onPressed: onPrimaryPressed,
                    height: 44,
                    backgroundColor: type == AppDialogType.error ? Colors.redAccent : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
