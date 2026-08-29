import 'package:flutter/material.dart';
import 'package:rental/shared/theme/app_color.dart';

enum AppTextStyle {
  h1,
  h2,
  h3,
  bodyLarge,
  bodyMedium,
  bodySmall,
  label,
  caption,
}

class AppText extends StatelessWidget {
  final String text;
  final AppTextStyle style;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? fontSize;
  final double? letterSpacing;

  const AppText(
    this.text, {
    super.key,
    this.style = AppTextStyle.bodyMedium,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.letterSpacing,
  });

  const AppText.h1(
    this.text, {
    super.key,
    this.color = primaryColor,
    this.fontWeight = FontWeight.bold,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.letterSpacing,
  }) : style = AppTextStyle.h1;

  const AppText.h2(
    this.text, {
    super.key,
    this.color = primaryColor,
    this.fontWeight = FontWeight.bold,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.letterSpacing,
  }) : style = AppTextStyle.h2;

  const AppText.h3(
    this.text, {
    super.key,
    this.color = primaryColor,
    this.fontWeight = FontWeight.w600,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.letterSpacing,
  }) : style = AppTextStyle.h3;

  const AppText.label(
    this.text, {
    super.key,
    this.color = textColorBlack,
    this.fontWeight = FontWeight.w600,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.letterSpacing,
  }) : style = AppTextStyle.label;

  const AppText.caption(
    this.text, {
    super.key,
    this.color = Colors.grey,
    this.fontWeight = FontWeight.normal,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.letterSpacing,
  }) : style = AppTextStyle.caption;

  @override
  Widget build(BuildContext context) {
    double computedFontSize;
    FontWeight computedFontWeight;
    Color computedColor;

    switch (style) {
      case AppTextStyle.h1:
        computedFontSize = fontSize ?? 24.0;
        computedFontWeight = fontWeight ?? FontWeight.bold;
        computedColor = color ?? primaryColor;
        break;
      case AppTextStyle.h2:
        computedFontSize = fontSize ?? 20.0;
        computedFontWeight = fontWeight ?? FontWeight.bold;
        computedColor = color ?? primaryColor;
        break;
      case AppTextStyle.h3:
        computedFontSize = fontSize ?? 16.0;
        computedFontWeight = fontWeight ?? FontWeight.w600;
        computedColor = color ?? primaryColor;
        break;
      case AppTextStyle.bodyLarge:
        computedFontSize = fontSize ?? 16.0;
        computedFontWeight = fontWeight ?? FontWeight.normal;
        computedColor = color ?? textColorBlack;
        break;
      case AppTextStyle.bodyMedium:
        computedFontSize = fontSize ?? 14.0;
        computedFontWeight = fontWeight ?? FontWeight.normal;
        computedColor = color ?? textColorBlack;
        break;
      case AppTextStyle.bodySmall:
        computedFontSize = fontSize ?? 12.0;
        computedFontWeight = fontWeight ?? FontWeight.normal;
        computedColor = color ?? Colors.grey.shade600;
        break;
      case AppTextStyle.label:
        computedFontSize = fontSize ?? 13.0;
        computedFontWeight = fontWeight ?? FontWeight.w600;
        computedColor = color ?? primaryColor;
        break;
      case AppTextStyle.caption:
        computedFontSize = fontSize ?? 11.0;
        computedFontWeight = fontWeight ?? FontWeight.normal;
        computedColor = color ?? Colors.grey.shade500;
        break;
    }

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontFamily: 'Urbanist',
        fontSize: computedFontSize,
        fontWeight: computedFontWeight,
        color: computedColor,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
