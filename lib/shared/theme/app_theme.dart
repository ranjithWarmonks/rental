
import 'package:flutter/material.dart';
import 'package:rental/shared/theme/app_color.dart';


class AppTheme{

  static final appThemeConfig =ThemeData(
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: primaryColor, // You can customize this
    ),

    fontFamily: "Urbanist",
    scaffoldBackgroundColor:Colors.transparent,
    iconTheme: const IconThemeData(
      color: Colors.white, size: 18,
      shadows: <Shadow>[Shadow(color: Colors.white, blurRadius: 0.5)],
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
      labelStyle:  TextStyle(fontFamily: "Urbanist",color: textColorBlack),
      prefixIconColor:  secondaryColor,
      suffixIconColor:  secondaryColor,
      hintStyle:   TextStyle(fontSize: 12,color:textColorBlack,fontFamily: "Urbanist", ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide:  BorderSide(width: 1.0  ,color: borderColor)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide:  BorderSide(width: 1.0,color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0),
          borderSide:  BorderSide(width: 1.0, color: borderColor)),
    ),
    appBarTheme: AppBarTheme(
        scrolledUnderElevation: 0,
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.transparent,

        //shadowColor: AppColors.appBarShadowColor,
        iconTheme: IconThemeData(
            color: secondaryColor,
            size: 18
        ),
        actionsIconTheme: IconThemeData(
            color: secondaryColor,
            size: 24
        ),
        titleTextStyle: TextStyle(fontSize: 16.0,color: btnTextColor),
        toolbarTextStyle: TextStyle(color: btnTextColor)
    ),
  );
}