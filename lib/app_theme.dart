import 'package:flutter/material.dart';
import 'package:KhadoAndSons/utils/resources/colors.dart';

class AppTheme {
  //
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: app_background,
    highlightColor: book_detail_background,
    primaryColor: colorPrimary,
    primaryColorDark: colorPrimaryDark,
    errorColor: Colors.red,
    hoverColor: Colors.grey,
    appBarTheme: AppBarTheme(
      color: app_background,
      iconTheme: IconThemeData(
        color: textColorPrimary,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: colorPrimary,
      onPrimary: colorPrimary,
      primaryVariant: colorPrimary,
      secondary: Colors.pink,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
    ),
    iconTheme: IconThemeData(
      color: textColorPrimary,
    ),
    textTheme: TextTheme(
      button: TextStyle(color: Colors.blueAccent),
      title: TextStyle(
        color: textColorPrimary,
      ),
      subtitle: TextStyle(
        color: textColorSecondary,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: app_background_black,
    highlightColor: app_background_black,
    errorColor: Color(0xFFCF6676),
    appBarTheme: AppBarTheme(
      color: app_background_black,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    primaryColor: color_primary_black,
    primaryColorDark: color_primary_black,
    hoverColor: Colors.black,
    colorScheme: ColorScheme.light(
      primary: app_background_black,
      onPrimary: card_background_black,
      primaryVariant: color_primary_black,
      secondary: Colors.pinkAccent,
    ),
    cardTheme: CardTheme(
      color: card_background_black,
    ),
    iconTheme: IconThemeData(
      color: Colors.white70,
    ),
    textTheme: TextTheme(
      button: TextStyle(color: color_primary_black),
      title: TextStyle(
        color: Colors.white70,
      ),
      subtitle: TextStyle(
        color: Colors.white54,
      ),
    ),
  );
}
