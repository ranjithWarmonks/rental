import 'package:flutter/material.dart';
import 'package:rental/shared/theme/app_color.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outlined,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool iconRight;
  final double? width;
  final double height;
  final Color? backgroundColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.iconRight = false,
    this.width,
    this.height = 50.0,
    this.backgroundColor,
  });

  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.iconRight = false,
    this.width,
    this.height = 50.0,
    this.backgroundColor,
  })  : variant = AppButtonVariant.secondary;

  const AppButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.iconRight = false,
    this.width,
    this.height = 50.0,
    this.backgroundColor,
  })  : variant = AppButtonVariant.outlined;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = backgroundColor ?? buttonColor1; // #059669
        fg = Colors.white;
        border = BorderSide.none;
        break;
      case AppButtonVariant.secondary:
        bg = backgroundColor ?? primaryColor; // #0F172A
        fg = Colors.white;
        border = BorderSide.none;
        break;
      case AppButtonVariant.outlined:
        bg = backgroundColor ?? Colors.white;
        fg = primaryColor;
        border = BorderSide(color: Colors.grey.shade300, width: 1);
        break;
    }

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          color: variant == AppButtonVariant.outlined ? primaryColor : Colors.white,
          strokeWidth: 2.5,
        ),
      );
    } else {
      List<Widget> children = [];

      if (icon != null && !iconRight) {
        children.add(Icon(icon, size: 20, color: fg));
        children.add(const SizedBox(width: 8));
      }

      children.add(
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Urbanist',
              color: fg,
            ),
          ),
        ),
      );

      if (icon != null && iconRight) {
        children.add(const SizedBox(width: 8));
        children.add(Icon(icon, size: 20, color: fg));
      }

      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: variant == AppButtonVariant.outlined ? 0 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: border,
          ),
        ),
        child: content,
      ),
    );
  }
}
